variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name for tagging and naming resources"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "project_name" {
  description = "Project name for tagging and naming resources"
  type        = string
  default     = "serverless-api"
}

variable "alarm_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = null
}

variable "enable_api_key_auth" {
  description = "Enable API key authentication instead of IAM"
  type        = bool
  default     = false
}

variable "enable_xray" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

variable "lambda_memory" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
  
  validation {
    condition     = var.lambda_memory >= 128 && var.lambda_memory <= 10240
    error_message = "lambda_memory must be between 128 MB and 10240 MB"
  }
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
  
  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "lambda_timeout must be between 1 and 900 seconds"
  }
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PROVISIONED"
  
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.dynamodb_billing_mode)
    error_message = "dynamodb_billing_mode must be either PROVISIONED or PAY_PER_REQUEST"
  }
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}