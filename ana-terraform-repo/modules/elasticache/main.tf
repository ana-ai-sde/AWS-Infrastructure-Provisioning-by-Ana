# Create subnet group for ElastiCache
resource "aws_elasticache_subnet_group" "this" {
  name        = "${var.environment}-${var.name}-subnet-group"
  description = "Subnet group for ${var.name} ElastiCache"
  subnet_ids  = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name}-subnet-group"
      Environment = var.environment
    }
  )
}

# Create parameter group for Redis
resource "aws_elasticache_parameter_group" "this" {
  family = var.parameter_group_family
  name   = "${var.environment}-${var.name}-params"

  description = "Parameter group for ${var.name} ElastiCache Redis"

  # Common Redis parameters
  parameter {
    name  = "maxmemory-policy"
    value = var.maxmemory_policy
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name}-params"
      Environment = var.environment
    }
  )
}

# Create Redis replication group
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.environment}-${var.name}"
  description         = "${var.environment} ${var.name} Redis cluster"

  node_type = var.node_type
  port      = var.port

  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.num_cache_clusters > 1 ? true : false

  subnet_group_name          = aws_elasticache_subnet_group.this.name
  security_group_ids         = var.security_group_ids
  parameter_group_name       = aws_elasticache_parameter_group.this.name
  
  engine               = "redis"
  engine_version      = var.engine_version
  maintenance_window  = var.maintenance_window
  snapshot_window    = var.snapshot_window
  snapshot_retention_limit = var.snapshot_retention_limit

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  apply_immediately = var.apply_immediately

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-${var.name}"
      Environment = var.environment
    }
  )

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      engine_version
    ]
  }
}




