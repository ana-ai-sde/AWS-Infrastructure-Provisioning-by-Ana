variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "metric_namespace" {
  description = "Namespace for CloudWatch metrics"
  type        = string
}

variable "alarm_email_endpoints" {
  description = "List of email addresses to receive alarm notifications"
  type        = list(string)
}

variable "cpu_anomaly_config" {
  description = "Configuration for CPU anomaly detection alarm"
  type = object({
    evaluation_periods = number
    anomaly_band_width = number
    period = number
    statistic = string
  })
  default = {
    evaluation_periods = 2
    anomaly_band_width = 2
    period = 300
    statistic = "Average"
  }
}

variable "disk_io_anomaly_config" {
  description = "Configuration for Disk I/O anomaly detection alarm"
  type = object({
    evaluation_periods = number
    anomaly_band_width = number
    period = number
    statistic = string
  })
  default = {
    evaluation_periods = 2
    anomaly_band_width = 2
    period = 300
    statistic = "Average"
  }
}

variable "memory_alarm_config" {
  description = "Configuration for Memory usage alarm"
  type = object({
    evaluation_periods = number
    period = number
    statistic = string
    threshold = number
  })
  default = {
    evaluation_periods = 2
    period = 300
    statistic = "Average"
    threshold = 80
  }
}