# EKS Platform with GitOps, Policy-as-Code, and Chaos Engineering

This repository contains a production-ready Kubernetes platform on AWS EKS with integrated GitOps, Policy-as-Code, and Chaos Engineering capabilities.

## Architecture Overview

### Infrastructure Components
- **VPC and Networking**: Secure network setup with public and private subnets
- **IAM**: Least-privilege roles and policies
- **EKS**: Managed Kubernetes cluster with private endpoint
- **ArgoCD**: GitOps deployment and management

### Platform Features

#### GitOps (ArgoCD)
- Automated deployment and synchronization
- Multi-environment management (prod/staging/dev)
- Health monitoring and notifications
- Maintenance windows and sync policies

#### Policy Control (OPA Gatekeeper)
- Resource quotas and limits
- Security policies
- Network policies
- RBAC controls

#### Monitoring Stack
- Prometheus for metrics
- Grafana for visualization
- Alertmanager for notifications
- Custom dashboards and alerts

#### Chaos Engineering (LitmusChaos)
- Automated chaos experiments
- Resilience testing
- Scheduled chaos runs
- Result analysis and metrics

## Directory Structure
```
.
├── terraform/
│   ├── modules/
│   │   ├── vpc/         # Network infrastructure
│   │   ├── iam/         # IAM roles and policies
│   │   ├── eks/         # EKS cluster configuration
│   │   └── argocd/      # ArgoCD installation
│   └── environments/
│       └── prod/        # Production environment
├── gitops/
│   ├── apps/           # ArgoCD applications
│   ├── monitoring/     # Monitoring stack
│   ├── policies/       # OPA policies
│   └── chaos/         # Chaos experiments
```

## Environment Management

### Production
- Strict security policies
- Limited sync windows
- Full monitoring
- Weekend chaos testing

### Staging
- Moderate security
- Flexible sync windows
- Full monitoring
- Weekday chaos testing

### Development
- Relaxed security
- Frequent sync windows
- Basic monitoring
- Daily chaos testing

## Maintenance Windows

### Production
- Sunday 1 AM - 5 AM
- Full notification chain
- Automated rollback

### Staging
- Wednesday 1 AM - 5 AM
- Slack notifications
- Manual intervention allowed

### Development
- Daily 1 AM - 3 AM
- Basic notifications
- Quick iterations

## Health Monitoring

### Components Monitored
- Infrastructure health
- Application deployments
- Policy enforcement
- Chaos experiment results

### Notification Channels
- Slack: All environments
- PagerDuty: Production only
- Email: Optional for all

## Getting Started

1. Initialize Terraform:
   ```bash
   cd terraform/environments/prod
   terraform init
   terraform apply
   ```

2. Access ArgoCD:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

3. Monitor Deployments:
   ```bash
   kubectl get applications -n argocd
   ```

## Security Considerations

- Private EKS endpoint
- Network isolation
- Pod security policies
- Image scanning
- RBAC enforcement

## Best Practices

1. **GitOps**
   - Always use Git for changes
   - Review before sync
   - Monitor sync status

2. **Security**
   - Regular policy updates
   - Audit logging
   - Access reviews

3. **Monitoring**
   - Set meaningful alerts
   - Regular dashboard reviews
   - Trend analysis

4. **Chaos Engineering**
   - Start small
   - Increase complexity
   - Document findings

## Troubleshooting

Common issues and solutions are documented in the [Wiki](wiki/).

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.