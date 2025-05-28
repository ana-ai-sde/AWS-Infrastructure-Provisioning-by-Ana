variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., prod, dev, staging)"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "List of subject alternative names for the certificate"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Certificate validation method (DNS or EMAIL)"
  type        = string
  default     = "DNS"
}

variable "validation_timeout" {
  description = "Timeout for certificate validation"
  type        = string
  default     = "45m"
}

variable "certificate_transparency_logging_preference" {
  description = "Whether certificate details should be added to CT logs"
  type        = bool
  default     = true
}

variable "monitoring" {
  description = "Certificate monitoring configuration"
  type = object({
    enabled            = bool
    evaluation_periods = number
    period            = number
    expiry_days       = number
    alarm_actions     = list(string)
  })
  default = {
    enabled            = true
    evaluation_periods = 1
    period            = 86400  # 1 day
    expiry_days       = 30
    alarm_actions     = []
  }
}

variable "tags" {
  description = "Additional tags for ACM resources"
  type        = map(string)
  default     = {}
}