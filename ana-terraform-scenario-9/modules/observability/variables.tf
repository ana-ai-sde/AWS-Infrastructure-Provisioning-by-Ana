variable "lambda_name" {
  description = "Name of the Lambda function to monitor"
  type        = string
}

variable "api_name" {
  description = "Name of the API Gateway to monitor"
  type        = string
}

variable "alarm_email" {
  description = "Email address to send alarm notifications"
  type        = string
  default     = null
}

variable "lambda_error_threshold" {
  description = "Threshold for Lambda error rate alarm (percentage)"
  type        = number
  default     = 1
  
  validation {
    condition     = var.lambda_error_threshold >= 0 && var.lambda_error_threshold <= 100
    error_message = "lambda_error_threshold must be between 0 and 100"
  }
}

variable "lambda_duration_threshold" {
  description = "Threshold for Lambda duration alarm (milliseconds)"
  type        = number
  default     = 300
  
  validation {
    condition     = var.lambda_duration_threshold > 0
    error_message = "lambda_duration_threshold must be greater than 0"
  }
}

variable "api_latency_threshold" {
  description = "Threshold for API Gateway latency alarm (milliseconds)"
  type        = number
  default     = 500
  
  validation {
    condition     = var.api_latency_threshold > 0
    error_message = "api_latency_threshold must be greater than 0"
  }
}

variable "api_error_threshold" {
  description = "Threshold for API Gateway 4xx/5xx error rate alarm (percentage)"
  type        = number
  default     = 1
  
  validation {
    condition     = var.api_error_threshold >= 0 && var.api_error_threshold <= 100
    error_message = "api_error_threshold must be between 0 and 100"
  }
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate alarms"
  type        = number
  default     = 3
  
  validation {
    condition     = var.evaluation_periods > 0
    error_message = "evaluation_periods must be greater than 0"
  }
}

variable "period_seconds" {
  description = "Period in seconds for alarm evaluation"
  type        = number
  default     = 300
  
  validation {
    condition     = contains([60, 120, 300, 600, 900, 1800, 3600], var.period_seconds)
    error_message = "period_seconds must be one of: 60, 120, 300, 600, 900, 1800, 3600"
  }
}

variable "treat_missing_data" {
  description = "How to treat missing data in CloudWatch alarms (missing, ignore, breaching, notBreaching)"
  type        = string
  default     = "breaching"
  
  validation {
    condition     = contains(["missing", "ignore", "breaching", "notBreaching"], var.treat_missing_data)
    error_message = "treat_missing_data must be one of: missing, ignore, breaching, notBreaching"
  }
}

variable "tags" {
  description = "Tags for observability resources"
  type        = map(string)
  default     = {}
}