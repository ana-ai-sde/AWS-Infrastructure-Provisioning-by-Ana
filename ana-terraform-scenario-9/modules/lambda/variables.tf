variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
}

variable "runtime" {
  description = "Runtime for Lambda function"
  type        = string
  default     = "nodejs18.x"
  
  validation {
    condition     = contains(["nodejs16.x", "nodejs18.x", "python3.8", "python3.9", "python3.10"], var.runtime)
    error_message = "runtime must be one of: nodejs16.x, nodejs18.x, python3.8, python3.9, python3.10"
  }
}

variable "memory_size" {
  description = "Memory size for Lambda function in MB"
  type        = number
  default     = 256
  
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "memory_size must be between 128 MB and 10240 MB"
  }
}

variable "timeout" {
  description = "Timeout for Lambda function in seconds"
  type        = number
  default     = 30
  
  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "timeout must be between 1 and 900 seconds"
  }
}

variable "environment_variables" {
  description = "Environment variables for Lambda function"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
  
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653"
  }
}

variable "enable_function_url" {
  description = "Enable Lambda Function URL"
  type        = bool
  default     = false
}

variable "function_url_authorization" {
  description = "Authorization type for Lambda Function URL (AWS_IAM or NONE)"
  type        = string
  default     = "AWS_IAM"
  
  validation {
    condition     = contains(["AWS_IAM", "NONE"], var.function_url_authorization)
    error_message = "function_url_authorization must be either AWS_IAM or NONE"
  }
}

variable "allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for Lambda resources"
  type        = map(string)
  default     = {}
}