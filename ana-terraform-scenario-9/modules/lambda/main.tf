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
  name = "${var.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags = var.tags
}

# CloudWatch Logs policy
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# X-Ray tracing policy
resource "aws_iam_role_policy_attachment" "lambda_xray" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# DynamoDB policy
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.function_name}-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [var.dynamodb_table_arn]
      }
    ]
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# Lambda Function
resource "aws_lambda_function" "function" {
  filename         = "${path.module}/function.zip"
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = var.runtime
  memory_size     = var.memory_size
  timeout         = var.timeout
  
  environment {
    variables = merge(
      {
        DYNAMODB_TABLE = var.dynamodb_table_name
        NODE_OPTIONS   = "--enable-source-maps"
        AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
      },
      var.environment_variables
    )
  }

  tracing_config {
    mode = "Active"
  }

  tags = var.tags

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

# Lambda Function URL (optional)
resource "aws_lambda_function_url" "url" {
  count = var.enable_function_url ? 1 : 0

  function_name      = aws_lambda_function.function.function_name
  authorization_type = var.function_url_authorization

  cors {
    allow_credentials = true
    allow_origins     = length(var.allowed_origins) > 0 ? var.allowed_origins : ["*"]
    allow_methods     = ["POST"]
    allow_headers     = ["*"]
    expose_headers    = ["*"]
    max_age          = 86400
  }
}

# Lambda source code
resource "local_file" "function_code" {
  filename = "${path.module}/src/index.js"
  content  = <<-EOT
const AWSXRay = require('aws-xray-sdk-core');
const AWS = AWSXRay.captureAWS(require('aws-sdk'));
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  try {
    const body = JSON.parse(event.body || '{}');
    const timestamp = new Date().toISOString();
    const id = context.awsRequestId;

    // Add request metadata for tracing
    const requestMetadata = {
      requestId: context.awsRequestId,
      functionVersion: context.functionVersion,
      functionName: context.functionName,
      memoryLimitInMB: context.memoryLimitInMB,
      remainingTime: context.getRemainingTimeInMillis(),
    };

    // Store item in DynamoDB with metadata
    const item = {
      id,
      timestamp,
      requestMetadata,
      ...body,
    };

    const startTime = Date.now();
    await dynamodb.put({
      TableName: process.env.DYNAMODB_TABLE,
      Item: item
    }).promise();
    const endTime = Date.now();

    // Log operation metrics
    console.log('Operation metrics:', {
      operation: 'putItem',
      tableName: process.env.DYNAMODB_TABLE,
      latencyMs: endTime - startTime,
      itemSize: JSON.stringify(item).length,
      requestId: context.awsRequestId
    });

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        message: 'Item stored successfully',
        id,
        timestamp,
        requestMetadata
      })
    };
  } catch (error) {
    console.error('Error:', {
      message: error.message,
      stack: error.stack,
      requestId: context.awsRequestId
    });
    
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        message: 'Internal server error',
        error: error.message,
        requestId: context.awsRequestId
      })
    };
  }
};
EOT
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/function.zip"
  source {
    content  = local_file.function_code.content
    filename = "index.js"
  }

  depends_on = [local_file.function_code]
}