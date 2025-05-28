output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = module.ec2.instance_id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.instance_public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.security_group.security_group_id
}

output "cloudwatch_role_arn" {
  description = "ARN of the CloudWatch IAM role"
  value       = module.iam.cloudwatch_role_arn
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = module.iam.instance_profile_name
}