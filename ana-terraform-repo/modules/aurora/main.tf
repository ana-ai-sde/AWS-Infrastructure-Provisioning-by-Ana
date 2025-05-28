# Security Group for Aurora
resource "aws_security_group" "aurora" {
  name_prefix = "${var.name_prefix}-aurora-sg"
  description = "Security group for Aurora cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "PostgreSQL access from VPC"
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
      Name        = "${var.name_prefix}-aurora-sg"
      Environment = var.environment
    },
    var.tags
  )
}

# Aurora Subnet Group
resource "aws_db_subnet_group" "aurora" {
  name        = "${var.name_prefix}-subnet-group"
  description = "Subnet group for Aurora cluster"
  subnet_ids  = var.subnet_ids

  tags = merge(
    {
      Name        = "${var.name_prefix}-subnet-group"
      Environment = var.environment
    },
    var.tags
  )
}

# Aurora Parameter Group
resource "aws_rds_cluster_parameter_group" "aurora" {
  family      = var.engine == "aurora-postgresql" ? "aurora-postgresql15" : "aurora-mysql8.0"
  name        = "${var.name_prefix}-cluster-parameter-group"
  description = "Aurora cluster parameter group"

  tags = merge(
    {
      Name        = "${var.name_prefix}-cluster-parameter-group"
      Environment = var.environment
    },
    var.tags
  )
}

# Aurora DB Parameter Group
resource "aws_db_parameter_group" "aurora" {
  family = var.engine == "aurora-postgresql" ? "aurora-postgresql15" : "aurora-mysql8.0"
  name   = "${var.name_prefix}-db-parameter-group"
  description = "Aurora DB parameter group"

  tags = merge(
    {
      Name        = "${var.name_prefix}-db-parameter-group"
      Environment = var.environment
    },
    var.tags
  )
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "${var.name_prefix}-cluster"
  engine            = var.engine
  engine_version    = var.engine_version
  
  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password

  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  vpc_security_group_ids         = [aws_security_group.aurora.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window     = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection
  apply_immediately     = var.apply_immediately
  storage_encrypted     = true

  enabled_cloudwatch_logs_exports = var.engine == "aurora-postgresql" ? ["postgresql"] : ["audit", "error", "general", "slowquery"]

  tags = merge(
    {
      Name        = "${var.name_prefix}-cluster"
      Environment = var.environment
    },
    var.tags
  )
}

# Aurora Cluster Instances
resource "aws_rds_cluster_instance" "aurora" {
  count = 1 + var.replica_count

  identifier         = "${var.name_prefix}-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.instance_class
  engine            = aws_rds_cluster.aurora.engine
  engine_version    = aws_rds_cluster.aurora.engine_version

  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  db_parameter_group_name = aws_db_parameter_group.aurora.name

  auto_minor_version_upgrade = true
  apply_immediately         = var.apply_immediately

  # First instance is writer, rest are readers
  promotion_tier = count.index

  tags = merge(
    {
      Name        = "${var.name_prefix}-instance-${count.index + 1}"
      Environment = var.environment
      Role        = count.index == 0 ? "writer" : "reader"
    },
    var.tags
  )
}