# Modern Data Stack Platform

A composable, cloud-agnostic data platform that can be deployed in days. Instead of building a data platform team, deploy a tested, production-ready foundation that handles orchestration, transformation, and infrastructure-as-code.

## 🎯 Overview

This platform provides a complete data platform foundation built on modern, open-source tools:

- **Orchestration**: Dagster for workflow management and observability
- **Transformation**: dbt Core for SQL-based transformations
- **Storage**: DuckDB for local development, PostgreSQL for production
- **Infrastructure**: Terraform modules for AWS deployment
- **Delivery**: Docker Compose for local development, ECS/Fargate for production

The platform is designed to be:
- **Cloud-agnostic**: Easily adaptable to other cloud providers
- **Modular**: Components can be replaced or extended independently
- **Declarative**: Infrastructure and transformations defined as code
- **Low-maintenance**: Battle-tested patterns and sensible defaults

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Dagster UI (Port 80)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Webserver   │  │    Daemon    │  │ Code Location│     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│         │                  │                  │             │
│         └──────────────────┼──────────────────┘             │
│                            │                                 │
│                    ┌───────▼────────┐                        │
│                    │   PostgreSQL   │                        │
│                    │   (Metadata)   │                        │
│                    └────────────────┘                        │
│                            │                                 │
│                    ┌───────▼────────┐                        │
│                    │   DuckDB/dbt   │                        │
│                    │   (Data Lake)  │                        │
│                    └────────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

### Components

- **Dagster Webserver**: Web UI for monitoring and managing data pipelines
- **Dagster Daemon**: Background service that executes scheduled jobs and sensors
- **dbt Code Location**: Service hosting dbt transformations as a Dagster code location
- **PostgreSQL**: Stores Dagster metadata (runs, schedules, assets)
- **DuckDB**: Local development database (can be replaced with other databases)

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Python 3.10+ (for local development)
- AWS CLI configured (for infrastructure deployment)
- Terraform 1.0+ (for infrastructure deployment)
- DuckDB CLI (optional, for database UI)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd moderndatastack
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start services**
   ```bash
   make dev-up
   ```

4. **Access Dagster UI**
   - Open http://localhost:80 in your browser
   - You should see the Dagster UI with your dbt assets

5. **View database (optional)**
   ```bash
   make duckdb-ui
   ```

### Available Make Commands

```bash
make help              # Show all available commands
make dev-up            # Start all services
make dev-down          # Stop all services
make dev-build         # Build Docker images
make dev-test          # Run dbt tests
make duckdb-ui         # Launch DuckDB UI
make clean             # Clean up containers and generated files
```

## 🏭 Infrastructure Deployment

### AWS Deployment

The platform can be deployed to AWS using Terraform modules. The infrastructure includes:

- **Networking**: VPC, subnets, security groups, internet gateway
- **Compute**: ECS cluster, ECS tasks for Dagster services
- **Storage**: S3 buckets, RDS PostgreSQL instance
- **Container Registry**: ECR repositories for Docker images

### Deployment Steps

1. **Configure AWS credentials**
   ```bash
   export AWS_ACCOUNT_ID=your-account-id
   export AWS_REGION=eu-north-1  # or your preferred region
   ```

2. **Set up Terraform variables**
   ```bash
   cd infra/aws
   cp prod.tfvars.example prod.tfvars
   # Edit prod.tfvars with your values:
   # - aws_account_id
   # - ssh_public_key
   # - allowed_ssh_cidr_blocks (your IP)
   # - postgres_password
   ```

3. **Deploy infrastructure**
   ```bash
   # From project root
   make deploy-infra
   ```

   This will:
   - Build and push Docker images to ECR
   - Initialize Terraform
   - Deploy infrastructure to AWS

4. **Access your deployment**
   - The deployment script will output the Dagster UI URL
   - SSH access is configured based on your `allowed_ssh_cidr_blocks`

### Manual Terraform Operations

```bash
make terraform-aws-init      # Initialize Terraform
make terraform-aws-plan      # Preview changes
make terraform-aws-apply    # Apply changes
make terraform-aws-destroy   # Destroy infrastructure
```

For detailed deployment documentation, see [`infra/aws/DEPLOYMENT.md`](infra/aws/DEPLOYMENT.md).

## 📁 Project Structure

```
moderndatastack/
├── db/                          # Local DuckDB database files
├── infra/                       # Infrastructure as Code
│   └── aws/                     # AWS Terraform modules
│       ├── modules/             # Reusable Terraform modules
│       │   ├── compute/         # ECS, ECR resources
│       │   ├── networking/      # VPC, subnets, security groups
│       │   └── storage/         # S3, RDS resources
│       ├── main.tf              # Root module configuration
│       ├── variables.tf         # Variable definitions
│       └── outputs.tf           # Output values
├── platform/                    # Platform components
│   ├── dagster/                 # Dagster orchestration
│   │   ├── workspace.yaml       # Code location definitions
│   │   ├── requirements.txt     # Python dependencies
│   │   └── utils/               # Utilities (sensors, resources, etc.)
│   └── dbt/                     # dbt transformations
│       ├── models/               # dbt models
│       ├── macros/               # dbt macros
│       ├── dbt_project.yml      # dbt configuration
│       └── requirements.txt     # Python dependencies
├── scripts/                     # Deployment and utility scripts
│   ├── deploy-infrastructure.sh # Full infrastructure deployment
│   ├── deploy-to-ecr.sh         # ECR image deployment
│   └── setup-ec2.sh            # EC2 setup script
├── docker-compose.dev.yaml      # Local development compose file
├── docker-compose.prod.yaml     # Production compose file
└── Makefile                     # Common commands
```

## 🔧 Development Workflow

### Adding New dbt Models

1. Create a new SQL file in `platform/dbt/models/`
2. Add schema documentation in `platform/dbt/models/schema.yml`
3. Test locally:
   ```bash
   make dev-test
   ```
4. View in Dagster UI at http://localhost:80

### Adding Dagster Assets

1. Create assets in `platform/dagster/utils/` or within your code locations
2. Restart services:
   ```bash
   make dev-down
   make dev-up
   ```

### Modifying Infrastructure

1. Update Terraform modules in `infra/aws/modules/`
2. Test changes:
   ```bash
   make terraform-aws-plan
   ```
3. Apply changes:
   ```bash
   make terraform-aws-apply
   ```

## 🔐 Security Considerations

- **Never commit** `.env` files or `*.tfvars` files with sensitive data
- Use strong passwords for PostgreSQL in production
- Restrict SSH access to your IP address in production
- Consider using AWS Secrets Manager for production credentials
- Regularly rotate credentials and keys

## 🧪 Testing

Run dbt tests:
```bash
make dev-test
```

Run tests against a specific dbt model:
```bash
docker compose -f docker-compose.dev.yaml run --rm platform-dbt dbt test --select <model_name>
```

## 📊 Monitoring & Observability

- **Dagster UI**: http://localhost:80 (local) or your deployed URL (production)
- **Asset Lineage**: View data dependencies in the Dagster UI
- **Run History**: Monitor pipeline execution and failures
- **Logs**: Access container logs via Docker Compose or CloudWatch (production)

## 🐛 Troubleshooting

### Services won't start
- Check that ports 80, 5432, 9090, 1001 are not in use
- Verify `.env` file exists and has correct values
- Check Docker logs: `docker compose -f docker-compose.dev.yaml logs`

### Dagster UI not showing assets
- Ensure the dbt code location container is running
- Check code location logs: `docker compose -f docker-compose.dev.yaml logs dbt-code-location`
- Verify `workspace.yaml` points to the correct code location

### Database connection issues
- Verify PostgreSQL is running: `docker compose -f docker-compose.dev.yaml ps`
- Check connection string in `.env`
- Ensure database exists (created automatically on first startup)

### Infrastructure deployment failures
- Verify AWS credentials are configured
- Check Terraform state: `cd infra/aws && terraform state list`
- Review deployment logs for specific errors

## 🔄 Upgrading

### Upgrading Dependencies

1. Update `requirements.txt` files in `platform/dagster/` and `platform/dbt/`
2. Rebuild images:
   ```bash
   make dev-build
   make dev-up
   ```

### Upgrading Infrastructure

1. Update Terraform modules
2. Plan changes:
   ```bash
   make terraform-aws-plan
   ```
3. Apply changes:
   ```bash
   make terraform-aws-apply
   ```

## 📚 Additional Resources

- [Dagster Documentation](https://docs.dagster.io/)
- [dbt Documentation](https://docs.getdbt.com/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [DuckDB Documentation](https://duckdb.org/docs/)

## 🤝 Contributing

This is a composable platform designed to be extended. When adding features:

1. Keep components modular and independent
2. Follow existing patterns (e.g., code locations, Terraform modules)
3. Update documentation for new features
4. Test locally before deploying

## 📝 License

[Add your license here]

## 🙋 Support

For issues or questions:
- Check the troubleshooting section above
- Review component-specific documentation
- Open an issue in the repository

---

**Built with** ❤️ **for modern data teams**
