output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  value       = aws_subnet.private[*].cidr_block
}

output "public_subnets" {
  description = "Map of AZ to public subnet ID"
  value = zipmap(
    aws_subnet.public[*].availability_zone,
    aws_subnet.public[*].id
  )
}

output "private_subnets" {
  description = "Map of AZ to private subnet ID"
  value = zipmap(
    aws_subnet.private[*].availability_zone,
    aws_subnet.private[*].id
  )
}