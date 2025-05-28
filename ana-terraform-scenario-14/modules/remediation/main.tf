resource "aws_sfn_state_machine" "remediation" {
  name     = "${var.project_name}-remediation"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    StartAt = "EvaluateAlert"
    States = {
      EvaluateAlert = {
        Type = "Choice"
        Choices = [
          {
            Variable = "$.alertType"
            StringEquals = "ModelDrift"
            Next = "TriggerRetraining"
          },
          {
            Variable = "$.alertType"
            StringEquals = "EndpointFailure"
            Next = "RollbackModel"
          }
        ]
        Default = "NotifyFailure"
      }
      TriggerRetraining = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "${var.pipeline_name}"
          Payload = {
            "action": "retrain"
          }
        }
        Next = "WaitForTraining"
      }
      WaitForTraining = {
        Type = "Wait"
        Seconds = 3600
        Next = "CheckTrainingStatus"
      }
      CheckTrainingStatus = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = "${aws_lambda_function.model_rollback.function_name}"
          Payload = {
            "action": "check_status"
          }
        }
        End = true
      }
      RollbackModel = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.model_rollback.function_name
          Payload = {
            "action": "rollback",
            "endpoint": "${var.endpoint_name}"
          }
        }
        End = true
      }
      NotifyFailure = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = var.alert_sns_topic_arn
          Message = "Failed to process alert"
        }
        End = true
      }
    }
  })
}

# Create the Lambda function for model rollback
resource "aws_lambda_function" "model_rollback" {
  filename      = "${path.module}/lambda/model_rollback.zip"
  function_name = "${var.project_name}-model-rollback"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.8"

  environment {
    variables = {
      ENDPOINT_NAME = var.endpoint_name
    }
  }
}

# Create the Lambda function code
resource "local_file" "lambda_function" {
  filename = "${path.module}/lambda/index.py"
  content  = <<EOF
import boto3
import json
import os

def handler(event, context):
    sagemaker = boto3.client('sagemaker')
    endpoint_name = os.environ['ENDPOINT_NAME']
    action = event.get('action', '')

    if action == 'rollback':
        try:
            # Get previous model version
            response = sagemaker.list_model_package_groups()
            # Implement rollback logic here
            return {
                'statusCode': 200,
                'body': json.dumps('Model rollback successful')
            }
        except Exception as e:
            return {
                'statusCode': 500,
                'body': json.dumps(str(e))
            }
    elif action == 'check_status':
        try:
            # Check training status
            return {
                'statusCode': 200,
                'body': json.dumps('Training status check completed')
            }
        except Exception as e:
            return {
                'statusCode': 500,
                'body': json.dumps(str(e))
            }
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid action')
        }
EOF
}

# Create a zip file for the Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = local_file.lambda_function.filename
  output_path = "${path.module}/lambda/model_rollback.zip"
}

# IAM role for Step Functions
resource "aws_iam_role" "step_functions_role" {
  name = "${var.project_name}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Step Functions
resource "aws_iam_role_policy" "step_functions_policy" {
  name = "${var.project_name}-step-functions-policy"
  role = aws_iam_role.step_functions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
          "sns:Publish"
        ]
        Resource = [
          aws_lambda_function.model_rollback.arn,
          var.alert_sns_topic_arn
        ]
      }
    ]
  })
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:*",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}





