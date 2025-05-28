resource "aws_sns_topic" "sre_alerts" {
  name = var.sns_topic_name

  tags = {
    Name    = "SRE Alerts Topic"
    Purpose = "Automated SRE Response System"
  }
}

resource "aws_sns_topic_subscription" "email_subscriptions" {
  for_each = toset(var.email_addresses)

  topic_arn = aws_sns_topic.sre_alerts.arn
  protocol  = "email"
  endpoint  = each.value

  depends_on = [aws_sns_topic.sre_alerts]
}

# Add SNS topic policy to allow CloudWatch Alarms to publish
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.sre_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarms"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.sre_alerts.arn
      },
      {
        Sid    = "AllowLambdaPublish"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.sre_alerts.arn
      }
    ]
  })
}