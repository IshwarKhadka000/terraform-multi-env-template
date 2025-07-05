.SHELLFLAGS = -ec

# Default environment
ENV := dev

# Terraform directory and arguments
TF_DIR := .
TF_PLAN_ARGS :=
TF_APPLY_ARGS :=
TF_DESTROY_ARGS :=

# Environment configuration - all variables come from environment or GitHub variables

.PHONY: clean init format lint scan plan build apply destroy help
all: clean init format lint scan plan build

validate-env: ## Validate required environment variables
	@echo "Validating environment variables..."
	@if [ -z "$(ENV)" ]; then \
		echo "Error: ENV environment variable is required!"; \
		echo "Usage: make <target> ENV=<environment>"; \
		exit 1; \
	fi
	@echo "Environment validation passed: ENV=$(ENV)"

generate-configs: validate-env ## Generate backend.hcl and variables.tfvars from templates
	@echo "Generating configuration files for environment: $(ENV)..."
	@mkdir -p $(TF_DIR)
	@cat backend.hcl.tpl | envsubst > $(TF_DIR)/backend.hcl
	@cat variables.tfvars.tpl | envsubst > $(TF_DIR)/variables.tfvars
	@echo "Configuration files generated:"
	@echo "  - $(TF_DIR)/backend.hcl"
	@echo "  - $(TF_DIR)/variables.tfvars"

init: generate-configs ## Initialize Terraform backend and modules
	@echo "Initializing Terraform..."
	@cd $(TF_DIR); terraform init --backend-config=backend.hcl
	@echo "Terraform initialization complete."

format: ## Format code
	@echo "Formatting code..."
	@cd $(TF_DIR); terraform fmt -recursive
	@echo "Formatting complete."

lint: init ## Check if code is properly formatted and valid
	@echo "Linting code..."
	@cd $(TF_DIR); terraform fmt -check -diff .
	@cd $(TF_DIR); tflint
	@cd $(TF_DIR); terraform validate .
	@echo "Linting complete."

tflint:
	@echo "Running tflint..."
	@cd $(TF_DIR); tflint
	@echo "Running tflint complete."

fmt:
	@echo "Running terraform fmt..."
	@cd $(TF_DIR); terraform fmt -check -diff .
	@echo "Running terraform fmt complete."

validate:
	@echo "Running terraform validate..."
	@cd $(TF_DIR); terraform validate .
	@echo "Running terraform validate complete."

# scan: init ## Scan code for potential security misconfigurations
# 	@echo "Running static Terraform security scan..."
# 	@cd $(TF_DIR); tfsec . --config-file ../.tfsec.yml --exclude-downloaded-modules
# 	@echo "Static security scan complete."

plan: init ## Run Terraform plan
	@echo "Running Terraform plan for environment: $(ENV)..."
	@cd $(TF_DIR); terraform plan -var-file=variables.tfvars $(TF_PLAN_ARGS)
	@echo "Terraform planning complete."

apply: init ## Apply terraform changes
	@echo "Applying Terraform changes for environment: $(ENV)..."
	@cd $(TF_DIR); terraform apply -var-file=variables.tfvars $(TF_APPLY_ARGS)
	@echo "Terraform apply complete."

destroy: init ## Destroy terraform changes
	@echo "Destroying Terraform infrastructure for environment: $(ENV)..."
	@cd $(TF_DIR); terraform destroy -var-file=variables.tfvars $(TF_DESTROY_ARGS)
	@echo "Terraform destroy complete."

show-env: ## Show current environment variables
	@echo "Current environment configuration:"
	@echo "  ENV: $(ENV)"
	@echo "  TF_DIR: $(TF_DIR)"
	@echo ""
	@echo "Required environment variables:"
	@echo "  ENV - Environment name (dev, staging, prod, etc.)"
	@echo ""
	@echo "Note: Only ENV is dynamically injected from GitHub variables."
	@echo "All other configuration values are hardcoded in templates."

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'