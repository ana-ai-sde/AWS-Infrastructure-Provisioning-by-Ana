resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# Enable CloudWatch logging
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "${var.api_name}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "${var.api_name}-cloudwatch-policy"
  role = aws_iam_role.cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# API resources and methods
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "POST"
  authorization    = var.authorization_type == "API_KEY" ? "NONE" : "AWS_IAM"
  api_key_required = var.authorization_type == "API_KEY"

  request_parameters = {
    "method.request.header.X-Request-ID" = true
  }

  request_validator_id = aws_api_gateway_request_validator.validator.id

  request_models = {
    "application/json" = aws_api_gateway_model.request_model.name
  }
}

# Request validation
resource "aws_api_gateway_request_validator" "validator" {
  name                        = "${var.api_name}-validator"
  rest_api_id                = aws_api_gateway_rest_api.api.id
  validate_request_body      = true
  validate_request_parameters = true
}

# Request model
resource "aws_api_gateway_model" "request_model" {
  rest_api_id  = aws_api_gateway_rest_api.api.id
  name         = "RequestModel"
  description  = "JSON Schema for request validation"
  content_type = "application/json"

  schema = jsonencode({
    type = "object"
    required = ["data"]
    properties = {
      data = {
        type = "object"
      }
    }
  })
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_invoke_arn

  request_parameters = {
    "integration.request.header.X-Request-ID" = "method.request.header.X-Request-ID"
  }
}

# CORS configuration
resource "aws_api_gateway_method" "options" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Request-ID'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = length(var.allowed_origins) > 0 ? "'${join(",", var.allowed_origins)}'" : "'*'"
  }
}

# API Gateway stage and deployment
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id  = aws_api_gateway_rest_api.api.id
  stage_name   = var.stage_name

  xray_tracing_enabled = var.xray_tracing_enabled

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId              = "$context.requestId"
      ip                     = "$context.identity.sourceIp"
      caller                = "$context.identity.caller"
      user                  = "$context.identity.user"
      requestTime           = "$context.requestTime"
      httpMethod            = "$context.httpMethod"
      resourcePath          = "$context.resourcePath"
      status                = "$context.status"
      protocol              = "$context.protocol"
      responseLength        = "$context.responseLength"
      integrationError      = "$context.integration.error"
      integrationStatus     = "$context.integration.status"
      integrationLatency    = "$context.integration.latency"
      integrationRequestId  = "$context.integration.requestId"
      xrayTraceId           = "$context.xrayTraceId"
      authorizerError       = "$context.authorizer.error"
      authorizerLatency     = "$context.authorizer.latency"
      authorizerStatus      = "$context.authorizer.status"
    })
  }

  tags = var.tags
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = var.metrics_enabled
    logging_level         = var.logging_level
    data_trace_enabled    = var.logging_level == "INFO"
    throttling_rate_limit  = var.throttling_rate_limit
    throttling_burst_limit = var.throttling_burst_limit
  }
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.options,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch log group
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = 14
  tags              = var.tags
}

# Lambda permission
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}