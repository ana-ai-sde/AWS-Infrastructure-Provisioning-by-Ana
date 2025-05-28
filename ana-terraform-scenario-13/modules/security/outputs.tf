# WAF Outputs
    output "waf_web_acl_arn" {
        description = "ARN of the WAF Web ACL"
        value       = aws_wafv2_web_acl.main.arn
    }

    output "waf_web_acl_id" {
        description = "ID of the WAF Web ACL"
        value       = aws_wafv2_web_acl.main.id
    }

    # VPC Flow Logs Outputs
    output "vpc_flow_log_group_name" {
        description = "Name of the CloudWatch Log Group for VPC Flow Logs"
        value       = aws_cloudwatch_log_group.vpc_flow_logs.name
    }

    output "vpc_flow_log_id" {
        description = "ID of the VPC Flow Log"
        value       = aws_flow_log.main.id
    }

    output "flow_logs_role_arn" {
        description = "ARN of the IAM role used by VPC Flow Logs"
        value       = aws_iam_role.flow_logs.arn
    }

    # GuardDuty Outputs
    output "guardduty_detector_id" {
        description = "ID of the GuardDuty detector"
        value       = aws_guardduty_detector.main.id
    }

    # Security Hub Outputs
    output "securityhub_arn" {
        description = "ARN of the Security Hub account"
        value       = aws_securityhub_account.main.id
    }