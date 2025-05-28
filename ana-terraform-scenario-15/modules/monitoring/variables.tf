variable "grafana_url" {
  description = "Grafana instance URL"
  type        = string
}

variable "grafana_auth" {
  description = "Grafana authentication key"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "slo_thresholds" {
  description = "Map of SLO thresholds for different services"
  type = map(object({
    availability = number
    latency_ms   = number
    error_rate   = number
  }))
}