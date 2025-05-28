variable "domain_name" {
  type        = string
  description = "Domain name for the website"
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "Regional domain name of the S3 bucket"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for the distribution"
  default     = {}
}

variable "price_class" {
  type        = string
  description = "CloudFront distribution price class"
  default     = "PriceClass_All"
}

variable "ssl_certificate_arn" {
  type        = string
  description = "ARN of SSL certificate"
}