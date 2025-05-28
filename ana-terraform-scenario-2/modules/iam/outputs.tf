output "cloudwatch_role_arn" {
  description = "ARN of the CloudWatch IAM role"
  value       = aws_iam_role.cloudwatch_role.arn
}

output "cloudwatch_role_name" {
  description = "Name of the CloudWatch IAM role"
  value       = aws_iam_role.cloudwatch_role.name
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.cloudwatch_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.cloudwatch_profile.arn
}