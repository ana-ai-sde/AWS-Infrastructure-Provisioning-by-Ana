# VPC Outputs
    output "vpc_id" {
        description = "ID of the VPC"
        value       = module.vpc.vpc_id
    }

    output "private_subnet_ids" {
        description = "IDs of private subnets"
        value       = module.vpc.private_subnet_ids
    }

    output "vpc_cidr" {
        description = "CIDR block of the VPC"
        value       = module.vpc.vpc_cidr
    }

    # Security Outputs
    output "waf_web_acl_arn" {
        description = "ARN of the WAF Web ACL"
        value       = module.security.waf_web_acl_arn
    }

    output "waf_web_acl_id" {
        description = "ID of the WAF Web ACL"
        value       = module.security.waf_web_acl_id
    }

    output "vpc_flow_log_group_name" {
        description = "Name of the CloudWatch Log Group for VPC Flow Logs"
        value       = module.security.vpc_flow_log_group_name
    }

    output "vpc_flow_log_id" {
        description = "ID of the VPC Flow Log"
        value       = module.security.vpc_flow_log_id
    }

    output "guardduty_detector_id" {
        description = "ID of the GuardDuty detector"
        value       = module.security.guardduty_detector_id
    }

    output "securityhub_arn" {
        description = "ARN of the Security Hub account"
        value       = module.security.securityhub_arn
    }

    # IAM Outputs
    output "permission_boundary_arn" {
        description = "ARN of the permission boundary policy"
        value       = module.iam.permission_boundary_arn
    }

    output "ec2_role_arn" {
        description = "ARN of the EC2 IAM role"
        value       = module.iam.ec2_role_arn
    }