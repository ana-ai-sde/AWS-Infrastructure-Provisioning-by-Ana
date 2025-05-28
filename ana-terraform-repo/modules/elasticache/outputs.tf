output "endpoint" {
  description = "The address of the endpoint for the primary node in the replication group"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint" {
  description = "The address of the endpoint for the reader node in the replication group"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "The port number on which the cache accepts connections"
  value       = aws_elasticache_replication_group.this.port
}

output "replication_group_id" {
  description = "The ID of the ElastiCache Replication Group"
  value       = aws_elasticache_replication_group.this.id
}

output "member_clusters" {
  description = "The identifiers of all the nodes that are part of this replication group"
  value       = aws_elasticache_replication_group.this.member_clusters
}