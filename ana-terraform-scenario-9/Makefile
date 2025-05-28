.PHONY: init plan apply destroy test clean format validate security-check load-test help

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform
	terraform init

plan: ## Plan Terraform changes
	terraform plan -out=tfplan

apply: ## Apply Terraform changes
	terraform apply tfplan

destroy: ## Destroy all resources
	terraform destroy

test: ## Run all tests
	npm test

clean: ## Clean up local files
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	rm -f tfplan
	rm -rf node_modules
	rm -f package-lock.json
	rm -f load-test-report.json

format: ## Format code
	terraform fmt -recursive
	prettier --write "*.{js,json,md}"

validate: ## Validate code
	terraform validate
	pre-commit run --all-files

security-check: ## Run security checks
	checkov -d .
	tfsec .

load-test: ## Run load tests
	@if [ -z "$$API_ENDPOINT" ]; then \
		echo "Error: API_ENDPOINT environment variable is required"; \
		exit 1; \
	fi
	npm test

deploy: init plan apply ## Deploy infrastructure

full-test: deploy load-test ## Deploy and test infrastructure

setup: ## Setup development environment
	pre-commit install
	npm install

update: ## Update dependencies
	npm update
	terraform init -upgrade

logs: ## View CloudWatch logs
	@if [ -z "$$FUNCTION_NAME" ]; then \
		FUNCTION_NAME=$$(terraform output -raw lambda_function_name); \
	fi
	aws logs tail "/aws/lambda/$$FUNCTION_NAME" --follow

dashboard: ## Open CloudWatch dashboard
	@DASHBOARD_URL=$$(terraform output -raw cloudwatch_dashboard_url); \
	if command -v xdg-open > /dev/null; then \
		xdg-open "$$DASHBOARD_URL"; \
	elif command -v open > /dev/null; then \
		open "$$DASHBOARD_URL"; \
	else \
		echo "Dashboard URL: $$DASHBOARD_URL"; \
	fi

# Variables
export AWS_REGION ?= ap-south-1
export TF_VAR_environment ?= dev
export CONCURRENT_USERS ?= 50
export REQUESTS_PER_USER ?= 20