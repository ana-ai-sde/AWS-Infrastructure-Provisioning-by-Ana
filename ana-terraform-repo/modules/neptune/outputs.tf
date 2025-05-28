output "cluster_id" {
  description = "The ID of the Neptune cluster"
  value       = aws_neptune_cluster.this.id
}

output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = aws_neptune_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "The cluster reader endpoint"
  value       = aws_neptune_cluster.this.reader_endpoint
}

output "cluster_port" {
  description = "The port the cluster is listening on"
  value       = aws_neptune_cluster.this.port
}

output "cluster_instances" {
  description = "List of cluster instance IDs"
  value       = aws_neptune_cluster_instance.this[*].id
}

output "security_group_id" {
  description = "ID of the Neptune security group"
  value       = aws_security_group.neptune.id
}

output "subnet_group_name" {
  description = "Name of the Neptune subnet group"
  value       = aws_neptune_subnet_group.this.name
}

output "parameter_group_name" {
  description = "Name of the Neptune parameter group"
  value       = aws_neptune_parameter_group.this.name
}