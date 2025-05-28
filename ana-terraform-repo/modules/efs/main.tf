# Create security group for EFS
resource "aws_security_group" "efs" {
  name        = "efs-security-group"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow NFS traffic from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  tags = merge(
    {
      Name = "efs-security-group"
    },
    var.tags
  )
}

# Get VPC information
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Create EFS File System
resource "aws_efs_file_system" "this" {
  creation_token                  = var.creation_token
  performance_mode               = var.performance_mode
  throughput_mode                = var.throughput_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  encrypted                      = var.encrypted
  kms_key_id                    = var.kms_key_id

  tags = merge(
    {
      Name = var.creation_token
    },
    var.tags
  )

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

# Create mount targets in each subnet
resource "aws_efs_mount_target" "this" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

# Create backup policy
resource "aws_efs_backup_policy" "this" {
  file_system_id = aws_efs_file_system.this.id

  backup_policy {
    status = "ENABLED"
  }
}