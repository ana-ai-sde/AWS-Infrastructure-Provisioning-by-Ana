output "feature_group_names" {
  description = "Names of created feature groups"
  value       = [for fg in aws_sagemaker_feature_group.feature_group : fg.feature_group_name]
}

output "feature_store_bucket" {
  description = "S3 bucket for feature store"
  value       = aws_s3_bucket.feature_store.id
}