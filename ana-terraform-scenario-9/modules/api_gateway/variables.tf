variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Lambda function invoke ARN"
  type        = string
}

variable "lambda_name" {
  description = "Lambda function name"
  type        = string
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}

variable "authorization_type" {
  description = "Authorization type for API Gateway (IAM or API_KEY)"
  type        = string
  default     = "IAM"
  
  validation {
    condition     = contains(["IAM", "API_KEY"], var.authorization_type)
    error_message = "authorization_type must be either IAM or API_KEY"
  }
}

variable "throttling_rate_limit" {
  description = "API Gateway throttling rate limit"
  type        = number
  default     = 10000
  
  validation {
    condition     = var.throttling_rate_limit > 0
    error_message = "throttling_rate_limit must be greater than 0"
  }
}

variable "throttling_burst_limit" {
  description = "API Gateway throttling burst limit"
  type        = number
  default     = 5000
  
  validation {
    condition     = var.throttling_burst_limit > 0
    error_message = "throttling_burst_limit must be greater than 0"
  }
}

variable "metrics_enabled" {
  description = "Enable detailed CloudWatch metrics"
  type        = bool
  default     = true
}

variable "logging_level" {
  description = "API Gateway logging level"
  type        = string
  default     = "INFO"
  
  validation {
    condition     = contains(["ERROR", "INFO"], var.logging_level)
    error_message = "logging_level must be either ERROR or INFO"
  }
}

variable "xray_tracing_enabled" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

variable "allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = []
}

variable "api_key_settings" {
  description = "API key settings when using API_KEY authorization"
  type = object({
    quota_limit    = optional(number, 1000000)
    quota_period   = optional(string, "MONTH")
    quota_offset   = optional(number, 0)
    key_name       = optional(string)
  })
  default = {}
}

variable "tags" {
  description = "Tags for API Gateway resources"
  type        = map(string)
  default     = {}
}