variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., prod, dev, staging)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS instance"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the RDS instance"
  type        = list(string)
}

variable "db_config" {
  description = "Database configuration settings"
  type = object({
    engine                  = string
    engine_version         = string
    instance_class         = string
    allocated_storage      = number
    max_allocated_storage  = number
    storage_type           = string
    storage_encrypted      = bool
    kms_key_id            = optional(string)
    username              = string
    port                  = number
    db_name               = string
    parameter_group_family = string
  })
}

variable "multi_az_config" {
  description = "Multi-AZ configuration settings"
  type = object({
    multi_az                = bool
    availability_zone       = optional(string)
    ca_cert_identifier     = optional(string)
    auto_minor_version_upgrade = bool
  })
  default = {
    multi_az                = true
    availability_zone       = null
    ca_cert_identifier     = "rds-ca-2019"
    auto_minor_version_upgrade = true
  }
}

variable "backup_config" {
  description = "Backup configuration settings"
  type = object({
    backup_retention_period = number
    backup_window          = string
    maintenance_window     = string
    skip_final_snapshot    = bool
    deletion_protection    = bool
    copy_tags_to_snapshot  = bool
  })
  default = {
    backup_retention_period = 7
    backup_window          = "03:00-04:00"
    maintenance_window     = "Mon:04:00-Mon:05:00"
    skip_final_snapshot    = false
    deletion_protection    = true
    copy_tags_to_snapshot  = true
  }
}

variable "performance_insights_config" {
  description = "Performance Insights configuration"
  type = object({
    enabled                = bool
    retention_period      = number
    kms_key_id           = optional(string)
  })
  default = {
    enabled           = true
    retention_period = 7
    kms_key_id      = null
  }
}

variable "monitoring_config" {
  description = "Enhanced monitoring and CloudWatch configuration"
  type = object({
    enhanced_monitoring_interval = number
    create_monitoring_role      = bool
    monitoring_role_name       = optional(string)
    alarm_config = map(object({
      metric_name         = string
      comparison_operator = string
      threshold          = number
      period             = number
      evaluation_periods = number
      alarm_actions      = list(string)
    }))
  })
  default = {
    enhanced_monitoring_interval = 60
    create_monitoring_role      = true
    monitoring_role_name       = null
    alarm_config = {
      high_cpu = {
        metric_name         = "CPUUtilization"
        comparison_operator = "GreaterThanThreshold"
        threshold          = 80
        period             = 300
        evaluation_periods = 2
        alarm_actions      = []
      }
      low_storage = {
        metric_name         = "FreeStorageSpace"
        comparison_operator = "LessThanThreshold"
        threshold          = 10000000000  # 10GB
        period             = 300
        evaluation_periods = 2
        alarm_actions      = []
      }
    }
  }
}

variable "parameter_group_config" {
  description = "Database parameter group configuration"
  type = map(string)
  default = {}
}

variable "tags" {
  description = "Additional tags for RDS resources"
  type        = map(string)
  default     = {}
}