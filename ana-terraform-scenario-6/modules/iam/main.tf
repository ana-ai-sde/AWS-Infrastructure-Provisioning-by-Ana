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
}

# EC2 Instance Role and Profile
resource "aws_iam_role" "ec2" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.default_tags
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = local.default_tags
}

# SSM Policy
resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.ec2_role_config.enable_ssm ? 1 : 0

  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch Policy
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.ec2_role_config.enable_cloudwatch ? 1 : 0

  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Custom EC2 Policies
resource "aws_iam_role_policy" "ec2_custom" {
  for_each = var.ec2_role_config.custom_policies

  name = "${local.name_prefix}-ec2-${each.key}"
  role = aws_iam_role.ec2.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = each.value.effect
        Action    = each.value.actions
        Resource  = each.value.resources
      }
    ]
  })
}

# Backup Role
resource "aws_iam_role" "backup" {
  count = var.backup_role_config.enabled ? 1 : 0

  name = "${local.name_prefix}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = local.default_tags
}

resource "aws_iam_role_policy" "backup" {
  count = var.backup_role_config.enabled ? 1 : 0

  name = "${local.name_prefix}-backup-policy"
  role = aws_iam_role.backup[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "backup:StartBackupJob",
          "backup:StopBackupJob",
          "backup:StartRestoreJob"
        ]
        Resource = concat(
          var.backup_role_config.backup_resources,
          var.backup_role_config.restore_resources
        )
      }
    ]
  })
}