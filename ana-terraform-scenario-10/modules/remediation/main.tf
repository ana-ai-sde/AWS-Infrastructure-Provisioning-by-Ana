data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "ec2-remediation-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Name    = "EC2 Remediation Lambda Role"
    Purpose = "Automated SRE Response System"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "ec2-remediation-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:RebootInstances",
          "ec2:DescribeInstances",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "sns:Publish"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# Create a CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14

  tags = {
    Name    = "EC2 Remediation Lambda Logs"
    Purpose = "Automated SRE Response System"
  }
}

locals {
  lambda_code = <<EOF
import boto3
import json
import os
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    instance_id = os.environ['INSTANCE_ID']
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    
    ec2 = boto3.client('ec2')
    sns = boto3.client('sns')
    
    logger.info(f"Starting remediation for instance {instance_id}")
    
    try:
        # Get instance state
        instance_state = ec2.describe_instances(InstanceIds=[instance_id])['Reservations'][0]['Instances'][0]['State']['Name']
        logger.info(f"Current instance state: {instance_state}")
        
        # Reboot only if instance is running
        if instance_state == 'running':
            logger.info(f"Initiating reboot for instance {instance_id}")
            ec2.reboot_instances(InstanceIds=[instance_id])
            message = f"Successfully initiated reboot for instance {instance_id}"
        else:
            message = f"Instance {instance_id} is in {instance_state} state, skipping reboot"
        
        # Send notification
        logger.info(f"Sending SNS notification: {message}")
        sns.publish(
            TopicArn=sns_topic_arn,
            Subject="EC2 Remediation Action Status",
            Message=message
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': message,
                'instanceId': instance_id,
                'initialState': instance_state
            })
        }
    except Exception as e:
        error_message = f"Error during remediation: {str(e)}"
        logger.error(error_message)
        sns.publish(
            TopicArn=sns_topic_arn,
            Subject="EC2 Remediation Action Failed",
            Message=error_message
        )
        raise e
EOF
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source {
    content  = local.lambda_code
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "remediation" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 128

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      INSTANCE_ID    = var.instance_id
      SNS_TOPIC_ARN  = var.sns_topic_arn
    }
  }

  tags = {
    Name    = "EC2 Remediation Lambda"
    Purpose = "Automated SRE Response System"
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
    aws_iam_role_policy.lambda_policy
  ]
}

# CloudWatch metric alarm for Lambda errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors lambda function errors"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    FunctionName = aws_lambda_function.remediation.function_name
  }

  tags = {
    Name    = "Lambda Error Alarm"
    Purpose = "Automated SRE Response System"
  }
}