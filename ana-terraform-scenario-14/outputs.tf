output "feature_store_groups" {
  description = "Created Feature Store groups"
  value       = module.feature_store.feature_group_names
}

output "pipeline_arn" {
  description = "ARN of the created SageMaker pipeline"
  value       = module.sagemaker_pipeline.pipeline_arn
}

output "endpoint_name" {
  description = "Name of the deployed SageMaker endpoint"
  value       = module.sagemaker_pipeline.endpoint_name
}

output "monitoring_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_url
}

output "alert_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.alerting.sns_topic_arn
}