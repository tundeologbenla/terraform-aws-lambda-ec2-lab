 # Terraform AWS Lambda and EC2 Lab

## Overview
This project is a hands-on AWS infrastructure lab built with Terraform. It demonstrates infrastructure as code (IaC), AWS resource provisioning, IAM permissions, serverless automation, and EC2 instance management.

The project is intended as a learning and portfolio exercise, with an emphasis on repeatable deployments, least-privilege access, and cost awareness.

## Architecture
Terraform manages the following AWS resources in the `ap-southeast-2` (Sydney) region:

- **Amazon S3** — stores the packaged Lambda deployment artifact.
- **AWS Lambda** — runs a Python function that logs the incoming event and returns a response.
- **Amazon EventBridge** — provides scheduled invocation of the Lambda function.
- **Amazon EC2** — provisions a `t3.micro` Linux instance.
- **AWS IAM** — defines execution roles and permissions for Lambda and EC2.
- **Amazon CloudWatch Logs** — receives Lambda execution logs.
- **Terraform providers** — manage AWS resources, package the Lambda code, and generate a unique resource suffix.

## Repository Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── lambda/
│   ├── handler.py
│   └── requirements.txt
├── README.md
└── .gitignore
```

## Prerequisites

- Terraform CLI
- AWS CLI
- An AWS account with appropriate permissions
- Git

Configure AWS CLI credentials locally using a dedicated profile with appropriately scoped permissions. Do not commit access keys, secret keys, Terraform state files, or other sensitive credentials.

## Initial Setup
Initialise the Terraform working directory:

```
terraform init
```

Format and validate the configuration:

```
terraform fmt -recursive
terraform validate
```

Review the proposed changes:

```
terraform plan
```

Apply the configuration only after reviewing the plan:

```
terraform apply
```

Terraform outputs include the EC2 instance ID, public IP address, Lambda function name, S3 bucket name, and AWS region.

## Cost and Resource Management
AWS resources can incur charges even when they are not actively being used.

- Stop the EC2 instance when it is not needed for testing. EBS storage and some other charges may continue.
- Disable the EventBridge schedule when the Lambda function does not need to run.
- Review S3 storage, public IPv4 address charges, and CloudWatch Logs usage.
- Use `terraform destroy` when you no longer need the lab resources, after reviewing the proposed destruction carefully.

Always review AWS billing and budget alerts regularly. Free Tier eligibility and credits do not guarantee that every resource or usage pattern is free.

## Security Considerations

- Use least-privilege IAM policies.
- Require IMDSv2 on the EC2 instance.
- Keep S3 public access blocked.
- Do not commit AWS credentials, `.tfstate` files, plans, or secret variable files.
- Review Terraform plans before applying changes.

## Learning Objectives

- Provision and manage AWS infrastructure using Terraform.
- Understand Terraform state, plans, and resource lifecycle behaviour.
- Configure IAM roles and least-privilege policies.
- Deploy a Python Lambda function using an S3-hosted deployment package.
- Configure EventBridge scheduled invocation.
- Provision and manage an EC2 instance.
- Practise cost control and safe infrastructure changes.

## Current Status
This lab is under development. Resource provisioning, IAM permissions, scheduled invocation, and lifecycle management are being validated incrementally.
