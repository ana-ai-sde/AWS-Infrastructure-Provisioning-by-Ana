module "cloudwatch" {
  source = "./modules/cloudwatch"

  function_name      = var.function_name
  log_retention_days = var.log_retention_days
}

module "iam" {
  source = "./modules/iam"

  function_name  = var.function_name
  log_group_arn = module.cloudwatch.log_group_arn
}

module "lambda" {
  source = "./modules/lambda"

  function_name         = var.function_name
  lambda_role_arn      = module.iam.role_arn
  runtime              = var.lambda_runtime
  memory_size          = var.lambda_memory_size
  timeout              = var.lambda_timeout
  environment_variables = var.lambda_environment_variables
}

module "scheduler" {
  source = "./modules/eventbridge"

  rule_name            = "${var.function_name}-schedule"
  rule_description     = var.schedule_description
  schedule_expression  = var.schedule_expression
  lambda_function_arn  = module.lambda.function_arn
  lambda_function_name = module.lambda.function_name
}