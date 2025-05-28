output "zone_id" {
  value       = data.aws_route53_zone.website.zone_id
  description = "The Route53 zone ID"
}

output "nameservers" {
  value       = data.aws_route53_zone.website.name_servers
  description = "The nameservers for the hosted zone"
}

output "validation_records" {
  value = aws_route53_record.acm_validation
  description = "The DNS records created for ACM certificate validation"
}