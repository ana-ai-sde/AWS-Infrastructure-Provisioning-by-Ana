output "efs_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.this.id
}

output "efs_arn" {
  description = "The ARN of the EFS file system"
  value       = aws_efs_file_system.this.arn
}

output "efs_dns_name" {
  description = "The DNS name of the EFS file system"
  value       = aws_efs_file_system.this.dns_name
}

output "mount_targets" {
  description = "List of mount target IDs created"
  value       = aws_efs_mount_target.this[*].id
}

output "security_group_id" {
  description = "The ID of the security group created for EFS"
  value       = aws_security_group.efs.id
}