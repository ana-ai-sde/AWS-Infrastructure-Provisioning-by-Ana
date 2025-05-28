output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "alarm_topic_arn" {
  description = "ARN of the SNS topic for alarms (if email was provided)"
  value       = var.alarm_email != null ? aws_sns_topic.alarms[0].arn : null
}

output "xray_sampling_rule_name" {
  description = "Name of the X-Ray sampling rule"
  value       = aws_xray_sampling_rule.api_sampling.rule_name
}

output "lambda_alarms" {
  description = "Map of Lambda CloudWatch alarm ARNs"
  value = {
    errors    = aws_cloudwatch_metric_alarm.lambda_errors.arn
    duration  = aws_cloudwatch_metric_alarm.lambda_duration.arn
    throttles = aws_cloudwatch_metric_alarm.lambda_throttles.arn
  }
}

output "api_alarms" {
  description = "Map of API Gateway CloudWatch alarm ARNs"
  value = {
    latency    = aws_cloudwatch_metric_alarm.api_latency.arn
    errors_4xx = aws_cloudwatch_metric_alarm.api_4xx_errors.arn
    errors_5xx = aws_cloudwatch_metric_alarm.api_5xx_errors.arn
  }
}

output "sns_subscription_status" {
  description = "Status of SNS topic subscription (if email was provided)"
  value       = var.alarm_email != null ? aws_sns_topic_subscription.alarm_email[0].confirmation_was_authenticated : null
}