# Self-Healing ML Pipeline Infrastructure

This repository contains Terraform code for deploying a self-healing ML pipeline on AWS using SageMaker Pipelines, Feature Store, and Model Registry. The infrastructure includes automated drift detection, monitoring, and remediation capabilities.

## Architecture Overview

The infrastructure consists of the following components:

1. **Feature Store Module**: Manages SageMaker Feature Store groups for storing and serving ML features
2. **SageMaker Pipeline Module**: Defines the ML training pipeline and model registry
3. **Monitoring Module**: Sets up CloudWatch dashboards and SageMaker Model Monitor
4. **Alerting Module**: Configures SNS topics for alerts and notifications
5. **Remediation Module**: Implements Step Functions workflow for automated remediation

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- Python >= 3.8 (for Lambda functions)

## Directory Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf             # Output definitions
├── modules/
│   ├── feature_store/     # Feature Store module
│   ├── sagemaker_pipeline/# SageMaker Pipeline module
│   ├── monitoring/        # Monitoring module
│   ├── alerting/         # Alerting module
│   └── remediation/      # Remediation module
└── README.md
```

## Deployment

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the deployment plan:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Self-Healing Capabilities

The infrastructure includes the following self-healing features:

1. **Model Drift Detection**: Automated monitoring of model performance metrics
2. **Automated Retraining**: Triggers model retraining when drift is detected
3. **Rollback Mechanism**: Automatically rolls back to previous model versions on failure
4. **Alert Notification**: SNS notifications for critical events

## Monitoring and Maintenance

- CloudWatch dashboard: Available at the URL provided in the outputs
- SNS topic: Subscribe to receive alerts and notifications
- SageMaker Model Monitor: Regular monitoring of model performance

## Security Considerations

- IAM roles follow the principle of least privilege
- All sensitive data is stored in Feature Store with encryption
- Network access is restricted using security groups
- CloudWatch logs are encrypted

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License