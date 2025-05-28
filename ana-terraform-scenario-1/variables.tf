variable "project_name" {
  type        = string
  description = "Project name"
  default     = "static-website"
}

variable "environment" {
  type        = string
  description = "Environment (e.g., dev, prod)"
  default     = "dev"
}

variable "domain_name" {
  type        = string
  description = "Domain name for the website"
}

variable "enable_versioning" {
  type        = bool
  description = "Enable versioning for S3 bucket"
  default     = true
}

variable "enable_dns" {
  type        = bool
  description = "Enable Route 53 DNS configuration"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for resources"
  default     = {}
}