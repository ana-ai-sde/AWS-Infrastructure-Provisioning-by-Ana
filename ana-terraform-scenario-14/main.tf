provider "aws" {
  region = var.aws_region
}

module "feature_store" {
  source = "./modules/feature_store"

  environment    = var.environment
  project_name   = var.project_name
  feature_groups = var.feature_groups
}

module "sagemaker_pipeline" {
  source = "./modules/sagemaker_pipeline"

  environment              = var.environment
  project_name             = var.project_name
  pipeline_name            = var.pipeline_name
  model_package_group_name = var.model_package_group_name
  feature_group_names      = module.feature_store.feature_group_names
}

module "monitoring" {
  source = "./modules/monitoring"

  environment         = var.environment
  project_name        = var.project_name
  endpoint_name       = module.sagemaker_pipeline.endpoint_name
  alert_sns_topic_arn = module.alerting.sns_topic_arn
}

module "alerting" {
  source = "./modules/alerting"

  environment  = var.environment
  project_name = var.project_name
}

module "remediation" {
  source = "./modules/remediation"

  environment         = var.environment
  project_name        = var.project_name
  pipeline_name       = var.pipeline_name
  endpoint_name       = module.sagemaker_pipeline.endpoint_name
  alert_sns_topic_arn = module.alerting.sns_topic_arn
}