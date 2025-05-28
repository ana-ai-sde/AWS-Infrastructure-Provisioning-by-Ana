variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_helm_chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "5.46.7"
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  type        = string
}

variable "enable_dex" {
  description = "Enable Dex for OIDC authentication"
  type        = bool
  default     = false
}

variable "oidc_config" {
  description = "OIDC configuration for Dex"
  type        = string
  default     = ""
}

variable "repositories" {
  description = "ArgoCD repository configurations"
  type        = string
  default     = ""
}

variable "gitops_repo_url" {
  description = "URL of the GitOps repository"
  type        = string
}

variable "gitops_repo_path" {
  description = "Path in the GitOps repository for system components"
  type        = string
  default     = "clusters/production"
}