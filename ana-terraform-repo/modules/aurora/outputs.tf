output "cluster_id" {
  description = "The ID of the Aurora cluster"
  value       = aws_rds_cluster.aurora.id
}

output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = aws_rds_cluster.aurora.endpoint
}

output "cluster_reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "cluster_port" {
  description = "The port the cluster is listening on"
  value       = aws_rds_cluster.aurora.port
}

output "database_name" {
  description = "Name of the default database"
  value       = aws_rds_cluster.aurora.database_name
}

output "master_username" {
  description = "Master username for the cluster"
  value       = aws_rds_cluster.aurora.master_username
}

output "cluster_instances" {
  description = "List of cluster instance IDs"
  value       = aws_rds_cluster_instance.aurora[*].id
}

output "security_group_id" {
  description = "ID of the Aurora security group"
  value       = aws_security_group.aurora.id
}

output "subnet_group_name" {
  description = "Name of the Aurora subnet group"
  value       = aws_db_subnet_group.aurora.name
}

output "parameter_group_name" {
  description = "Name of the Aurora cluster parameter group"
  value       = aws_rds_cluster_parameter_group.aurora.name
}

output "db_parameter_group_name" {
  description = "Name of the Aurora DB parameter group"
  value       = aws_db_parameter_group.aurora.name
}