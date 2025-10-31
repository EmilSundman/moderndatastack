# Color codes
COLOR_GREEN := \033[32m
COLOR_BLUE := \033[34m
COLOR_RED := \033[31m
COLOR_ORANGE := \033[38;5;208m
COLOR_YELLOW := \033[33m
COLOR_RESET := \033[0m

.PHONY: help dev-build dev-up dev-down dev-test clean deploy-ecr build-ecr deploy-infra terraform-aws-init terraform-aws-plan terraform-aws-apply terraform-aws-destroy duckdb-ui

help: ## Display this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "  %-20s %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

dev-build: ## Build all Docker images
	./infra/common/scripts/build-images.sh

dev-up: ## Start all services
	@echo "$(COLOR_ORANGE) Starting services... ⏳$(COLOR_RESET)"
	@echo " "
	docker compose --file docker-compose.dev.yaml up -d --build
	@echo " "
	@echo "$(COLOR_YELLOW) To access the Dagster UI, go to http://localhost:80$(COLOR_RESET)"
	@echo " "

dev-down: ## Stop all services
	docker compose --file docker-compose.dev.yaml down

dev-test: ## Run tests
	docker compose --file docker-compose.dev.yaml run --rm platform-dbt dbt test

duckdb-ui: ## Launch DuckDB UI with local dev database (kills existing instance first)
	@echo "$(COLOR_ORANGE) Stopping any existing DuckDB UI instances... ⏳$(COLOR_RESET)"
	@pkill -f "duckdb.*dev.duckdb.*-ui" 2>/dev/null || true
	@sleep 1
	@echo "$(COLOR_ORANGE) Launching DuckDB UI... ⏳$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW) Tip: Tables are in 'main' schema. Query with 'main.table_name' or run 'SET search_path TO main;'$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW) Note: If new tables appear after materialization, refresh the UI or close/reopen to see them$(COLOR_RESET)"
	@mkdir -p ./db
	@which duckdb > /dev/null 2>&1 || (echo "$(COLOR_RED) DuckDB CLI not found. Please install DuckDB: https://duckdb.org/docs/installation/$(COLOR_RESET)" && exit 1)
	@duckdb ./db/dev.duckdb -ui 2>/dev/null || true

clean: ## Clean up generated files and containers
	docker compose down -v
	find . -type d -name "__pycache__" -exec rm -r {} +
	find . -type d -name "target" -exec rm -r {} +
	find . -type d -name "dbt_packages" -exec rm -r {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.pyd" -delete
	find . -type f -name ".coverage" -delete
	find . -type d -name "*.egg-info" -exec rm -r {} +
	find . -type d -name "*.egg" -exec rm -r {} +
	find . -type d -name ".pytest_cache" -exec rm -r {} +
	find . -type d -name ".coverage" -exec rm -r {} +
	find . -type d -name "htmlcov" -exec rm -r {} +
	find . -type d -name ".mypy_cache" -exec rm -r {} +
	find . -type d -name ".ruff_cache" -exec rm -r {} +
	find . -type d -name ".hypothesis" -exec rm -r {} +

deploy-ecr: ## Build and deploy all images to ECR
	./scripts/deploy-to-ecr.sh

build-ecr: ## Build ECR images locally without pushing
	@if [ -z "$$AWS_ACCOUNT_ID" ]; then \
		echo "$(COLOR_RED)Error: AWS_ACCOUNT_ID environment variable is not set$(COLOR_RESET)"; \
		echo "Please set it with: export AWS_ACCOUNT_ID=your-account-id"; \
		exit 1; \
	fi
	@PROJECT_NAME=$${PROJECT_NAME:-moderndatastack} && \
	AWS_REGION=$${AWS_REGION:-eu-north-1} && \
	echo "$(COLOR_BLUE)Building ECR images locally (multi-platform) for $$PROJECT_NAME...$(COLOR_RESET)" && \
	docker buildx build --platform linux/amd64,linux/arm64 -f platform/dagster/Dockerfile -t $$AWS_ACCOUNT_ID.dkr.ecr.$$AWS_REGION.amazonaws.com/$$PROJECT_NAME-daemon:latest . && \
	docker buildx build --platform linux/amd64,linux/arm64 -f platform/dbt/Dockerfile -t $$AWS_ACCOUNT_ID.dkr.ecr.$$AWS_REGION.amazonaws.com/$$PROJECT_NAME-code-location-dbt:latest . && \
	docker buildx build --platform linux/amd64,linux/arm64 -f platform/dagster/Dockerfile -t $$AWS_ACCOUNT_ID.dkr.ecr.$$AWS_REGION.amazonaws.com/$$PROJECT_NAME-webserver:latest .
	@echo "$(COLOR_GREEN)✅ All ECR images built locally (multi-platform)$(COLOR_RESET)"

deploy-infra: ## Deploy complete infrastructure (ECR + Terraform)
	./scripts/deploy-infrastructure.sh

terraform-aws-init: ## Initialize Terraform
	cd infra/aws && terraform init

terraform-aws-plan: ## Plan Terraform deployment
	cd infra/aws && terraform plan

terraform-aws-apply: ## Apply Terraform deployment with auto-approve
	cd infra/aws && terraform apply -auto-approve

terraform-aws-destroy: ## Destroy Terraform infrastructure with auto-approve
	cd infra/aws && terraform destroy -auto-approve