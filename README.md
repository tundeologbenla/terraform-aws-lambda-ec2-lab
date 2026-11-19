# Terraform AWS Lambda and EC2 Lab

## Overview

This project is a hands-on AWS infrastructure lab built with Terraform. It demonstrates Infrastructure as Code (IaC), AWS resource provisioning, IAM permissions, serverless automation, EC2 instance management and infrastructure security.

The project is intended as a learning and portfolio exercise, with an emphasis on repeatable deployments, least-privilege access, operational resilience, security scanning and cost awareness.

## Architecture

Terraform manages the following AWS resources in the `ap-southeast-2` (Sydney) region:

- **Amazon S3** — stores the packaged Lambda deployment artifact, with bucket versioning and lifecycle management.
- **AWS Lambda** — runs a Python function that logs incoming events and returns a response.
- **Amazon SQS** — provides a dead-letter queue (DLQ) for failed asynchronous Lambda invocations.
- **Amazon EventBridge** — provides scheduled invocation of the Lambda function. The schedule is currently disabled.
- **Amazon EC2** — provisions a `t3.micro` Linux instance without a public IP address.
- **AWS IAM** — defines execution roles and scoped permissions for Lambda and EC2.
- **Amazon CloudWatch Logs** — receives Lambda execution logs.
- **AWS X-Ray** — provides active Lambda tracing.
- **Terraform providers** — manage AWS resources, package the Lambda code and generate a unique resource suffix.

## Repository Structure

```text
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

- Terraform CLI (version 1.6 or later)
- AWS CLI
- An AWS account with appropriate permissions
- Git

Configure AWS CLI credentials locally using a dedicated profile with appropriately scoped permissions.

For example:

```bash
aws configure --profile terraform-lab
```

Set the profile and AWS region in your terminal:

```bash
export AWS_PROFILE=terraform-lab
export AWS_DEFAULT_REGION=ap-southeast-2
export AWS_REGION=ap-southeast-2
```

Verify authentication:

```bash
aws sts get-caller-identity
```

Do not commit access keys, secret keys, Terraform state files, plan files or other sensitive credentials.

## Initial Setup

Initialise the Terraform working directory:

```bash
terraform init
```

Format and validate the configuration:

```bash
terraform fmt -recursive
terraform validate
```

Review the proposed infrastructure changes:

```bash
terraform plan
```

Apply the configuration only after reviewing the plan:

```bash
terraform apply
```

Terraform outputs include the EC2 instance ID, public IP address, Lambda function name, S3 bucket name and AWS region.

## Security and Resilience

Security and operational resilience are important considerations throughout this lab.

### Identity and access management

- Use least-privilege IAM policies.
- Use dedicated IAM roles for Lambda and EC2.
- Restrict Lambda DLQ permissions to the specific SQS queue ARN.
- Avoid hard-coded AWS credentials in Terraform configuration.

### Lambda resilience and observability

- Configure an SQS dead-letter queue for failed asynchronous invocations.
- Limit reserved Lambda concurrency to one execution.
- Enable AWS X-Ray active tracing.
- Use CloudWatch Logs for Lambda execution visibility.

### S3 security and lifecycle management

- Block public S3 access.
- Enable bucket versioning.
- Expire noncurrent object versions after 30 days.
- Abort incomplete multipart uploads after seven days.
- Retain encryption at rest for stored deployment artifacts.

### EC2 and network security

- Require IMDSv2 for instance metadata access.
- Encrypt the EC2 root EBS volume.
- Avoid assigning a public IP address.
- Restrict outbound security group traffic to HTTPS (TCP 443).
- Use AWS Systems Manager Session Manager for instance access.

## Security Scanning

Checkov is used to scan Terraform configuration for potential security and infrastructure misconfigurations.

Run a local Terraform scan:

```bash
checkov -d . --framework terraform
```

Findings are reviewed individually to determine whether they require remediation or represent justified exceptions for this lab.

The objective is not simply to achieve zero failed checks. Security controls should be appropriate to the architecture, operational requirements and cost constraints.

## Cost and Resource Management

AWS resources can incur charges even when they are not actively being used.

- Stop the EC2 instance when it is not needed for testing. EBS storage and other applicable charges may continue.
- Keep the EventBridge schedule disabled when scheduled Lambda execution is not required.
- Review S3 storage and noncurrent object versions.
- Monitor CloudWatch Logs and AWS X-Ray usage.
- Review AWS billing and budget alerts regularly.
- Use `terraform destroy` when the lab resources are no longer required, after carefully reviewing the proposed destruction.

Free Tier eligibility and AWS credits do not guarantee that every resource or usage pattern is free.

## Learning Objectives

- Provision and manage AWS infrastructure using Terraform.
- Understand Terraform state, plans and resource lifecycle behaviour.
- Configure IAM roles and least-privilege permissions.
- Deploy a Python Lambda function using an S3-hosted deployment package.
- Configure asynchronous Lambda failure handling with SQS.
- Implement S3 versioning and lifecycle policies.
- Apply security controls to EC2 and AWS networking.
- Use Checkov to identify and assess infrastructure security findings.
- Practise cost control and safe infrastructure changes.

## Current Status

The project is actively being developed and security-hardened.

Implemented configuration improvements include:

- Lambda concurrency controls and SQS dead-letter handling.
- Active AWS X-Ray tracing.
- Scoped IAM permissions for Lambda failure handling.
- S3 versioning and lifecycle management.
- Restricted EC2 outbound network access.
- IMDSv2 enforcement and encrypted EBS storage.
- Terraform validation and Checkov security scanning.

Further work includes reviewing remaining Checkov findings, documenting justified security exceptions and continuing to improve infrastructure security and operational practices.