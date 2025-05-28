variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "metric_namespace" {
  description = "Namespace for CloudWatch metrics"
  type        = string
  default     = "CustomMetrics"
}

variable "alarm_email_endpoints" {
  description = "List of email addresses to receive alarm notifications"
  type        = list(string)
  default     = []
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

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 2
}