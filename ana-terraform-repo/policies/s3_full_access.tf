module "s3_full_access_policy" {
  source = "../modules/iam_policy"

  policy_name        = "s3-full-access"
  policy_description = "Policy that grants full access to S3"

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

# Example of using this policy with our IAM role module
module "s3_admin_role" {
  source = "../modules/iam_role"

  role_name        = "s3-administrator"
  role_description = "Role with full S3 access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  # Reference the policy ARN from the policy module
  policy_arns = [module.s3_full_access_policy.policy_arn]
}