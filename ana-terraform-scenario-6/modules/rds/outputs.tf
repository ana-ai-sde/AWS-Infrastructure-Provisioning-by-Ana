output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "Connection endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "db_subnet_group_id" {
  description = "ID of DB subnet group"
  value       = aws_db_subnet_group.main.id
}

output "db_parameter_group_id" {
  description = "ID of DB parameter group"
  value       = aws_db_parameter_group.main.id
}

output "monitoring_role_arn" {
  description = "ARN of the monitoring IAM role"
  value       = var.monitoring_config.create_monitoring_role ? aws_iam_role.monitoring[0].arn : null
}

output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarms created for the RDS instance"
  value       = aws_cloudwatch_metric_alarm.alarms
}