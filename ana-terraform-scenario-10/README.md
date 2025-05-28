# Automated SRE Response System

This Terraform project sets up an automated SRE response system in AWS that monitors EC2 instances for high CPU usage and automatically performs remediation actions.

## Architecture

The system consists of the following components:

1. CloudWatch Alarms monitoring:
   - EC2 CPU utilization
   - Instance status checks
2. Lambda function for automated remediation
3. SNS topic for notifications
4. IAM roles and policies for secure execution

## Prerequisites

- Terraform installed (v0.12 or later)
- AWS credentials configured
- An EC2 instance to monitor

## Setup Instructions

1. Clone this repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values:
   ```hcl
   aws_region = "ap-south-1"
   instance_id = "your-instance-id"
   notification_emails = ["your-email@domain.com"]
   cpu_threshold = 80
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Monitoring Configuration

### CloudWatch Alarms

1. CPU Utilization Alarm:
   - Triggers when CPU > threshold for 2 consecutive 5-minute periods
   - Missing data is treated as breaching (treat_missing_data = "breaching")
   - Requires 2 datapoints to trigger alarm (datapoints_to_alarm = 2)
   - Sends notifications for insufficient data

2. Instance Status Check Alarm:
   - Monitors EC2 status checks every minute
   - Triggers when status check fails
   - Missing data is treated as breaching
   - Sends notifications for insufficient data

## Remediation Workflow

1. CloudWatch monitors EC2 metrics
2. When thresholds are exceeded:
   - CloudWatch Alarm triggers
   - Lambda function is invoked
   - Lambda reboots the EC2 instance
   - SNS notification is sent to the SRE team
3. The Lambda function logs all actions to CloudWatch Logs

## Verification

You can verify the system is working by:
1. Checking CloudWatch Alarms
2. Reviewing Lambda execution logs
3. Confirming email notifications are received
4. Monitoring EC2 instance state changes

## Clean Up

To remove all resources:
```bash
terraform destroy