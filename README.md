# AWS Infrastructure Provisioning by Ana

[![Built with ❤️ by Ana](https://img.shields.io/badge/Built%20with%20%E2%9D%A4%EF%B8%8F%20by-Ana-orange)](https://www.openana.ai)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)

A comprehensive collection of **18 production-ready AWS infrastructure scenarios** created by [Ana](https://www.openana.ai), the autonomous AI engineer that revolutionizes software development workflows. These scenarios range from simple deployments to complex enterprise-grade architectures, demonstrating best practices in Infrastructure as Code (IaC).

## 🤖 About Ana

**Ana** is an autonomous AI engineer that collaborates with super-performant engineering teams towards strategic imperatives. Ana specializes in:

- **🔧 Autonomous Engineering**: Your dedicated team member for DevSecOps workflows
- **🛡️ Security Engineering**: Comprehensive security with threat modeling, API security, and vulnerability assessment
- **🚀 SRE/DevOps Engineering**: Automated infrastructure management and monitoring
- **🤖 AI/ML Engineering**: Self-healing ML pipelines with drift detection and automated remediation

### Ana's Impact
- **2x** gain in Delivery Velocity
- **25%** uptick in Innovation Acceleration  
- **ROI** delivered in months
- **70%** uptick in Developer Satisfaction
- **60%** reduction in Development Cost

**Headquarters**: Columbia, MD, USA  
**Tech Center**: New Delhi, India

Learn more at [www.openana.ai](https://www.openana.ai)

## 📋 Scenario Overview

This repository contains **18 carefully crafted AWS scenarios** that demonstrate Ana's capabilities across different complexity levels and use cases:

### 🟢 Simple Scenarios (Complexity: Simple)
| ID | Scenario | Description | Pass Criteria Score |
|----|----------|-------------|-------------------|
| **1** | [Static Website Deployment](./ana-terraform-scenario-1/) | S3 + CloudFront + Route53 static website hosting | 4.5/5 |
| **2** | [EC2 with Monitoring](./ana-terraform-scenario-2/) | Secure EC2 with CloudWatch monitoring and SSH control | 4.0/5 |
| **3** | [Basic VPC Networking](./ana-terraform-scenario-3/) | VPC with public/private subnets and NAT Gateway | 5.0/5 |
| **4** | [CloudWatch URL Monitoring](./ana-terraform-scenario-4/) | External URL monitoring with CloudWatch Synthetics | 4.0/5 |
| **5** | [Scheduled Lambda Function](./ana-terraform-scenario-5/) | Lambda with EventBridge scheduled triggers | 5.0/5 |
| **16** | [Site-to-Site VPN](./ana-terraform-scenario-16/) | AWS VPC to simulated on-premises VPN connection | 4.9/5 |

### 🟡 Medium Scenarios (Complexity: Medium)
| ID | Scenario | Description | Pass Criteria Score |
|----|----------|-------------|-------------------|
| **6** | [Highly Available Web App](./ana-terraform-scenario-6/) | Multi-tier application with ALB, ASG, and RDS | 3.7/5 |
| **7** | [Centralized Logging & Monitoring](./ana-terraform-scenario-7/) | CloudWatch Logs, custom metrics, and dashboards | 4.8/5 |
| **9** | [Serverless API Stack](./ana-terraform-scenario-9/) | Lambda + API Gateway + DynamoDB with auto-scaling | 4.8/5 |
| **10** | [Incident Response Automation](./ana-terraform-scenario-10/) | Automated SRE response workflows with remediation | 4.9/5 |

### 🔴 High Complexity Scenarios
| ID | Scenario | Description | Pass Criteria Score |
|----|----------|-------------|-------------------|
| **13** | [Zero Trust Security](./ana-terraform-scenario-13/) | Full zero-trust architecture with advanced security | 4.0/5 |
| **14** | [Self-Healing ML Pipeline](./ana-terraform-scenario-14/) | SageMaker pipelines with drift detection and auto-remediation | 4.0/5 |
| **15** | [Enterprise Observability](./ana-terraform-scenario-15/) | Hybrid cloud observability with OpenTelemetry | 4.0/5 |
| **18** | [Multi-Region VPN Failover](./ana-terraform-scenario-18/) | HA VPN mesh with automated failover across regions | 4.0/5 |

### 🟣 Super Complex Scenarios
| ID | Scenario | Description | Pass Criteria Score |
|----|----------|-------------|-------------------|
| **12** | [Kubernetes Platform](./ana-terraform-scenario-12/) | EKS with GitOps, Policy-as-Code, and Chaos Engineering | 3.7/5 |

## 🏗️ Repository Structure

```
├── ana-terraform-scenario-1/          # Static Website Deployment
├── ana-terraform-scenario-2/          # EC2 with Monitoring  
├── ana-terraform-scenario-3/          # Basic VPC Networking
├── ana-terraform-scenario-4/          # CloudWatch URL Monitoring
├── ana-terraform-scenario-5/          # Scheduled Lambda Function
├── ana-terraform-scenario-6/          # Highly Available Web App
├── ana-terraform-scenario-7/          # Centralized Logging & Monitoring
├── ana-terraform-scenario-9/          # Serverless API Stack
├── ana-terraform-scenario-10/         # Incident Response Automation
├── ana-terraform-scenario-12/         # Kubernetes Platform
├── ana-terraform-scenario-13/         # Zero Trust Security
├── ana-terraform-scenario-14/         # Self-Healing ML Pipeline
├── ana-terraform-scenario-15/         # Enterprise Observability
├── ana-terraform-scenario-16/         # Site-to-Site VPN
├── ana-terraform-scenario-18/         # Multi-Region VPN Failover
├── ana-terraform-scenario-3-duplicate/ # Alternative VPC implementation
├── ana-placeholder-project/           # Placeholder project
├── ana-terraform-repo/               # General terraform modules
└── AWS_Scenarios_ThirdParty_Evaluation(AWS).csv # Evaluation criteria
```

## 🚀 Getting Started

### Prerequisites
- **Terraform** >= 1.0.0
- **AWS CLI** configured with appropriate credentials
- **AWS Account** with necessary permissions

### Quick Start
1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-org/ana-terraform-scenarios.git
   cd ana-terraform-scenarios
   ```

2. **Choose a scenario**:
   ```bash
   cd ana-terraform-scenario-1  # Example: Static Website
   ```

3. **Initialize and deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Clean up**:
   ```bash
   terraform destroy
   ```

## 📊 Evaluation Metrics

Each scenario has been evaluated across multiple dimensions:

| Metric | Average Score | Description |
|--------|---------------|-------------|
| **Completeness** | 4.4/5 | How well the scenario meets requirements |
| **Accuracy** | 4.3/5 | Technical correctness and best practices |
| **Productivity** | 4.9/5 | Development efficiency and automation |

## 🎯 Use Cases

These scenarios demonstrate Ana's capabilities across various domains:

- **🌐 Web Applications**: Static sites, dynamic web apps, and APIs
- **🔒 Security**: Zero-trust architectures, VPN connections, and monitoring
- **📊 Observability**: Centralized logging, monitoring, and alerting
- **🤖 ML/AI**: Self-healing pipelines and automated model management
- **☸️ Container Orchestration**: Kubernetes platforms with GitOps
- **🔄 Automation**: Incident response and infrastructure remediation

## 🛡️ Security Best Practices

All scenarios implement security best practices including:
- ✅ **Least Privilege Access**: IAM roles with minimal required permissions
- ✅ **Encryption**: Data encryption at rest and in transit
- ✅ **Network Security**: VPC isolation, security groups, and NACLs
- ✅ **Monitoring**: Comprehensive logging and alerting
- ✅ **Compliance**: Following AWS Well-Architected Framework

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Ana Platform**: [www.openana.ai](https://www.openana.ai)
- **Support**: [Contact us](https://www.openana.ai/contact)

## 🙏 Acknowledgments

- Created with ❤️ by the [Ana](https://www.openana.ai) autonomous AI engineering platform
- Inspired by real-world enterprise infrastructure challenges
- Built for the global DevOps and SRE community

---

**Ready to revolutionize your workflow?** [Schedule a demo with Ana](https://www.openana.ai) and experience autonomous engineering in action! 🚀
