variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PROVISIONED"
  
  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "billing_mode must be either PROVISIONED or PAY_PER_REQUEST"
  }
}

variable "read_capacity" {
  description = "Initial read capacity units for PROVISIONED billing mode"
  type        = number
  default     = 5
  
  validation {
    condition     = var.read_capacity >= 1
    error_message = "read_capacity must be greater than or equal to 1"
  }
}

variable "write_capacity" {
  description = "Initial write capacity units for PROVISIONED billing mode"
  type        = number
  default     = 5
  
  validation {
    condition     = var.write_capacity >= 1
    error_message = "write_capacity must be greater than or equal to 1"
  }
}

variable "autoscaling_min_read_capacity" {
  description = "Minimum read capacity for autoscaling"
  type        = number
  default     = 5
  
  validation {
    condition     = var.autoscaling_min_read_capacity >= 1
    error_message = "autoscaling_min_read_capacity must be greater than or equal to 1"
  }
}

variable "autoscaling_max_read_capacity" {
  description = "Maximum read capacity for autoscaling"
  type        = number
  default     = 100
  
  validation {
    condition     = var.autoscaling_max_read_capacity > var.autoscaling_min_read_capacity
    error_message = "autoscaling_max_read_capacity must be greater than autoscaling_min_read_capacity"
  }
}

variable "autoscaling_min_write_capacity" {
  description = "Minimum write capacity for autoscaling"
  type        = number
  default     = 5
  
  validation {
    condition     = var.autoscaling_min_write_capacity >= 1
    error_message = "autoscaling_min_write_capacity must be greater than or equal to 1"
  }
}

variable "autoscaling_max_write_capacity" {
  description = "Maximum write capacity for autoscaling"
  type        = number
  default     = 100
  
  validation {
    condition     = var.autoscaling_max_write_capacity > var.autoscaling_min_write_capacity
    error_message = "autoscaling_max_write_capacity must be greater than autoscaling_min_write_capacity"
  }
}

variable "autoscaling_target_value" {
  description = "Target value for autoscaling (percentage of capacity)"
  type        = number
  default     = 70
  
  validation {
    condition     = var.autoscaling_target_value > 0 && var.autoscaling_target_value <= 100
    error_message = "autoscaling_target_value must be between 1 and 100"
  }
}

variable "hash_key" {
  description = "Hash key for the DynamoDB table"
  type        = string
  default     = "id"
}

variable "tags" {
  description = "Tags for the DynamoDB table"
  type        = map(string)
  default     = {}
}