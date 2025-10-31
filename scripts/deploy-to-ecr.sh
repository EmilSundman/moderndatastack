#!/bin/bash

# ECR Registry details - uses environment variable or prompts
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-}"
AWS_REGION="${AWS_REGION:-eu-north-1}"
PROJECT_NAME="${PROJECT_NAME:-moderndatastack}"
ENVIRONMENT="${ENVIRONMENT:-test}"

if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "Error: AWS_ACCOUNT_ID environment variable is not set"
    echo "Please set it with: export AWS_ACCOUNT_ID=your-account-id"
    exit 1
fi

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
DAEMON_REPO="${PROJECT_NAME}-${ENVIRONMENT}-daemon"
CODE_LOCATION_REPO="${PROJECT_NAME}-${ENVIRONMENT}-code-location-dbt"
WEBSERVER_REPO="${PROJECT_NAME}-${ENVIRONMENT}-webserver"
TAG="latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Starting ECR deployment for ${PROJECT_NAME} Platform${NC}"

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
        exit 1
    fi
}

# Function to check if Docker is running
check_docker() {
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
        exit 1
    fi
}

# Function to login to ECR
login_to_ecr() {
    echo -e "${YELLOW}🔐 Logging into ECR...${NC}"
    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $ECR_REGISTRY
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully logged into ECR${NC}"
    else
        echo -e "${RED}❌ Failed to login to ECR${NC}"
        exit 1
    fi
}

# Function to build and push image
build_and_push() {
    local service_name=$1
    local dockerfile_path=$2
    local build_context=$3
    local repo_name=$4
    
    echo -e "${YELLOW}🔨 Building $service_name (multi-platform)...${NC}"
    
    # Create a new builder instance for multi-platform builds
    docker buildx create --name multiarch-builder --use 2>/dev/null || docker buildx use multiarch-builder
    
    # Build and push multi-platform image
    docker buildx build --platform linux/amd64,linux/arm64 \
        -f $dockerfile_path \
        -t $ECR_REGISTRY/$repo_name:$TAG \
        --push \
        $build_context
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully built and pushed $service_name (multi-platform)${NC}"
    else
        echo -e "${RED}❌ Failed to build $service_name${NC}"
        exit 1
    fi
}

# Main execution
main() {
    # Pre-flight checks
    check_aws_cli
    check_docker
    
    # Login to ECR
    login_to_ecr
    
    # Build and push all images
    echo -e "${YELLOW}📦 Building and pushing all images...${NC}"
    
    # Build and push daemon (uses dagster Dockerfile)
    build_and_push "Daemon" "platform/dagster/Dockerfile" "." $DAEMON_REPO
    
    # Build and push code location dbt
    build_and_push "Code Location DBT" "platform/dbt/Dockerfile" "." $CODE_LOCATION_REPO
    
    # Build and push webserver (uses dagster Dockerfile)
    build_and_push "Webserver" "platform/dagster/Dockerfile" "." $WEBSERVER_REPO
    
    echo -e "${GREEN}🎉 All images successfully deployed to ECR!${NC}"
    echo -e "${YELLOW}📋 Image URLs:${NC}"
    echo -e "  • Daemon: $ECR_REGISTRY/$DAEMON_REPO:$TAG"
    echo -e "  • Code Location DBT: $ECR_REGISTRY/$CODE_LOCATION_REPO:$TAG"
    echo -e "  • Webserver: $ECR_REGISTRY/$WEBSERVER_REPO:$TAG"
}

# Run main function
main
