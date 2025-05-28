# ACM Certificate
resource "aws_acm_certificate" "website" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# S3 bucket for website hosting
module "s3" {
  source = "./modules/s3"

  bucket_name                = "${var.project_name}-${var.environment}-website"
  enable_versioning         = var.enable_versioning
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
  tags                      = var.tags

  depends_on = [aws_acm_certificate.website]
}

# CloudFront distribution
module "cloudfront" {
  source = "./modules/cloudfront"

  domain_name                = var.domain_name
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  ssl_certificate_arn        = aws_acm_certificate.website.arn
  tags                      = var.tags

  depends_on = [aws_acm_certificate.website]
}

# Route53 DNS configuration
module "route53" {
  count  = var.enable_dns ? 1 : 0
  source = "./modules/route53"

  domain_name               = var.domain_name
  cloudfront_domain_name    = module.cloudfront.domain_name
  cloudfront_hosted_zone_id = module.cloudfront.hosted_zone_id
  domain_validation_options = aws_acm_certificate.website.domain_validation_options
  tags                     = var.tags

  depends_on = [aws_acm_certificate.website]
}

# ACM certificate validation
resource "aws_acm_certificate_validation" "website" {
  certificate_arn         = aws_acm_certificate.website.arn
  validation_record_fqdns = var.enable_dns ? [for record in module.route53[0].validation_records : record.fqdn] : []

  depends_on = [
    aws_acm_certificate.website,
    module.route53
  ]
}

# Outputs
output "website_url" {
  value       = "https://${var.domain_name}"
  description = "Website URL"
}

output "cloudfront_domain" {
  value       = module.cloudfront.domain_name
  description = "CloudFront distribution domain name"
}

output "bucket_name" {
  value       = module.s3.bucket_id
  description = "Name of the S3 bucket"
}

output "nameservers" {
  value       = var.enable_dns ? module.route53[0].nameservers : null
  description = "Nameservers for the hosted zone (if DNS is enabled)"
}