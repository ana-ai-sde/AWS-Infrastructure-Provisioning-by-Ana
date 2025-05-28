# Permission boundary for IAM roles
    resource "aws_iam_policy" "permission_boundary" {
        name        = "${var.environment}-permission-boundary"
        description = "Permission boundary for all IAM roles"

        policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Effect = "Allow"
                    Action = [
                        "s3:*",
                        "ec2:*",
                        "rds:*",
                        "dynamodb:*",
                        "kms:*",
                        "secretsmanager:*"
                    ]
                    Resource = "*"
                    Condition = {
                        StringEquals = {
                            "aws:RequestedRegion": var.aws_region
                        }
                    }
                },
                {
                    Effect = "Deny"
                    Action = [
                        "iam:CreateUser",
                        "iam:DeleteUser",
                        "iam:CreateRole",
                        "iam:DeleteRole"
                    ]
                    Resource = "*"
                }
            ]
        })
    }

    # IAM role for EC2 instances
    resource "aws_iam_role" "ec2_role" {
        name                = "${var.environment}-ec2-role"
        assume_role_policy  = jsonencode({
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
        permissions_boundary = aws_iam_policy.permission_boundary.arn
    }