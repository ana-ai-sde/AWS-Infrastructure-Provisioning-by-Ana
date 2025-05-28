output "cluster_id" {
  description = "The ID of the Redshift cluster"
  value       = aws_redshift_cluster.this.id
}

output "cluster_identifier" {
  description = "The Cluster Identifier"
  value       = aws_redshift_cluster.this.cluster_identifier
}

output "cluster_endpoint" {
  description = "The connection endpoint"
  value       = aws_redshift_cluster.this.endpoint
}

output "cluster_port" {
  description = "The port the cluster responds on"
  value       = aws_redshift_cluster.this.port
}

output "database_name" {
  description = "The name of the default database"
  value       = aws_redshift_cluster.this.database_name
}

output "master_username" {
  description = "The master username for the cluster"
  value       = aws_redshift_cluster.this.master_username
}

output "security_group_id" {
  description = "The ID of the security group for the Redshift cluster"
  value       = aws_security_group.redshift.id
}

output "subnet_group_name" {
  description = "The name of the Redshift subnet group"
  value       = aws_redshift_subnet_group.this.name
}

output "parameter_group_name" {
  description = "The name of the Redshift parameter group"
  value       = aws_redshift_parameter_group.this.name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role for Redshift"
  value       = aws_iam_role.redshift.arn
}

output "cluster_nodes" {
  description = "The nodes in the cluster"
  value       = aws_redshift_cluster.this.cluster_nodes
}

output "cluster_public_key" {
  description = "The public key for the cluster"
  value       = aws_redshift_cluster.this.cluster_public_key
}

output "cluster_revision_number" {
  description = "The specific revision number of the database"
  value       = aws_redshift_cluster.this.cluster_revision_number
}

output "vpc_security_group_ids" {
  description = "The VPC security group ids associated with the cluster"
  value       = aws_redshift_cluster.this.vpc_security_group_ids
}