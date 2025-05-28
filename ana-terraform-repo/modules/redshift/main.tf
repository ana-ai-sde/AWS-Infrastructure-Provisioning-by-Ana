# Security Group for Redshift
resource "aws_security_group" "redshift" {
  name_prefix = "${var.name_prefix}-redshift-sg"
  description = "Security group for Redshift cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Redshift access from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    {
      Name        = "${var.name_prefix}-redshift-sg"
      Environment = var.environment
    },
    var.tags
  )
}

# Redshift Subnet Group
resource "aws_redshift_subnet_group" "this" {
  name        = "${var.name_prefix}-subnet-group"
  description = "Subnet group for Redshift cluster"
  subnet_ids  = var.subnet_ids

  tags = merge(
    {
      Name        = "${var.name_prefix}-subnet-group"
      Environment = var.environment
    },
    var.tags
  )
}

# Redshift Parameter Group
resource "aws_redshift_parameter_group" "this" {
  name        = "${var.name_prefix}-parameter-group"
  description = "Parameter group for Redshift cluster"
  family      = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }

  parameter {
    name  = "max_concurrency_scaling_clusters"
    value = "1"
  }

  tags = merge(
    {
      Name        = "${var.name_prefix}-parameter-group"
      Environment = var.environment
    },
    var.tags
  )
}

# IAM Role for Redshift
resource "aws_iam_role" "redshift" {
  name = "${var.name_prefix}-redshift-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name        = "${var.name_prefix}-redshift-role"
      Environment = var.environment
    },
    var.tags
  )
}

# IAM Policy for Redshift
resource "aws_iam_role_policy" "redshift" {
  name = "${var.name_prefix}-redshift-policy"
  role = aws_iam_role.redshift.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

# Redshift Cluster
resource "aws_redshift_cluster" "this" {
  cluster_identifier = "${var.name_prefix}-cluster"
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = var.master_password
  node_type         = var.node_type
  cluster_type      = var.cluster_type
  number_of_nodes   = var.cluster_type == "single-node" ? 1 : var.number_of_nodes

  # Network Configuration
  cluster_subnet_group_name = aws_redshift_subnet_group.this.name
  vpc_security_group_ids    = [aws_security_group.redshift.id]
  publicly_accessible       = var.publicly_accessible
  port                     = var.port
  elastic_ip               = var.publicly_accessible ? var.elastic_ip : null

  # Parameter and IAM Configuration
  cluster_parameter_group_name = aws_redshift_parameter_group.this.name
  iam_roles                   = [aws_iam_role.redshift.arn]

  # Backup Configuration
  automated_snapshot_retention_period = var.automated_snapshot_retention_period
  preferred_maintenance_window       = var.preferred_maintenance_window
  skip_final_snapshot               = var.skip_final_snapshot
  final_snapshot_identifier         = var.skip_final_snapshot ? null : (
    var.final_snapshot_identifier != null ? var.final_snapshot_identifier : "${var.name_prefix}-final-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  )

  # Security Configuration
  encrypted  = var.encrypted
  kms_key_id = var.kms_key_id

  # Version Management
  allow_version_upgrade = var.allow_version_upgrade

  tags = merge(
    {
      Name        = "${var.name_prefix}-cluster"
      Environment = var.environment
    },
    var.tags
  )

  lifecycle {
    prevent_destroy = false
  }
}


