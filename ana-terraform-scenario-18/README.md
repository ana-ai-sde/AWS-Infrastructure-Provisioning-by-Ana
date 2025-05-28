# Multi-Region High-Availability VPN Mesh with AWS Transit Gateway

This Terraform configuration sets up a multi-region, high-availability VPN mesh using AWS Transit Gateway and StrongSwan Customer Gateways. The setup includes automated failover capabilities using Lambda functions and CloudWatch monitoring, with full redundancy in both primary (Mumbai) and secondary (Hyderabad) regions.

## Module Structure

The configuration is organized into the following modules:

1. `vpc` - VPC and networking resources
   - VPC creation
   - Subnet configuration
   - Internet Gateway
   - Route tables

2. `transit_gateway` - Transit Gateway resources
   - Transit Gateway creation
   - VPC attachments
   - Cross-region peering

3. `vpn` - VPN connection resources
   - Customer Gateway configuration
   - VPN connection setup
   - BGP routing configuration

4. `strongswan` - StrongSwan EC2 instances
   - EC2 instance deployment
   - Security group configuration
   - User data template for StrongSwan setup

5. `monitoring` - Monitoring and automation
   - CloudWatch alarms
   - Lambda functions
   - IAM roles and policies

## Architecture Overview

### Primary Region (Mumbai - ap-south-1)
- Transit Gateway
- Two StrongSwan EC2 instances as Customer Gateways
- VPN connections with BGP routing
- Lambda function for failover automation
- CloudWatch alarms for monitoring

### Secondary Region (Hyderabad - ap-south-2)
- Transit Gateway
- Two StrongSwan EC2 instances as Customer Gateways
- VPN connections with BGP routing
- Lambda function for failover automation
- CloudWatch alarms for monitoring

### Cross-Region Connectivity
- Transit Gateway peering between regions
- Automated route propagation
- Cross-region failover capability

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform v1.2.0 or later
3. Node.js 18.x (for Lambda function development)

## Deployment Instructions

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Create Lambda deployment package:
   ```bash
   cd lambda
   npm install
   zip -r vpn_failover.zip index.js node_modules/
   cd ..
   ```

3. Review and apply the Terraform configuration:
   ```bash
   terraform plan
   terraform apply
   ```

## Testing Failover

1. Monitor the VPN connections in both regions:
   ```bash
   # Primary Region (Mumbai)
   aws ec2 describe-vpn-connections --region ap-south-1
   
   # Secondary Region (Hyderabad)
   aws ec2 describe-vpn-connections --region ap-south-2
   ```

2. Simulate a tunnel failure:
   ```bash
   # Primary Region - Disable the primary VPN tunnel
   ssh ubuntu@<primary_strongswan_1_public_ip> "sudo ipsec down AWS-VPN-1"
   
   # Secondary Region - Disable the primary VPN tunnel
   ssh ubuntu@<secondary_strongswan_1_public_ip> "sudo ipsec down AWS-VPN-1"
   ```

3. Monitor failover:
   - Check CloudWatch metrics for tunnel status in both regions
   - Verify Lambda function execution in CloudWatch Logs
   - Confirm traffic routing through secondary tunnels
   - Verify cross-region communication via Transit Gateway peering

## Validation

The system should:
- Detect tunnel failure within 60 seconds in both regions
- Trigger Lambda functions via CloudWatch alarms
- Update TGW route tables automatically
- Redirect traffic to secondary tunnels
- Maintain cross-region connectivity via TGW peering
- Log all events in CloudWatch Logs

## Cleanup

To destroy all created resources:
```bash
terraform destroy
```

## Monitoring and Metrics

Access the following in AWS Console for both regions:
1. CloudWatch Metrics:
   - VPN tunnel status
   - BGP route propagation
   - Network throughput
   - Transit Gateway peering status

2. CloudWatch Logs:
   - Lambda function execution logs
   - VPN connection events
   - Failover actions
   - Cross-region routing events

## Security Considerations

- All VPN tunnels use BGP for dynamic routing
- IPSec security associations are automatically rotated
- Dead Peer Detection (DPD) is enabled for quick failure detection
- Lambda functions use least-privilege IAM roles
- Cross-region traffic is encrypted via Transit Gateway peering
- Separate BGP ASNs for each region to prevent routing conflicts

## Module Configuration

Each module can be configured independently through variables:

1. VPC Module:
   - CIDR blocks
   - Availability zones
   - Subnet configuration

2. Transit Gateway Module:
   - BGP ASN
   - Peering configuration
   - Route table settings

3. VPN Module:
   - Customer Gateway settings
   - Tunnel configuration
   - BGP routing parameters

4. StrongSwan Module:
   - Instance type
   - Security group rules
   - VPN configuration

5. Monitoring Module:
   - Alarm thresholds
   - Lambda settings
   - Log retention