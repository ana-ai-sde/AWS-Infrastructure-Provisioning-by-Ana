module "ec2_management_policy" {
  source = "../modules/iam_policy"

  policy_name        = "ec2-management-policy"
  policy_description = "Policy for EC2 instance management with specific permissions"

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeTags",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:PutMetricData"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# Create a role that uses this policy
module "ec2_manager_role" {
  source = "../modules/iam_role"

  role_name        = "ec2-manager"
  role_description = "Role for EC2 instance management"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
          AWS     = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      }
    ]
  })

  # Reference the policy ARN from the policy module
  policy_arns = [module.ec2_management_policy.policy_arn]

  tags = {
    Environment = "Production"
    Purpose     = "EC2 Management"
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}