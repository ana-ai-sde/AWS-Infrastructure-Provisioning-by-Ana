provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Enable CloudWatch for API Gateway logging
provider "aws" {
  alias  = "logging"
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "dynamodb" {
  source = "./modules/dynamodb"
  
  table_name    = "${local.name_prefix}-table"
  billing_mode  = var.dynamodb_billing_mode
  read_capacity = 5
  write_capacity = 5
  autoscaling_min_read_capacity = 5
  autoscaling_max_read_capacity = 100
  autoscaling_min_write_capacity = 5
  autoscaling_max_write_capacity = 100
  autoscaling_target_value = 70
  tags         = var.tags
}

module "lambda" {
  source = "./modules/lambda"
  
  function_name       = "${local.name_prefix}-function"
  dynamodb_table_name = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  runtime            = "nodejs18.x"
  memory_size        = var.lambda_memory
  timeout            = var.lambda_timeout
  environment_variables = {
    POWERTOOLS_SERVICE_NAME = local.name_prefix
    LOG_LEVEL              = "INFO"
  }
  tags = var.tags
}

module "api_gateway" {
  source = "./modules/api_gateway"
  
  api_name          = "${local.name_prefix}-api"
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
  lambda_name       = module.lambda.function_name
  authorization_type = var.enable_api_key_auth ? "API_KEY" : "IAM"
  throttling_rate_limit = 10000
  throttling_burst_limit = 5000
  metrics_enabled    = true
  logging_level      = "INFO"
  xray_tracing_enabled = var.enable_xray
  tags              = var.tags
}

module "observability" {
  source = "./modules/observability"
  
  lambda_name = module.lambda.function_name
  api_name    = module.api_gateway.api_name
  alarm_email = var.alarm_email
  
  lambda_error_threshold    = 1
  lambda_duration_threshold = 300
  api_latency_threshold    = 500
  api_error_threshold      = 1
  
  evaluation_periods = 3
  period_seconds    = 300
  treat_missing_data = "breaching"
  
  tags = var.tags
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.2.0"
}