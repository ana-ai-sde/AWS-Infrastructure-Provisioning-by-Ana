output "distribution_id" {
  value       = aws_cloudfront_distribution.website.id
  description = "The ID of the CloudFront distribution"
}

output "distribution_arn" {
  value       = aws_cloudfront_distribution.website.arn
  description = "The ARN of the CloudFront distribution"
}

output "domain_name" {
  value       = aws_cloudfront_distribution.website.domain_name
  description = "The domain name of the CloudFront distribution"
}

output "hosted_zone_id" {
  value       = aws_cloudfront_distribution.website.hosted_zone_id
  description = "The CloudFront distribution hosted zone ID"
}