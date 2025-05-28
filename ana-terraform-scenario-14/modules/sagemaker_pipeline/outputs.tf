output "pipeline_arn" {
  description = "ARN of the created SageMaker pipeline"
  value       = aws_sagemaker_pipeline.training_pipeline.arn
}

output "endpoint_name" {
  description = "Name of the deployed SageMaker endpoint"
  value       = aws_sagemaker_endpoint.endpoint.name
}