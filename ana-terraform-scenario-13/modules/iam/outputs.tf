output "permission_boundary_arn" {
        description = "ARN of the permission boundary policy"
        value       = aws_iam_policy.permission_boundary.arn
    }

    output "ec2_role_arn" {
        description = "ARN of the EC2 IAM role"
        value       = aws_iam_role.ec2_role.arn
    }