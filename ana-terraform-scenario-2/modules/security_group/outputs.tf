output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.this.id
}

output "security_group_name" {
  description = "Name of the created security group"
  value       = aws_security_group.this.name
}

output "security_group_vpc_id" {
  description = "VPC ID of the created security group"
  value       = aws_security_group.this.vpc_id
}