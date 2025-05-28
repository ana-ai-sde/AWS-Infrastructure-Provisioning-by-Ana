# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  lifecycle {
    create_before_destroy = false
    prevent_destroy      = false
    ignore_changes = [
      tags
    ]
  }
}

# IAM policy for Lambda logging
resource "aws_iam_role_policy" "lambda_logging" {
  name = "${var.function_name}-logging-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${var.log_group_arn}",
          "${var.log_group_arn}:*"
        ]
      }
    ]
  })

  lifecycle {
    create_before_destroy = false
  }
}