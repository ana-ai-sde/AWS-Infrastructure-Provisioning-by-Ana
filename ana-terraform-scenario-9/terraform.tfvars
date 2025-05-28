aws_region = "ap-south-1"
environment = "dev"
project_name = "serverless-api"

# Lambda Configuration
lambda_memory = 256
lambda_timeout = 30
enable_xray = true

# API Gateway Configuration
enable_api_key_auth = false  # Use IAM authentication

# DynamoDB Configuration
dynamodb_billing_mode = "PROVISIONED"

# Optional: Uncomment and set email for alarm notifications
# alarm_email = "your.email@example.com"

tags = {
  Environment = "dev"
  Project     = "serverless-api"
  Terraform   = "true"
  Region      = "ap-south-1"
}