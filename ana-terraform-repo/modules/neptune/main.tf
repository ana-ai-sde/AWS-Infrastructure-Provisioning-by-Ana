# Security Group for Neptune
resource "aws_security_group" "neptune" {
  name_prefix = "${var.name_prefix}-neptune-sg"
  description = "Security group for Neptune cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.neptune_port
    to_port     = var.neptune_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name        = "${var.name_prefix}-neptune-sg"
      Environment = var.environment
    },
    var.tags
  )
}

# Neptune Subnet Group
resource "aws_neptune_subnet_group" "this" {
  name        = "${var.name_prefix}-subnet-group"
  description = "Neptune subnet group"
  subnet_ids  = var.subnet_ids

  tags = merge(
    {
      Name        = "${var.name_prefix}-subnet-group"
      Environment = var.environment
    },
    var.tags
  )
}

# Neptune Parameter Group
resource "aws_neptune_parameter_group" "this" {
  family      = var.neptune_parameter_group_family
  name        = "${var.name_prefix}-parameter-group"
  description = "Neptune parameter group"

  tags = merge(
    {
      Name        = "${var.name_prefix}-parameter-group"
      Environment = var.environment
    },
    var.tags
  )
}

# Neptune Cluster
resource "aws_neptune_cluster" "this" {
  cluster_identifier                  = "${var.name_prefix}-cluster"
  engine                             = "neptune"
  neptune_subnet_group_name          = aws_neptune_subnet_group.this.name
  vpc_security_group_ids             = [aws_security_group.neptune.id]
  neptune_cluster_parameter_group_name = aws_neptune_parameter_group.this.name
  port                               = var.neptune_port
  backup_retention_period            = var.backup_retention_period
  preferred_backup_window            = var.preferred_backup_window
  skip_final_snapshot                = var.skip_final_snapshot
  final_snapshot_identifier          = var.skip_final_snapshot ? null : (
    var.final_snapshot_identifier != null ? var.final_snapshot_identifier : "${var.name_prefix}-final-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  )
  apply_immediately                  = var.apply_immediately

  tags = merge(
    {
      Name        = "${var.name_prefix}-cluster"
      Environment = var.environment
    },
    var.tags
  )
}

# Neptune Cluster Instances
resource "aws_neptune_cluster_instance" "this" {
  count                = var.neptune_cluster_size
  cluster_identifier   = aws_neptune_cluster.this.id
  engine              = "neptune"
  instance_class      = var.instance_class
  identifier          = "${var.name_prefix}-instance-${count.index + 1}"
  neptune_subnet_group_name = aws_neptune_subnet_group.this.name
  apply_immediately   = var.apply_immediately

  tags = merge(
    {
      Name        = "${var.name_prefix}-instance-${count.index + 1}"
      Environment = var.environment
    },
    var.tags
  )
}




