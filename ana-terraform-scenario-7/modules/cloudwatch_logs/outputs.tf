output "application_log_group_name" {
  description = "Name of the application log group"
  value       = aws_cloudwatch_log_group.application_logs.name
}

output "system_log_group_name" {
  description = "Name of the system log group"
  value       = aws_cloudwatch_log_group.system_logs.name
}