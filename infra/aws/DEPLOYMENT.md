# Deployment Guide

This guide explains how to deploy the Composia platform infrastructure using environment-specific configurations.

## 🚀 **Quick Start**

### 1. **Setup Development Environment**
```bash
cd infra/aws
make setup-dev
```

### 2. **Deploy Development Infrastructure**
```bash
make dev-plan    # Review changes
make dev-apply   # Deploy infrastructure
```

### 3. **Setup Production Environment**
```bash
make setup-prod
```

### 4. **Deploy Production Infrastructure**
```bash
make prod-plan   # Review changes
make prod-apply  # Deploy infrastructure
```

## 📁 **Environment Files**

### **Development** (`dev.tfvars`)
- Smaller instance types (`t3.medium`, `db.t3.micro`)
- Less storage (20GB)
- Open SSH access (for development)
- 7-day backup retention
- No Elastic IP

### **Production** (`prod.tfvars`)
- Larger instance types (`t3.large`, `db.t3.small`)
- More storage (100GB)
- Restricted SSH access (your IP only)
- 30-day backup retention
- Elastic IP enabled

## 🔧 **Makefile Commands**

### **Environment-Agnostic Commands**
```bash
make help                    # Show all available commands
make init ENV=dev           # Initialize specific environment
make plan ENV=prod          # Plan specific environment
make apply ENV=dev          # Apply specific environment
make destroy ENV=prod       # Destroy specific environment
```

### **Environment-Specific Shortcuts**
```bash
make dev-init               # Initialize dev environment
make dev-plan               # Plan dev environment
make dev-apply              # Apply dev environment
make dev-destroy            # Destroy dev environment

make prod-init              # Initialize prod environment
make prod-plan              # Plan prod environment
make prod-apply             # Apply prod environment
make prod-destroy           # Destroy prod environment
```

### **Workspace Management**
```bash
make workspace-new          # Create new workspace
make workspace-select       # Select current workspace
make workspace-list         # List all workspaces
```

### **Utility Commands**
```bash
make validate               # Validate Terraform configuration
make fmt                    # Format Terraform files
make clean                  # Clean up Terraform files
make status                 # Show current status
```

## 🌍 **Terraform Workspaces**

This setup uses Terraform workspaces to manage different environments:

- **Default workspace**: Contains no state
- **dev workspace**: Contains development infrastructure state
- **prod workspace**: Contains production infrastructure state

### **Workspace Commands**
```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new dev

# Select workspace
terraform workspace select prod

# Show current workspace
terraform workspace show
```

## 🔐 **Security Considerations**

### **SSH Access**
- **Development**: Open access (`0.0.0.0/0`) for easy development
- **Production**: Restricted to your IP address (`YOUR_IP/32`)

### **Passwords**
- **IMPORTANT**: Change default passwords in both `dev.tfvars` and `prod.tfvars`
- Use strong, unique passwords for production
- Consider using AWS Secrets Manager for production passwords

### **Instance Types**
- **Development**: Smaller instances to save costs
- **Production**: Larger instances for performance and reliability

## 📊 **Cost Optimization**

### **Development Environment**
- Use spot instances where possible
- Smaller instance types
- Shorter backup retention
- No Elastic IP

### **Production Environment**
- Use on-demand instances for reliability
- Larger instance types for performance
- Longer backup retention
- Elastic IP for stable access

## 🚨 **Before Deploying Production**

1. **Update Variables**:
   - Change `aws_account_id` to your actual AWS account
   - Update `ssh_public_key` with your SSH public key
   - Change `allowed_ssh_cidr_blocks` to your IP address
   - Use strong passwords

2. **Review Security**:
   - Ensure SSH access is restricted
   - Verify security group rules
   - Check encryption settings

3. **Test First**:
   - Deploy to development environment first
   - Test all functionality
   - Verify monitoring and logging

## 🔄 **Updating Infrastructure**

### **Development Updates**
```bash
make dev-plan
make dev-apply
```

### **Production Updates**
```bash
make prod-plan
make prod-apply
```

### **Cross-Environment Changes**
If you need to make changes that affect both environments:

1. Update the relevant module files
2. Test in development first
3. Deploy to development
4. Deploy to production

## 🧹 **Cleanup**

### **Destroy Development Environment**
```bash
make dev-destroy
```

### **Destroy Production Environment**
```bash
make prod-destroy
```

### **Remove Workspaces**
```bash
terraform workspace select default
terraform workspace delete dev
terraform workspace delete prod
```

## 📝 **Troubleshooting**

### **Common Issues**

1. **State Lock**: If Terraform hangs, check for state locks in S3
2. **Permission Errors**: Ensure your AWS credentials have necessary permissions
3. **Workspace Issues**: Use `make workspace-list` to see available workspaces

### **Getting Help**
```bash
make help                    # Show all commands
terraform --help            # Terraform help
terraform validate          # Validate configuration
```

## 🔗 **Related Documentation**

- [Module Documentation](./modules/README.md)
- [Variables Reference](./variables.tf)
- [Outputs Reference](./outputs.tf)
