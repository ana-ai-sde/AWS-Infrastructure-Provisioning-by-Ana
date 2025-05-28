locals {
  is_provisioned = var.billing_mode == "PROVISIONED"
}

resource "aws_dynamodb_table" "main" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  read_capacity  = local.is_provisioned ? var.read_capacity : null
  write_capacity = local.is_provisioned ? var.write_capacity : null

  attribute {
    name = var.hash_key
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = !local.is_provisioned || (var.read_capacity >= var.autoscaling_min_read_capacity && var.read_capacity <= var.autoscaling_max_read_capacity)
      error_message = "For PROVISIONED mode, read_capacity must be between autoscaling_min_read_capacity and autoscaling_max_read_capacity"
    }

    precondition {
      condition     = !local.is_provisioned || (var.write_capacity >= var.autoscaling_min_write_capacity && var.write_capacity <= var.autoscaling_max_write_capacity)
      error_message = "For PROVISIONED mode, write_capacity must be between autoscaling_min_write_capacity and autoscaling_max_write_capacity"
    }
  }
}

# Autoscaling for read capacity
resource "aws_appautoscaling_target" "read_target" {
  count = local.is_provisioned ? 1 : 0

  max_capacity       = var.autoscaling_max_read_capacity
  min_capacity       = var.autoscaling_min_read_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read_policy" {
  count = local.is_provisioned ? 1 : 0

  name               = "${var.table_name}-read-capacity-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.autoscaling_target_value
  }
}

# Autoscaling for write capacity
resource "aws_appautoscaling_target" "write_target" {
  count = local.is_provisioned ? 1 : 0

  max_capacity       = var.autoscaling_max_write_capacity
  min_capacity       = var.autoscaling_min_write_capacity
  resource_id        = "table/${aws_dynamodb_table.main.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write_policy" {
  count = local.is_provisioned ? 1 : 0

  name               = "${var.table_name}-write-capacity-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.autoscaling_target_value
  }
}