# AWS CloudWatch Synthetics URL Monitoring

This Terraform configuration sets up a complete URL monitoring solution using AWS CloudWatch Synthetics, with alerting via SNS notifications.

## Features

- CloudWatch Synthetics canary for URL monitoring
- SNS topic and subscriptions for notifications
- CloudWatch alarm configuration for failure alerts
- Modular and reusable Terraform configuration

## Architecture

The solution consists of three main components:

1. **Synthetic Monitoring Module**
   - Creates a CloudWatch Synthetics canary
   - Sets up an S3 bucket for artifacts
   - Configures necessary IAM roles and policies

2. **Notification Module**
   - Creates an SNS topic
   - Sets up email subscriptions for alerts

3. **Alarm Module**
   - Configures CloudWatch alarms based on canary metrics
   - Links to SNS for notifications

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version 0.12 or later)
- An AWS account with necessary permissions

## Usage

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. Configure your variables in `terraform.tfvars`:
   ```hcl
   aws_region = "us-east-1"
   url_to_monitor = "https://your-url.com"
   email_endpoints = ["your-email@example.com"]
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the planned changes:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

6. Confirm the email subscription when you receive the confirmation email from AWS SNS.

## Configuration Options

### Required Variables

- `url_to_monitor`: The URL to monitor with CloudWatch Synthetics
- `email_endpoints`: List of email addresses to receive notifications

### Optional Variables

- `aws_region`: AWS region to deploy resources (default: "us-east-1")

## Monitoring Details

- The canary runs every 5 minutes
- Alerts are triggered when the success rate falls below 90% for 2 consecutive evaluation periods
- Both successful and failed checks are reported via email

## Clean Up

To remove all created resources:

```bash
terraform destroy
```

## Notes

- Make sure to confirm the SNS email subscription when you receive the confirmation email
- The canary script checks for HTTP status codes in the 200-299 range
- All resources are tagged for easy identification and management
- S3 bucket for canary artifacts has versioning enabled
- IAM roles are configured with least privilege access

## Troubleshooting

1. **Email Notifications Not Received**
   - Check if you confirmed the SNS subscription
   - Verify the email address in terraform.tfvars

2. **Canary Failures**
   - Check CloudWatch Logs for detailed error messages
   - Verify the URL is accessible from AWS
   - Review the canary timeout settings if needed

## Security Considerations

- All S3 buckets are private by default
- IAM roles follow least privilege principle
- Sensitive data should be managed through AWS Secrets Manager (not included)