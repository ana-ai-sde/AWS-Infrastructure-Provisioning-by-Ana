output "certificate_arn" {
  description = "ARN of the issued certificate"
  value       = aws_acm_certificate.main.arn
}

output "domain_validation_options" {
  description = "Domain validation options for the certificate"
  value       = aws_acm_certificate.main.domain_validation_options
}

output "validation_domains" {
  description = "List of distinct domain validation options for the certificate"
  value       = distinct(aws_acm_certificate.main.domain_validation_options[*].resource_record_name)
}