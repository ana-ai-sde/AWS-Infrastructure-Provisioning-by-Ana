variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., prod, dev, staging)"
  type        = string
}

variable "alarm_notification_config" {
  description = "Configuration for alarm notifications"
  type = object({
    enabled = bool
    endpoints = map(object({
      type     = string  # email, sms, or lambda
      endpoint = string
    }))
    default_actions = list(string)  # List of SNS topic ARNs
  })
  default = {
    enabled = false
    endpoints = {}
    default_actions = []
  }
}

variable "ec2_monitoring" {
  description = "EC2 monitoring configuration"
  type = object({
    enabled = bool
    metrics = map(object({
      metric_name         = string
      namespace          = string
      statistic          = string
      comparison_operator = string
      threshold          = number
      period             = number
      evaluation_periods = number
      datapoints_to_alarm = number
      treat_missing_data = string
      actions = list(string)
    }))
    dimensions = map(string)
  })
  default = {
    enabled = true
    metrics = {
      cpu_utilization = {
        metric_name         = "CPUUtilization"
        namespace          = "AWS/EC2"
        statistic          = "Average"
        comparison_operator = "GreaterThanThreshold"
        threshold          = 80
        period             = 300
        evaluation_periods = 2
        datapoints_to_alarm = 2
        treat_missing_data = "missing"
        actions            = []
      },
      memory_utilization = {
        metric_name         = "MemoryUtilization"
        namespace          = "CWAgent"
        statistic          = "Average"
        comparison_operator = "GreaterThanThreshold"
        threshold          = 80
        period             = 300
        evaluation_periods = 2
        datapoints_to_alarm = 2
        treat_missing_data = "missing"
        actions            = []
      }
    }
    dimensions = {}
  }
}

variable "rds_monitoring" {
  description = "RDS monitoring configuration"
  type = object({
    enabled = bool
    metrics = map(object({
      metric_name         = string
      namespace          = string
      statistic          = string
      comparison_operator = string
      threshold          = number
      period             = number
      evaluation_periods = number
      datapoints_to_alarm = number
      treat_missing_data = string
      actions = list(string)
    }))
    dimensions = map(string)
  })
  default = {
    enabled = true
    metrics = {
      cpu_utilization = {
        metric_name         = "CPUUtilization"
        namespace          = "AWS/RDS"
        statistic          = "Average"
        comparison_operator = "GreaterThanThreshold"
        threshold          = 80
        period             = 300
        evaluation_periods = 2
        datapoints_to_alarm = 2
        treat_missing_data = "missing"
        actions            = []
      },
      free_storage_space = {
        metric_name         = "FreeStorageSpace"
        namespace          = "AWS/RDS"
        statistic          = "Average"
        comparison_operator = "LessThanThreshold"
        threshold          = 10000000000
        period             = 300
        evaluation_periods = 2
        datapoints_to_alarm = 2
        treat_missing_data = "missing"
        actions            = []
      }
    }
    dimensions = {}
  }
}

variable "alb_monitoring" {
  description = "ALB monitoring configuration"
  type = object({
    enabled = bool
    metrics = map(object({
      metric_name         = string
      namespace          = string
      statistic          = string
      comparison_operator = string
      threshold          = number
      period             = number
      evaluation_periods = number
      datapoints_to_alarm = number
      treat_missing_data = string
      actions = list(string)
    }))
    dimensions = map(string)
  })
  default = {
    enabled = true
    metrics = {
      unhealthy_hosts = {
        metric_name         = "UnHealthyHostCount"
        namespace          = "AWS/ApplicationELB"
        statistic          = "Average"
        comparison_operator = "GreaterThanThreshold"
        threshold          = 0
        period             = 300
        evaluation_periods = 2
        datapoints_to_alarm = 2
        treat_missing_data = "missing"
        actions            = []
      },
      target_response_time = {
        metric_name         = "TargetResponseTime"
        namespace          = "AWS/ApplicationELB"
        statistic          = "Average"
        comparison_operator = "GreaterThanThreshold"
        threshold          = 5
        period             = 300
        evaluation_periods = 2
        datapoints_to_alarm = 2
        treat_missing_data = "missing"
        actions            = []
      }
    }
    dimensions = {}
  }
}

variable "custom_metrics" {
  description = "Custom metrics configuration"
  type = map(object({
    metric_name = string
    namespace   = string
    unit        = string
    dimensions  = map(string)
    value       = number
  }))
  default = {}
}

variable "dashboard_config" {
  description = "CloudWatch dashboard configuration"
  type = object({
    enabled = bool
    widgets = map(object({
      type       = string
      width      = number
      height     = number
      x          = number
      y          = number
      properties = any
    }))
  })
  default = {
    enabled = false
    widgets = {}
  }
}

variable "log_groups" {
  description = "Log groups configuration"
  type = map(object({
    retention_in_days = number
    kms_key_id       = string
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags for monitoring resources"
  type        = map(string)
  default     = {}
}