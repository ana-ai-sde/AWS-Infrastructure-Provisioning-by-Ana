resource "aws_sns_topic" "monitoring_alerts" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "email" {
  count     = length(var.email_endpoints)
  topic_arn = aws_sns_topic.monitoring_alerts.arn
  protocol  = "email"
  endpoint  = var.email_endpoints[count.index]
}