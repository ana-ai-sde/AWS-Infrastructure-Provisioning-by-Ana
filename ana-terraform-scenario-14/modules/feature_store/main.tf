resource "aws_iam_role" "feature_store_role" {
  name = "${var.project_name}-feature-store-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "feature_store_policy" {
  name = "${var.project_name}-feature-store-policy"
  role = aws_iam_role.feature_store_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          aws_s3_bucket.feature_store.arn,
          "${aws_s3_bucket.feature_store.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_sagemaker_feature_group" "feature_group" {
  for_each = { for fg in var.feature_groups : fg.name => fg }

  feature_group_name = "${var.project_name}-${each.value.name}"
  description        = each.value.description
  record_identifier_feature_name = each.value.record_identifier_feature_name
  event_time_feature_name       = each.value.event_time_feature_name
  role_arn          = aws_iam_role.feature_store_role.arn

  dynamic "feature_definition" {
    for_each = each.value.features
    content {
      feature_name = feature_definition.value.name
      feature_type = feature_definition.value.type
    }
  }

  online_store_config {
    enable_online_store = true
  }

  offline_store_config {
    disable_glue_table_creation = false
    s3_storage_config {
      s3_uri = "s3://${aws_s3_bucket.feature_store.id}/${each.value.name}"
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket" "feature_store" {
  bucket = "${var.project_name}-feature-store-${var.environment}"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "feature_store" {
  bucket = aws_s3_bucket.feature_store.id
  versioning_configuration {
    status = "Enabled"
  }
}















    