variable "domain_name" {
  type        = string
  description = "Domain name for the website"
}

variable "cloudfront_domain_name" {
  type        = string
  description = "CloudFront distribution domain name"
}

variable "cloudfront_hosted_zone_id" {
  type        = string
  description = "CloudFront distribution hosted zone ID"
}

variable "domain_validation_options" {
  type = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
  description = "Domain validation options for ACM certificate"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for the DNS records"
  default     = {}
}