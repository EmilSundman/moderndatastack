#!/bin/bash

# Comprehensive deployment script
# This script will:
# 1. Build and push Docker images to ECR
# 2. Deploy infrastructure with Terraform
# 3. Provide deployment status

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_NAME="${PROJECT_NAME:-moderndatastack}"
echo "=================================================="

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI is not installed${NC}"
        exit 1
    fi
    
    # Check Docker
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker is not running${NC}"
        exit 1
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}❌ Terraform is not installed${NC}"
        exit 1
    fi
    
    # Check if .env file exists
    if [ ! -f ".env" ]; then
        echo -e "${RED}❌ .env file not found. Please create one based on env.prod.example${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites met${NC}"
}

# Function to build and push Docker images
deploy_images() {
    echo -e "${YELLOW}🐳 Building and pushing Docker images to ECR...${NC}"
    ./scripts/deploy-to-ecr.sh
    echo -e "${GREEN}✅ Docker images deployed successfully${NC}"
}

# Function to deploy infrastructure
deploy_infrastructure() {
    echo -e "${YELLOW}🏗️ Deploying infrastructure with Terraform...${NC}"
    
    cd infra/aws
    
    # Initialize Terraform
    echo -e "${BLUE}📋 Initializing Terraform...${NC}"
    terraform init
    
    # Plan deployment
    echo -e "${BLUE}📋 Planning deployment...${NC}"
    terraform plan -out=tfplan
    
    # Apply deployment
    echo -e "${BLUE}🚀 Applying deployment...${NC}"
    terraform apply tfplan
    
    # Get outputs
    echo -e "${BLUE}📋 Getting deployment outputs...${NC}"
    EC2_PUBLIC_IP=$(terraform output -raw ec2_public_ip 2>/dev/null || echo "Not available yet")
    RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null || echo "Not available yet")
    
    cd ../..
    
    echo -e "${GREEN}✅ Infrastructure deployed successfully${NC}"
}

# Function to show deployment status
show_status() {
    echo -e "${BLUE}📊 Deployment Status${NC}"
    echo "======================"
    echo -e "${YELLOW}🌐 Access URLs:${NC}"
    echo -e "  • Dagster UI: http://${EC2_PUBLIC_IP}:1000"
    echo -e "  • DBT Code Location: http://${EC2_PUBLIC_IP}:1001"
    echo -e "  • Dagster Daemon: http://${EC2_PUBLIC_IP}:1070"
    echo ""
    echo -e "${YELLOW}🗄️ Database:${NC}"
    echo -e "  • RDS Endpoint: ${RDS_ENDPOINT}"
    echo ""
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo -e "  1. Wait 5-10 minutes for EC2 instance to fully initialize"
    echo -e "  2. SSH to the instance: ssh -i your-key.pem ec2-user@${EC2_PUBLIC_IP}"
    echo -e "  3. Check service status: systemctl status $$PROJECT_NAME"
    echo -e "  4. View logs: journalctl -u $$PROJECT_NAME -f"
}

# Main execution
main() {
    check_prerequisites
    deploy_images
    deploy_infrastructure
    show_status
}

# Run main function
main
