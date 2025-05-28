output "bucket_id" {
  value       = aws_s3_bucket.website.id
  description = "The name of the bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.website.arn
  description = "The ARN of the bucket"
}

output "bucket_regional_domain_name" {
  value       = aws_s3_bucket.website.bucket_regional_domain_name
  description = "The regional domain name of the bucket"
}

output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
  description = "The website endpoint URL"
}