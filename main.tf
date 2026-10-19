
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# S3 bucket for the Lambda deployment package.

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "${var.project_name}-lambda-${random_id.suffix.hex}"

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_artifacts" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_object" "lambda_package" {
  bucket = aws_s3_bucket.lambda_artifacts.id
  key    = "releases/lambda.zip"
  source = data.archive_file.lambda_package.output_path
  etag   = data.archive_file.lambda_package.output_md5
}

# Lambda execution role.

resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "scheduled" {
  function_name = "${var.project_name}-scheduled-${random_id.suffix.hex}"
  role          = aws_iam_role.lambda.arn
  runtime       = "python3.12"
  handler       = "handler.lambda_handler"

  s3_bucket = aws_s3_bucket.lambda_artifacts.id
  s3_key    = aws_s3_object.lambda_package.key

  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs
  ]

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# EventBridge schedule: invokes Lambda every five minutes.

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.project_name}-schedule-${random_id.suffix.hex}"
  description         = "Triggers the Terraform lab Lambda every five minutes"
  schedule_expression = "rate(5 minutes)"
  state = "DISABLED"
  
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "InvokeLambda"
  arn       = aws_lambda_function.scheduled.arn
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduled.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

# EC2 IAM role for Systems Manager Session Manager.

resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-ec2-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-profile-${random_id.suffix.hex}"
  role = aws_iam_role.ec2.name
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg-${random_id.suffix.hex}"
  description = "No inbound access; outbound traffic for SSM"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"
    ]
  }

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

resource "aws_instance" "lab" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.ec2_instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name      = "${var.project_name}-ec2"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}
