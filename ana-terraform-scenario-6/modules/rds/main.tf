locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  default_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  )

  monitoring_role_name = coalesce(
    var.monitoring_config.monitoring_role_name,
    "${local.name_prefix}-rds-monitoring-role"
  )
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "${local.name_prefix}-subnet-group"
  description = "Subnet group for ${local.name_prefix} RDS instance"
  subnet_ids  = var.subnet_ids

  tags = local.default_tags
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  name        = "${local.name_prefix}-parameter-group"
  family      = var.db_config.parameter_group_family
  description = "Parameter group for ${local.name_prefix} RDS instance"

  dynamic "parameter" {
    for_each = var.parameter_group_config
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = local.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

# Enhanced Monitoring IAM Role
resource "aws_iam_role" "monitoring" {
  count = var.monitoring_config.create_monitoring_role ? 1 : 0

  name = local.monitoring_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  count = var.monitoring_config.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-db"

  # Engine settings
  engine                = var.db_config.engine
  engine_version       = var.db_config.engine_version
  instance_class       = var.db_config.instance_class

  # Storage settings
  allocated_storage      = var.db_config.allocated_storage
  max_allocated_storage  = var.db_config.max_allocated_storage
  storage_type           = var.db_config.storage_type
  storage_encrypted      = var.db_config.storage_encrypted
  kms_key_id            = var.db_config.kms_key_id

  # Network settings
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  multi_az              = var.multi_az_config.multi_az
  availability_zone     = var.multi_az_config.availability_zone
  port                  = var.db_config.port

  # Database settings
  db_name  = var.db_config.db_name
  username = var.db_config.username
  password = random_password.db_password.result

  # Parameter group
  parameter_group_name = aws_db_parameter_group.main.name

  # Backup settings
  backup_retention_period = var.backup_config.backup_retention_period
  backup_window          = var.backup_config.backup_window
  maintenance_window     = var.backup_config.maintenance_window
  skip_final_snapshot    = var.backup_config.skip_final_snapshot
  deletion_protection    = var.backup_config.deletion_protection
  copy_tags_to_snapshot  = var.backup_config.copy_tags_to_snapshot

  # Monitoring settings
  monitoring_interval = var.monitoring_config.enhanced_monitoring_interval
  monitoring_role_arn = var.monitoring_config.create_monitoring_role ? aws_iam_role.monitoring[0].arn : null

  # Performance Insights
  performance_insights_enabled    = var.performance_insights_config.enabled
  performance_insights_retention_period = var.performance_insights_config.retention_period
  performance_insights_kms_key_id      = var.performance_insights_config.kms_key_id

  # Other settings
  auto_minor_version_upgrade = var.multi_az_config.auto_minor_version_upgrade
  ca_cert_identifier        = var.multi_az_config.ca_cert_identifier

  tags = local.default_tags
}

# Generate random password for RDS
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name        = "${local.name_prefix}-db-password"
  description = "Password for RDS instance ${local.name_prefix}"
  tags        = local.default_tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_config.username
    password = random_password.db_password.result
    host     = aws_db_instance.main.endpoint
    port     = var.db_config.port
    dbname   = var.db_config.db_name
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = var.monitoring_config.alarm_config

  alarm_name          = "${local.name_prefix}-${each.key}"
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = "AWS/RDS"
  period              = each.value.period
  statistic           = "Average"
  threshold           = each.value.threshold
  alarm_description   = "RDS ${each.key} alarm for ${local.name_prefix}"
  alarm_actions       = each.value.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = local.default_tags
}