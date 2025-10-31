# Terraform Variables Configuration

This directory contains example Terraform variable files for configuring your AWS infrastructure.

## Setup

1. **Copy the example files:**
   ```bash
   cp infra/aws/prod.tfvars.example infra/aws/prod.tfvars
   cp infra/aws/test.tfvars.example infra/aws/test.tfvars
   ```

2. **Edit the tfvars files** with your actual values:
   - Set `aws_account_id` to your AWS Account ID
   - Set `ssh_public_key` to your SSH public key
   - Set `allowed_ssh_cidr_blocks` to your IP address
   - Change `postgres_password` to a secure password

3. **Use environment variables (alternative):**
   ```bash
   export AWS_ACCOUNT_ID=your-account-id
   export TF_VAR_aws_account_id=your-account-id  # For Terraform
   ```

## Usage

### Using tfvars files:
```bash
cd infra/aws
terraform init
terraform plan -var-file="test.tfvars"
terraform apply -var-file="test.tfvars"
```

### Using environment variables:
```bash
export TF_VAR_aws_account_id=your-account-id
export TF_VAR_postgres_password=your-secure-password
terraform apply
```

## Security Notes

- **Never commit `*.tfvars` files** - they contain sensitive information
- **Use strong passwords** for PostgreSQL
- **Restrict SSH access** in production (`allowed_ssh_cidr_blocks`)
- **Rotate credentials** regularly
- The `.gitignore` file excludes `*.tfvars` files

## Required Variables

The following variables **must** be set (via tfvars or environment):

- `aws_account_id` - Your AWS Account ID
- `ssh_public_key` - Your SSH public key for EC2 access
- `postgres_password` - Database password (use strong password!)

## Optional Variables

All other variables have defaults in `variables.tf` but can be overridden.
