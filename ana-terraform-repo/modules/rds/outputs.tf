output "endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.this.endpoint
}

output "arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "port" {
  description = "The database port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "The master username for the database"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "monitoring_role_arn" {
  description = "The ARN of the monitoring role"
  value       = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null
}

output "monitoring_role_name" {
  description = "The name of the monitoring role"
  value       = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].name : null
}