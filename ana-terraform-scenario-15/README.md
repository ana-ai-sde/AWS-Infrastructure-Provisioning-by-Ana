# Enterprise Observability Platform

This repository contains Terraform configurations for deploying an enterprise-scale observability platform that unifies monitoring across cloud and on-premises environments using OpenTelemetry.

## Architecture

The platform consists of the following components:

- OpenTelemetry Collectors for data ingestion and processing
- Grafana Tempo for distributed tracing
- Grafana Loki for log aggregation
- Prometheus for metrics storage
- Grafana for visualization and alerting
- SLO/SLA monitoring with error budget tracking

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0.0
- kubectl configured to access your Kubernetes cluster
- Helm 3.x

## Module Structure

- `core_infrastructure/`: AWS VPC and EKS cluster setup
- `otel_collector/`: OpenTelemetry collector deployment and configuration
- `observability_stack/`: Tempo, Loki, and Grafana deployment
- `monitoring/`: SLO configurations and Grafana dashboards

## Setup Instructions

1. Configure AWS credentials:
```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
```

2. Initialize Terraform:
```bash
terraform init
```

3. Create a terraform.tfvars file:
```hcl
aws_region = "us-west-2"
environment = "prod"
vpc_cidr = "10.0.0.0/16"
cluster_name = "observability-cluster"
grafana_url = "http://grafana.your-domain.com"
grafana_auth_key = "your-grafana-api-key"
```

4. Apply the configuration:
```bash
terraform plan
terraform apply
```

## SLO Configuration

The platform comes with pre-configured SLO dashboards and alerts:

- Availability SLO: 99.9%
- Latency SLO: P95 < 200ms
- Error Budget: Alerts trigger when error budget consumption exceeds thresholds

## Adding New Services

1. Deploy the OpenTelemetry agent to your service
2. Configure the agent to send data to the collector
3. Add service-specific SLOs in terraform.tfvars
4. Apply the changes using Terraform

## Monitoring and Alerting

- Access Grafana dashboards at the configured URL
- SLO breaches trigger alerts via configured channels
- Error budget consumption is tracked and visualized

## Maintenance

Regular maintenance tasks:

1. Monitor S3 bucket usage for Tempo and Loki
2. Review and adjust SLO thresholds as needed
3. Update OpenTelemetry collector configurations for new requirements
4. Rotate access credentials periodically

## Support

For issues or questions, please open a GitHub issue in this repository.