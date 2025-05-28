# Serverless API with Terraform

A production-ready, fully event-driven serverless architecture on AWS using Lambda, API Gateway, and DynamoDB, configured with Terraform and comprehensive observability.

## Features

- **API Gateway**
  - IAM-based authentication
  - Request validation
  - Rate limiting and throttling
  - CORS configuration
  - Structured logging

- **Lambda Function**
  - Node.js runtime with source maps
  - X-Ray tracing integration
  - Comprehensive error handling
  - Environment variable management
  - Connection reuse enabled

- **DynamoDB**
  - Auto-scaling configuration
  - Point-in-time recovery
  - Server-side encryption
  - Flexible billing modes
  - Optimized capacity management

- **Observability**
  - CloudWatch dashboard
  - X-Ray tracing
  - Custom metrics
  - Automated alarms
  - SNS notifications
  - Structured logging

- **Load Testing**
  - Concurrent user simulation
  - Latency percentiles
  - Error tracking
  - Detailed reporting
  - Warmup phase

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.2.0
- Node.js >= 16.x
- pre-commit (optional, for development)

## Quick Start

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. Install pre-commit hooks (optional):
   ```bash
   pre-commit install
   ```

3. Deploy the infrastructure:
   ```bash
   ./deploy.sh
   ```

4. Run a load test:
   ```bash
   export API_ENDPOINT=$(terraform output -raw api_endpoint)
   npm test
   ```

## Configuration

### Infrastructure Configuration (terraform.tfvars)

```hcl
aws_region = "ap-south-1"
environment = "dev"
project_name = "serverless-api"

# Lambda Configuration
lambda_memory = 256
lambda_timeout = 30
enable_xray = true

# API Gateway Configuration
enable_api_key_auth = false  # Use IAM authentication

# DynamoDB Configuration
dynamodb_billing_mode = "PROVISIONED"

# Optional: Set email for alarm notifications
# alarm_email = "your.email@example.com"
```

### Load Test Configuration

Set environment variables to customize the load test:

```bash
export CONCURRENT_USERS=50           # Number of concurrent users
export REQUESTS_PER_USER=20         # Requests per user
export DELAY_BETWEEN_REQUESTS=100   # Delay in milliseconds
export WARMUP_REQUESTS=5            # Number of warmup requests
export REPORT_FILE="report.json"    # Custom report filename
```

## Module Structure

```
.
├── modules/
│   ├── api_gateway/    # API Gateway configuration
│   ├── dynamodb/      # DynamoDB table and auto-scaling
│   ├── lambda/        # Lambda function and IAM roles
│   └── observability/ # Monitoring and alerting
├── load-test.js       # Load testing script
├── deploy.sh          # Deployment script
├── cleanup.sh         # Resource cleanup script
└── terraform.tfvars   # Configuration variables
```

## Monitoring and Observability

### CloudWatch Dashboard

Access the dashboard:
```bash
terraform output -raw cloudwatch_dashboard_url
```

### Available Metrics

- Lambda:
  - Invocations
  - Errors
  - Duration (p95)
  - Throttles
  - Memory usage

- API Gateway:
  - Requests
  - Latency (p95)
  - 4XX/5XX errors
  - Integration latency

- DynamoDB:
  - Read/Write capacity
  - Throttled requests
  - System errors

### Alarms

- Lambda function errors
- API Gateway latency
- API Gateway 4XX/5XX errors
- DynamoDB throttles

## Load Testing

The load testing script provides:

- Concurrent user simulation
- Latency percentiles (p50, p90, p95, p99)
- Error tracking and reporting
- Request rate metrics
- JSON report generation

### Sample Load Test Output

```
Load Test Results:
==================
Total Requests: 1000
Success Rate: 99.8%
Requests/Second: 95.2
Duration: 10.5s

Latency (ms):
  Min: 45.2
  Avg: 89.7
  P50: 82.3
  P90: 125.6
  P95: 156.8
  P99: 198.4
  Max: 245.6
```

## Cleanup

To remove all resources:

```bash
./cleanup.sh
```

## Security Considerations

- IAM authentication for API access
- Encryption at rest for DynamoDB
- X-Ray tracing for request tracking
- CloudWatch logs retention
- API request validation
- Rate limiting and throttling

## Development

### Pre-commit Hooks

Install pre-commit hooks to ensure code quality:

```bash
pre-commit install
```

This will run:
- Terraform formatting
- Terraform validation
- Security checks (checkov)
- JavaScript formatting
- YAML/JSON validation

### Best Practices

1. Always use `terraform plan` before applying changes
2. Review CloudWatch logs for issues
3. Monitor the dashboard for performance metrics
4. Run load tests after significant changes
5. Keep dependencies updated

## Troubleshooting

1. **API Gateway 5XX Errors**
   - Check Lambda function logs
   - Verify IAM roles and permissions
   - Review X-Ray traces

2. **DynamoDB Throttling**
   - Check CloudWatch metrics
   - Review auto-scaling settings
   - Consider increasing capacity

3. **Lambda Cold Starts**
   - Adjust memory allocation
   - Review function size
   - Consider provisioned concurrency

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.