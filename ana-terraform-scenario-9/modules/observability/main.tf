# Get current region
data "aws_region" "current" {}

# SNS Topic for alarms
resource "aws_sns_topic" "alarms" {
  count = var.alarm_email != null ? 1 : 0
  
  name = "serverless-api-alarms"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "alarm_email" {
  count = var.alarm_email != null ? 1 : 0
  
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# X-Ray sampling rule
resource "aws_xray_sampling_rule" "api_sampling" {
  rule_name      = "serverless-api-sampling"
  priority       = 1000
  reservoir_size = 1
  fixed_rate     = 0.05
  host           = "*"
  http_method    = "*"
  service_name   = "*"
  service_type   = "*"
  url_path       = "*"
  version        = 1
  resource_arn   = "*"
}

# Lambda Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.lambda_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = var.period_seconds
  statistic          = "Sum"
  threshold          = var.lambda_error_threshold
  alarm_description  = "Lambda function error rate exceeded threshold"
  alarm_actions      = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions         = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  treat_missing_data = var.treat_missing_data

  dimensions = {
    FunctionName = var.lambda_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.lambda_name}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name        = "Duration"
  namespace          = "AWS/Lambda"
  period             = var.period_seconds
  extended_statistic = "p95"
  threshold          = var.lambda_duration_threshold
  alarm_description  = "Lambda function p95 duration exceeded threshold"
  alarm_actions      = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions         = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  treat_missing_data = var.treat_missing_data

  dimensions = {
    FunctionName = var.lambda_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${var.lambda_name}-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name        = "Throttles"
  namespace          = "AWS/Lambda"
  period             = var.period_seconds
  statistic          = "Sum"
  threshold          = 0
  alarm_description  = "Lambda function is being throttled"
  alarm_actions      = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions         = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  treat_missing_data = var.treat_missing_data

  dimensions = {
    FunctionName = var.lambda_name
  }

  tags = var.tags
}

# API Gateway Alarms
resource "aws_cloudwatch_metric_alarm" "api_latency" {
  alarm_name          = "${var.api_name}-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name        = "IntegrationLatency"
  namespace          = "AWS/ApiGateway"
  period             = var.period_seconds
  extended_statistic = "p95"
  threshold          = var.api_latency_threshold
  alarm_description  = "API Gateway p95 latency exceeded threshold"
  alarm_actions      = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions         = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  treat_missing_data = var.treat_missing_data

  dimensions = {
    ApiName = var.api_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "api_4xx_errors" {
  alarm_name          = "${var.api_name}-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name        = "4XXError"
  namespace          = "AWS/ApiGateway"
  period             = var.period_seconds
  statistic          = "Average"
  threshold          = var.api_error_threshold
  alarm_description  = "API Gateway 4XX error rate exceeded threshold"
  alarm_actions      = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions         = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  treat_missing_data = var.treat_missing_data

  dimensions = {
    ApiName = var.api_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "api_5xx_errors" {
  alarm_name          = "${var.api_name}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name        = "5XXError"
  namespace          = "AWS/ApiGateway"
  period             = var.period_seconds
  statistic          = "Average"
  threshold          = var.api_error_threshold
  alarm_description  = "API Gateway 5XX error rate exceeded threshold"
  alarm_actions      = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  ok_actions         = var.alarm_email != null ? [aws_sns_topic.alarms[0].arn] : []
  treat_missing_data = var.treat_missing_data

  dimensions = {
    ApiName = var.api_name
  }

  tags = var.tags
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "ServerlessAPI"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.lambda_name],
            [".", "Errors", ".", "."],
            [".", "Throttles", ".", "."],
            [".", "Duration", ".", ".", { "stat": "p95" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Lambda Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_name],
            [".", "4XXError", ".", "."],
            [".", "5XXError", ".", "."],
            [".", "IntegrationLatency", ".", ".", { "stat": "p95" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "API Gateway Metrics"
        }
      }
    ]
  })
}