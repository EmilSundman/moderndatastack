#!/bin/bash

# EC2 Setup Script
# This script will be run as user data when the EC2 instance starts
# Variables are passed from Terraform templatefile:
#   - project_name
#   - environment
#   - aws_account_id
#   - aws_ecr_region  
#   - postgres_endpoint
#   - postgres_username
#   - postgres_password
#   - postgres_db_name

set -e

# Get project name and AWS details from Terraform template variables
PROJECT_NAME="${project_name}"
ENVIRONMENT="${environment}"
AWS_ACCOUNT_ID="${aws_account_id}"
AWS_REGION="${aws_ecr_region}"

# Set defaults if not provided
if [ -z "$$AWS_REGION" ]; then
    AWS_REGION="eu-north-1"
fi

ECR_REGISTRY="$${AWS_ACCOUNT_ID}.dkr.ecr.$${AWS_REGION}.amazonaws.com"
# ECR repository names based on project and environment
WEBSERVER_REPO="$${PROJECT_NAME}-$${ENVIRONMENT}-webserver"
DAEMON_REPO="$${PROJECT_NAME}-$${ENVIRONMENT}-daemon"
CODE_LOCATION_REPO="$${PROJECT_NAME}-$${ENVIRONMENT}-code-location-dbt"

# If not set, try to get from AWS metadata service
if [ -z "$$AWS_ACCOUNT_ID" ]; then
    echo "Attempting to get AWS Account ID from metadata service..."
    AWS_ACCOUNT_ID=$$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep -oP '"accountId"\s*:\s*"\K[^"]+' || echo "")
fi

if [ -z "$$AWS_ACCOUNT_ID" ]; then
    echo "Warning: AWS_ACCOUNT_ID not set. ECR images will not work correctly."
    echo "Set aws_account_id variable in Terraform"
fi

# Create log file for debugging
exec > >(tee /var/log/$${PROJECT_NAME}-setup.log) 2>&1

echo "🚀 Starting $$PROJECT_NAME EC2 setup..."
echo "Timestamp: $$(date)"


# Update system
echo "📦 Updating system packages..."
apt-get update -y

# Install required packages
echo "📦 Installing required packages..."
apt-get install -y \
    ca-certificates \
    curl \
    git \
    unzip \
    lsb-release


# Install Docker Engine
echo "🐳 Installing Docker Engine..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add official Docker repository
echo "🐳 Adding official Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

## Install Docker engine and tools 
echo "🐳 Installing Docker Engine and tools..."
apt-get update -y
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


# Start and enable Docker
echo "🐳 Starting Docker and adding user to docker group..."
systemctl enable docker
systemctl start docker
usermod -a -G docker ubuntu


# Install AWS CLI v2
echo "☁️ Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install # Run aws cli installer
rm -rf awscliv2.zip aws


# Authenticate to ECR
echo "🔐 Authenticating to ECR..."
if [ -n "$$AWS_ACCOUNT_ID" ]; then
    aws ecr get-login-password --region "$${AWS_REGION}" | docker login --username AWS --password-stdin "$${ECR_REGISTRY}"
else
    echo "Warning: Skipping ECR login - AWS_ACCOUNT_ID not set"
fi

# Create application directory
echo "📁 Setting up application directory..."
mkdir -p /opt/$$PROJECT_NAME
cd /opt/$$PROJECT_NAME

# Create production environment file
echo "⚙️ Creating environment configuration..."
cat > .env << 'EOF'
# Production Environment Variables

# PostgreSQL RDS Configuration
POSTGRES_HOST=${postgres_endpoint}
POSTGRES_USER=${postgres_username}
POSTGRES_PASSWORD=${postgres_password}
POSTGRES_DB=${postgres_db_name}

# Environment
ENVIRONMENT=PROD

# Port Configuration
PORT=80

# AWS Configuration (for ECR access)
AWS_DEFAULT_REGION=eu-north-1
EOF

# Create production Docker Compose file
echo "🐳 Creating production Docker Compose configuration..."
cat > docker-compose.prod.yaml << EOF
version: '3.8'

services:

  # Dagster Services
  platform-dagster-webserver:
    image: $${ECR_REGISTRY}/$${WEBSERVER_REPO}:latest
    entrypoint:
      - dagster-webserver
      - -h
      - "0.0.0.0"
      - -p
      - "80"
      - -w
      - workspace.yaml
    container_name: platform_dagster_webserver
    expose:
      - 80
    ports:
      - 80:80
    environment:
      POSTGRES_USER: $${POSTGRES_USER}
      POSTGRES_PASSWORD: $${POSTGRES_PASSWORD}
      POSTGRES_DB: $${POSTGRES_DB}
      POSTGRES_HOST: $${POSTGRES_HOST}
      POSTGRES_PORT: $${POSTGRES_PORT}
      ENVIRONMENT: PROD
      PORT: 80
    env_file:
      - .env
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - network_dagster
    depends_on:
      - platform-dbt
    restart: unless-stopped

  platform-dagster-daemon:
    image: $${ECR_REGISTRY}/$${DAEMON_REPO}:latest
    entrypoint:
      - dagster-daemon
      - run
    container_name: platform_dagster_daemon
    environment:
      POSTGRES_HOST: $${POSTGRES_HOST}
      POSTGRES_PORT: $${POSTGRES_PORT}
      POSTGRES_DB: $${POSTGRES_DB}
      POSTGRES_USER: $${POSTGRES_USER}
      POSTGRES_PASSWORD: $${POSTGRES_PASSWORD}
    env_file:
      - .env
    expose:
      - 9090
    ports: 
      - 9090:9090
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - network_dagster
    depends_on:
      - platform-dbt
    restart: unless-stopped

  # Code Locations
  platform-dbt:
    image: $${ECR_REGISTRY}/$${CODE_LOCATION_REPO}:latest
    container_name: platform_dbt
    env_file:
      - .env
    environment:
      POSTGRES_HOST: $${POSTGRES_HOST}
      POSTGRES_PORT: $${POSTGRES_PORT}
      POSTGRES_USER: $${POSTGRES_USER}
      POSTGRES_PASSWORD: $${POSTGRES_PASSWORD}
      POSTGRES_DB: $${POSTGRES_DB}
      ENVIRONMENT: PROD
      DAGSTER_CURRENT_IMAGE: $${ECR_REGISTRY}/$${CODE_LOCATION_REPO}:latest
    expose:
      - 1001
    ports: 
      - 1001:1001
    networks:
      - network_dagster
    restart: unless-stopped

networks:
  network_dagster:
    driver: bridge
    name: network_dagster
EOF

# Create startup script
echo "🔄 Creating startup script..."
cat > start-$${PROJECT_NAME}.sh << EOF
#!/bin/bash

set -e

cd /opt/$$PROJECT_NAME

echo "🔐 Logging into ECR..."
aws ecr get-login-password --region $${AWS_REGION} | docker login --username AWS --password-stdin $${ECR_REGISTRY}

echo "📥 Pulling latest images..."
docker-compose -f docker-compose.prod.yaml pull

echo "🚀 Starting services..."
docker-compose -f docker-compose.prod.yaml up -d

echo "✅ $$PROJECT_NAME started successfully!"
echo "🌐 Dagster UI available at: http://$$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):80"
EOF

chmod +x start-$${PROJECT_NAME}.sh

# Create systemd service for auto-start
echo "🔧 Creating systemd service..."
cat > /etc/systemd/system/$${PROJECT_NAME}.service << EOF
[Unit]
Description=$${PROJECT_NAME}
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/$${PROJECT_NAME}
ExecStart=/opt/$${PROJECT_NAME}/start-$${PROJECT_NAME}.sh
ExecStop=/usr/local/bin/docker-compose -f /opt/$${PROJECT_NAME}/docker-compose.prod.yaml down
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

# Enable the service
echo "🔧 Enabling systemd service..."
systemctl enable $${PROJECT_NAME}.service

# Wait a bit for everything to settle
echo "⏳ Waiting for system to settle..."
sleep 30

# Start the service
echo "🚀 Starting $$PROJECT_NAME..."
systemctl start $${PROJECT_NAME}.service

echo "✅ EC2 setup completed successfully!"
echo "🔄 $$PROJECT_NAME will start automatically on boot"
echo "📋 Manual start command: systemctl start $${PROJECT_NAME}"
echo "📋 Check status: systemctl status $${PROJECT_NAME}"
echo "📋 View logs: journalctl -u $${PROJECT_NAME} -f"
echo "Timestamp: $$(date)"
