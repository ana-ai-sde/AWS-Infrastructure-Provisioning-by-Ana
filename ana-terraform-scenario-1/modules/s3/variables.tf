variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "enable_versioning" {
  type        = bool
  description = "Enable versioning for S3 bucket"
  default     = true
}

variable "cloudfront_distribution_arn" {
  type        = string
  description = "CloudFront distribution ARN"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for the bucket"
  default     = {}
}