# EventBridge rule
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = var.rule_name
  description         = var.rule_description
  schedule_expression = var.schedule_expression

  lifecycle {
    create_before_destroy = true
    prevent_destroy      = false
    ignore_changes = [
      description,
      tags
    ]
  }
}

# EventBridge target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "SendToLambda"
  arn       = var.lambda_function_arn

  lifecycle {
    create_before_destroy = true
  }
}

# Lambda permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn

  lifecycle {
    create_before_destroy = true
  }
}