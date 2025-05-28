resource "aws_sns_topic" "this" {
  name                        = var.fifo_topic ? "${var.name}.fifo" : var.name
  display_name               = var.name
  policy                     = var.policy
  delivery_policy            = var.delivery_policy
  kms_master_key_id         = var.kms_master_key_id
  fifo_topic                = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication
  tags                      = var.tags
}

# Optional: Create an SNS topic policy
data "aws_iam_policy_document" "default" {
  count = var.policy == null ? 1 : 0

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    resources = [aws_sns_topic.this.arn]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_caller_identity" "current" {}



