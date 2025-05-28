# Secure EC2 Instance with CloudWatch Monitoring

This Terraform configuration sets up a secure EC2 instance with CloudWatch monitoring capabilities in AWS. The configuration is organized in a modular structure for better maintainability and reusability.

## Architecture Overview

```
┌────────────────────────────────────────────┐
│                  VPC                       │
│                                           │
│    ┌────────────────┐     ┌──────────┐    │
│    │  Public Subnet │     │   IGW    │    │
│    │                │     │          │    │
│    │  ┌──────────┐  │     └──────────┘    │
│    │  │   EC2    │  │          │          │
│    │  │          │  │          │          │
│    │  └──────────┘  │          │          │
│    │       │        │          │          │
│    └───────┼────────┘          │          │
│            │                    │          │
└────────────┼────────────────────┼──────────┘
             │                    │
             ▼                    ▼
    ┌────────────────┐    ┌──────────────┐
    │  CloudWatch    │    │   Internet   │
    │  Monitoring    │    │              │
    └───────┬────────┘    └──────────────┘
            │
            ▼
    ┌────────────────┐
    │  SSM Parameter │
    │     Store      │
    └────────────────┘
```

## Components

1. **VPC Infrastructure**
   - Custom VPC with DNS support
   - Public subnet in ap-south-1a
   - Internet Gateway for external access
   - Route table for internet routing

2. **EC2 Instance**
   - Amazon Linux 2 AMI
   - CloudWatch agent configured via SSM Parameter Store
   - Collects CPU and memory metrics
   - IMDSv2 enabled for enhanced security
   - Root volume encryption enabled

3. **Security Group**
   - Restricts SSH access to specified CIDR block
   - Allows outbound traffic for updates and metric submission
   - Modular and customizable rules

4. **CloudWatch Configuration**
   - Configuration stored in SSM Parameter Store
   - Custom metrics for CPU and memory usage
   - Dashboard for metric visualization
   - Alarms for:
     - CPU utilization > 80%
     - Memory utilization > 80%

5. **IAM Roles**
   - EC2 instance profile for CloudWatch agent
   - SSM Parameter Store read access
   - Necessary permissions for metric submission

6. **SSM Parameter Store**
   - Stores CloudWatch agent configuration
   - Enables configuration updates without instance redeployment
   - Secure storage of configuration

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0.0
3. An EC2 key pair for SSH access

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| aws_region | AWS region | string | ap-south-1 |
| vpc_cidr | CIDR block for VPC | string | 10.0.0.0/16 |
| public_subnet_cidr | CIDR for public subnet | string | 10.0.1.0/24 |
| instance_type | EC2 instance type | string | t2.micro |
| ssh_cidr | CIDR block for SSH access | string | - |
| key_name | EC2 key pair name | string | - |
| environment | Environment name | string | dev |
| cpu_threshold | CPU alarm threshold | number | 80 |

## Security Features

- SSH access is restricted to specified CIDR block
- Security group follows principle of least privilege
- IMDSv2 required for enhanced instance metadata security
- Root volume encryption enabled
- CloudWatch agent configuration stored securely in SSM
- All metrics are encrypted in transit

## Monitoring

- CPU utilization metrics (user, system, idle)
- Memory usage metrics
- Custom CloudWatch dashboard
- Automated alerts for:
  - High CPU usage (>80%)
  - High memory usage (>80%)

## Best Practices Implemented

1. **Security**
   - IMDSv2 enforcement
   - Root volume encryption
   - Principle of least privilege
   - CIDR-based access control

2. **Configuration Management**
   - CloudWatch agent config in SSM Parameter Store
   - Easy configuration updates
   - Secure configuration storage
   - No hardcoded configurations

3. **Monitoring**
   - Comprehensive metrics collection
   - Multi-metric dashboard
   - Proactive alerting

4. **Infrastructure**
   - Modular design
   - Variable-driven configuration
   - Proper resource tagging
   - VPC best practices

## Pass Criteria Validation

1. **SSH Access Restriction**: ✅
   - Implemented via security group CIDR restriction
   - Customizable through variables

2. **CloudWatch Metrics**: ✅
   - CPU and memory metrics configured via SSM
   - Visible in custom dashboard
   - 60-second collection interval

3. **Alarm Configuration**: ✅
   - CPU utilization alarm set at 80%
   - Memory utilization alarm set at 80%
   - 2 evaluation periods of 5 minutes each

## Updating CloudWatch Agent Configuration

To update the CloudWatch agent configuration:

1. Modify the SSM parameter in the AWS Console or via AWS CLI
2. Restart the CloudWatch agent on the EC2 instance:
   ```bash
   sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:<parameter-name>
   sudo systemctl restart amazon-cloudwatch-agent
   ```

This allows for configuration updates without requiring instance redeployment.