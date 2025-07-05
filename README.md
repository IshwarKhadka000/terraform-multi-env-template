# Terraform Multi-Environment Starter Template

A simple and clean Terraform starter template for managing infrastructure across multiple environments (dev, staging, prod, qa, uat) with dynamic environment injection.

## Features

- **Dynamic Backend Configuration**: Automatically generates `backend.hcl` files for each environment
- **Environment-Specific Variables**: Generates `variables.tfvars` files with only the environment variable
- **Multi-Environment Support**: Easy switching between dev, staging, prod, qa, uat
- **Template-Based Configuration**: Uses `envsubst` for variable substitution
- **Resource Naming**: All resources are named using the environment variable
- **GitHub Integration**: Environment name injected from GitHub repository variables
- **No Complex Scopes**: Simple environment-based approach

## Project Structure

```
terraform-multienvs/
├── Makefile                   # Main build automation
├── backend.hcl.tpl            # Backend configuration template
├── variables.tfvars.tpl       # Variables template
├── s3.tf                      # S3 bucket configuration (example)
├── providers.tf               # AWS provider configuration
└── README.md                  # This file
```

## Quick Start

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- `envsubst` command (usually available with gettext)
- Make

### 1. Clone and Setup

```bash
git clone <your-repo>
cd terraform-multienvs
```

### 2. Configure AWS Credentials

```bash
aws configure
# or set environment variables
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=ap-south-1
```

### 3. Initialize for Development Environment

```bash
make init ENV=dev
```

### 4. Plan Changes

```bash
make plan ENV=dev
```

### 5. Apply Changes

```bash
make apply ENV=dev
```

## Environment Configuration

The environment name (`ENV`) is dynamically injected from GitHub repository variables. All other configuration values are hardcoded in the templates.

### Required Environment Variables

- `ENV`: Environment name (dev, staging, prod, qa, uat) - **Injected from GitHub**

### Configuration Values

All configuration values are hardcoded in the Terraform code:

- **Project**: `project-name`
- **AWS Region**: `ap-south-1`
- **State Bucket**: `my-terraform-state-bucket`
- **Resource Naming**: All resources use `${project_name}-${environment}` prefix

## Makefile Targets

| Target | Description |
|--------|-------------|
| `show-env` | Show current environment configuration |
| `generate-configs` | Generate backend.hcl and variables.tfvars |
| `init` | Initialize Terraform backend and modules |
| `plan` | Run Terraform plan |
| `apply` | Apply Terraform changes |
| `destroy` | Destroy Terraform infrastructure |
| `clean` | Remove local artifacts |
| `format` | Format Terraform code |
| `lint` | Lint and validate Terraform code |
| `scan` | Security scan with tfsec |

## Usage Examples

### Switch Between Environments

```bash
# Development
make plan ENV=dev

# Staging
make plan ENV=staging

# Production
make plan ENV=prod

# QA
make plan ENV=qa

# UAT
make plan ENV=uat
```

### Add a New Environment

Simply use a new environment name - no configuration files needed:

```bash
make plan ENV=test
```

### Custom Terraform Arguments

```bash
# Plan with specific variables
make plan ENV=dev TF_PLAN_ARGS="-var='custom_var=value'"

# Apply with auto-approve
make apply ENV=dev TF_APPLY_ARGS="-auto-approve"
```

## Example: S3 Bucket Configuration

The included `s3.tf` file demonstrates conditional resource creation:

```hcl
locals {
  # Create bucket only in dev and uat, not in qa
  create_bucket = contains(["dev", "uat"], var.environment) ? 1 : 0
}

resource "aws_s3_bucket" "app_bucket" {
  count  = local.create_bucket
  bucket = "${local.name_prefix}-app-bucket"
}
```

This creates S3 buckets only in `dev` and `uat` environments, but not in `qa`.

## Template Variables

### Backend Template (`backend.hcl.tpl`)
Only uses `ENV` environment variable:
- `ENV`: Environment name (injected from GitHub)

### Variables Template (`variables.tfvars.tpl`)
Only contains the environment variable:
- `environment`: Environment name (injected from GitHub)

All other values are hardcoded in the Terraform code and use the environment variable for resource naming.

## Security Considerations

- Store sensitive values in environment variables or AWS Secrets Manager
- Use different AWS accounts/profiles for different environments
- Enable encryption for S3 buckets and DynamoDB tables
- Use least-privilege IAM policies

## Troubleshooting

### Environment Variable Issues
```bash
make show-env  # Check current environment configuration
```

### Backend Configuration Issues
```bash
make clean ENV=dev
make init ENV=dev
```

### Variable Substitution Issues
Ensure the `ENV` environment variable is set correctly.

## GitHub Actions Integration

Add this to your GitHub repository variables:
- `ENV`: Set to your target environment (dev, staging, prod, qa, uat)

Example workflow:
```yaml
name: Terraform
on: [push, pull_request]
env:
  ENV: ${{ github.ref_name == 'main' && 'prod' || 'dev' }}
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
      - name: Terraform Init
        run: make init ENV=${{ env.ENV }}
      - name: Terraform Plan
        run: make plan ENV=${{ env.ENV }}
``` 