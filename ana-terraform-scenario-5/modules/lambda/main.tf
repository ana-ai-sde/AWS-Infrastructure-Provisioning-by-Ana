# Archive the Python file for Lambda deployment
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda function
resource "aws_lambda_function" "function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role            = var.lambda_role_arn
  handler         = "lambda_function.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = var.runtime
  
  # Resource configuration
  memory_size    = var.memory_size
  timeout        = var.timeout

  environment {
    variables = var.environment_variables
  }

  lifecycle {
    create_before_destroy = false
    prevent_destroy      = false
    ignore_changes = [
      tags,
      environment
    ]
  }
}