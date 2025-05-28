output "cloudwatch_config_parameter_name" {
  description = "Name of the SSM parameter storing CloudWatch agent configuration"
  value       = aws_ssm_parameter.cloudwatch_config.name
}