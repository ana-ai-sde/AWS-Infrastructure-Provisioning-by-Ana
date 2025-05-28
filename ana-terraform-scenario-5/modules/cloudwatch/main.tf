# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags
    ]
  }
}