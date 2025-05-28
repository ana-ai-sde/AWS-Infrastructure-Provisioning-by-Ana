output "alarm_arn" {
  description = "ARN of the created CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.canary_alarm.arn
}

output "alarm_name" {
  description = "Name of the created CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.canary_alarm.alarm_name
}