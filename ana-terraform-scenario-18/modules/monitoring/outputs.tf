output "cloudwatch_alarm_arn" {
  description = "ARN of the CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.vpn_tunnel_status.arn
}