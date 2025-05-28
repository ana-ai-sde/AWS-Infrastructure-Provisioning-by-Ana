output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}

output "dynamodb_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = try(aws_vpc_endpoint.dynamodb[0].id, null)
}

output "ecr_api_endpoint_id" {
  description = "ID of the ECR API VPC endpoint"
  value       = try(aws_vpc_endpoint.ecr_api[0].id, null)
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR Docker VPC endpoint"
  value       = try(aws_vpc_endpoint.ecr_dkr[0].id, null)
}

output "vpc_endpoint_security_group_id" {
  description = "ID of the security group created for VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}