# Security Group for Secrets Manager VPC Endpoint
resource "aws_security_group" "secrets" {
  name_prefix = "${var.name_prefix}-secrets-sg"
  description = "Security group for Secrets Manager VPC endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    {
      Name        = "${var.name_prefix}-secrets-sg"
      Environment = var.environment
    },
    var.tags
  )
}

# VPC Endpoint for Secrets Manager
resource "aws_vpc_endpoint" "secrets" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.subnet_ids
  security_group_ids = [aws_security_group.secrets.id]

  private_dns_enabled = true

  tags = merge(
    {
      Name        = "${var.name_prefix}-secrets-endpoint"
      Environment = var.environment
    },
    var.tags
  )
}

# Get current region
data "aws_region" "current" {}

# Create secrets
resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.secrets

  name        = "${var.name_prefix}-${each.key}"
  description = each.value.description
  kms_key_id  = var.kms_key_id

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    {
      Name        = "${var.name_prefix}-${each.key}"
      Environment = var.environment
    },
    var.tags
  )
}

# Store secret values
resource "aws_secretsmanager_secret_version" "secret_values" {
  for_each = var.secrets

  secret_id = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = jsonencode(merge(
    {
      username = each.value.secret_string.username
      password = each.value.secret_string.password
    },
    each.value.secret_string.engine != null ? {
      engine = each.value.secret_string.engine
      host   = each.value.secret_string.host
      port   = each.value.secret_string.port
      dbname = each.value.secret_string.dbname
    } : {}
  ))
}

# Create rotation schedule if enabled
resource "aws_secretsmanager_secret_rotation" "rotation" {
  for_each = var.enable_secret_rotation ? var.secrets : {}

  secret_id           = aws_secretsmanager_secret.secrets[each.key].id
  rotation_lambda_arn = aws_lambda_function.rotation[0].arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

# IAM role for Lambda rotation function
resource "aws_iam_role" "rotation_lambda" {
  count = var.enable_secret_rotation ? 1 : 0

  name = "${var.name_prefix}-rotation-lambda-role"

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

  tags = merge(
    {
      Name        = "${var.name_prefix}-rotation-lambda-role"
      Environment = var.environment
    },
    var.tags
  )
}

# IAM policy for Lambda rotation function
resource "aws_iam_role_policy" "rotation_lambda" {
  count = var.enable_secret_rotation ? 1 : 0

  name = "${var.name_prefix}-rotation-lambda-policy"
  role = aws_iam_role.rotation_lambda[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = [for secret in aws_secretsmanager_secret.secrets : secret.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

# Lambda function for secret rotation (if enabled)
resource "aws_lambda_function" "rotation" {
  count = var.enable_secret_rotation ? 1 : 0

  filename         = "${path.module}/rotation_function.zip"
  function_name    = "${var.name_prefix}-secret-rotation"
  role            = aws_iam_role.rotation_lambda[0].arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 30
  memory_size     = 128

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.secrets.id]
  }

  environment {
    variables = {
      SECRETS_PREFIX = var.name_prefix
    }
  }

  tags = merge(
    {
      Name        = "${var.name_prefix}-rotation-lambda"
      Environment = var.environment
    },
    var.tags
  )
}