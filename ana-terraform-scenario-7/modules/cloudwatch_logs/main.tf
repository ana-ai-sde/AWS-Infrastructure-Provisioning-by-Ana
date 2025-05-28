# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/application/${var.environment}"
  retention_in_days = var.retention_days

  tags = {
    Environment = var.environment
    Service     = "application"
  }
}

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/aws/system/${var.environment}"
  retention_in_days = var.retention_days

  tags = {
    Environment = var.environment
    Service     = "system"
  }
}

# Log Metric Filter for Error tracking
resource "aws_cloudwatch_log_metric_filter" "error_metric" {
  name           = "error-metric-${var.environment}"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.application_logs.name

  metric_transformation {
    name          = "ErrorCount"
    namespace     = "LogMetrics"
    value         = "1"
    default_value = "0"
  }
}