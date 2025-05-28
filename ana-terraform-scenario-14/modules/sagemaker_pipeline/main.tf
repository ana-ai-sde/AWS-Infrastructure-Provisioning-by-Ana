resource "aws_sagemaker_model_package_group" "model_group" {
  model_package_group_name = var.model_package_group_name
  model_package_group_description = "Model package group for ${var.project_name}"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sagemaker_pipeline" "training_pipeline" {
  pipeline_name = var.pipeline_name
  pipeline_display_name = "${var.pipeline_name}-display"
  pipeline_definition = jsonencode({
    Version = "2020-12-01"
    Parameters = [
      {
        Name = "ProcessingInstanceType"
        Type = "String"
        DefaultValue = "ml.m5.xlarge"
      },
      {
        Name = "TrainingInstanceType"
        Type = "String"
        DefaultValue = "ml.m5.xlarge"
      }
    ]
    Steps = [
      {
        Name = "PreprocessData"
        Type = "Processing"
        Arguments = {
          ProcessingResources = {
            ClusterConfig = {
              InstanceCount = 1
              InstanceType = "ml.m5.xlarge"
            }
          }
        }
      },
      {
        Name = "TrainModel"
        Type = "Training"
        Arguments = {
          AlgorithmSpecification = {
            TrainingImage = "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.0-1"
            TrainingInputMode = "File"
          }
          ResourceConfig = {
            InstanceCount = 1
            InstanceType = "ml.m5.xlarge"
          }
        }
      },
      {
        Name = "EvaluateModel"
        Type = "Processing"
        Arguments = {
          ProcessingResources = {
            ClusterConfig = {
              InstanceCount = 1
              InstanceType = "ml.m5.xlarge"
            }
          }
        }
      }
    ]
  })

  role_arn = aws_iam_role.pipeline_role.arn

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket" "model_artifacts" {
  bucket = "${var.project_name}-model-artifacts-${var.environment}"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "model_artifacts" {
  bucket = aws_s3_bucket.model_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "pipeline_role" {
  name = "${var.project_name}-pipeline-role"

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

resource "aws_iam_role_policy" "pipeline_policy" {
  name = "${var.project_name}-pipeline-policy"
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:*",
          "s3:*",
          "logs:*",
          "ecr:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_sagemaker_model" "model" {
  name = "${var.project_name}-model"
  execution_role_arn = aws_iam_role.pipeline_role.arn

  primary_container {
    image = "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-scikit-learn:1.0-1"
    mode  = "SingleModel"
    environment = {
      SAGEMAKER_PROGRAM = "inference.py"
      SAGEMAKER_SUBMIT_DIRECTORY = "/opt/ml/model"
      SAGEMAKER_CONTAINER_LOG_LEVEL = "20"
      SAGEMAKER_REGION = "us-east-1"
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sagemaker_endpoint_configuration" "endpoint_config" {
  name = "${var.project_name}-endpoint-config"

  production_variants {
    variant_name           = "AllTraffic"
    model_name            = aws_sagemaker_model.model.name
    initial_instance_count = 1
    instance_type         = "ml.t2.medium"
    initial_variant_weight = 1.0
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_sagemaker_endpoint" "endpoint" {
  name                 = "${var.project_name}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.endpoint_config.name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}