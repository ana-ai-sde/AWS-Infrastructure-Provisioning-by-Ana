# Dead Letter Queue (if enabled)
resource "aws_sqs_queue" "dlq" {
  count = var.dlq_enabled ? 1 : 0

  name                              = "${var.queue_name}-dlq${var.fifo_queue ? ".fifo" : ""}"
  fifo_queue                       = var.fifo_queue
  content_based_deduplication      = var.fifo_queue ? var.content_based_deduplication : null
  delay_seconds                    = var.delay_seconds
  max_message_size                 = var.max_message_size
  message_retention_seconds        = var.message_retention_seconds
  receive_wait_time_seconds        = var.receive_wait_time_seconds
  visibility_timeout_seconds       = var.visibility_timeout_seconds
  kms_master_key_id               = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

  tags = merge(
    {
      Name = "${var.queue_name}-dlq"
    },
    var.tags
  )
}

# Main Queue
resource "aws_sqs_queue" "this" {
  name                              = var.fifo_queue ? "${var.queue_name}.fifo" : var.queue_name
  fifo_queue                       = var.fifo_queue
  content_based_deduplication      = var.fifo_queue ? var.content_based_deduplication : null
  delay_seconds                    = var.delay_seconds
  max_message_size                 = var.max_message_size
  message_retention_seconds        = var.message_retention_seconds
  receive_wait_time_seconds        = var.receive_wait_time_seconds
  visibility_timeout_seconds       = var.visibility_timeout_seconds
  kms_master_key_id               = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

  redrive_policy = var.dlq_enabled ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = merge(
    {
      Name = var.queue_name
    },
    var.tags
  )
}

# Queue Policy
resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSQSActions"
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.this.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn": "arn:aws:*:*:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}