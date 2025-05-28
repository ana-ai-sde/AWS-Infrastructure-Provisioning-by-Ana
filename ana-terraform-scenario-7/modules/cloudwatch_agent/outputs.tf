output "agent_role_arn" {
  description = "ARN of the CloudWatch Agent IAM role"
  value       = aws_iam_role.cloudwatch_agent_role.arn
}

output "agent_profile_name" {
  description = "Name of the CloudWatch Agent instance profile"
  value       = aws_iam_instance_profile.cloudwatch_agent_profile.name
}

output "agent_config_parameter" {
  description = "SSM Parameter name for the CloudWatch Agent configuration"
  value       = aws_ssm_parameter.cloudwatch_agent_config.name
}