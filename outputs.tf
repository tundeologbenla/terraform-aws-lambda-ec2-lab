
output "s3_bucket_name" {
  description = "S3 bucket holding the Lambda package"
  value       = aws_s3_bucket.lambda_artifacts.bucket
}

output "lambda_function_name" {
  description = "Name of the scheduled Lambda function"
  value       = aws_lambda_function.scheduled.function_name
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.lab.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.lab.public_ip
}

output "aws_region" {
  description = "AWS region used for the project"
  value       = var.aws_region
}
