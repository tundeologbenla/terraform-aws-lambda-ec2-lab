
variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "ap-southeast-2"
}

variable "project_name" {
  description = "Prefix for the lab's AWS resources"
  type        = string
  default     = "terraform-lab"
}

variable "ec2_instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "ec2_ami_id" {
  description = "AMI ID used for the EC2 lab instance"
  type        = string
}
