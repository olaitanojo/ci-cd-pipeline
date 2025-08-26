# Enterprise CI/CD Pipeline Platform - Makefile
# SRE Portfolio Project

.PHONY: help setup test build deploy clean
.DEFAULT_GOAL := help

# Configuration
APP_NAME := ci-cd-platform
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "v0.1.0")
REGISTRY := ghcr.io/sre-portfolio
ENVIRONMENT ?= dev

# Docker configuration
DOCKER_IMAGE := $(REGISTRY)/$(APP_NAME):$(VERSION)
DOCKER_LATEST := $(REGISTRY)/$(APP_NAME):latest

# Kubernetes configuration
NAMESPACE := $(APP_NAME)-$(ENVIRONMENT)
KUBECONFIG ?= ~/.kube/config

# Testing configuration
TEST_TIMEOUT := 300s
COVERAGE_THRESHOLD := 80

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[1;37m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Enterprise CI/CD Pipeline Platform$(NC)"
	@echo "$(YELLOW)=====================================$(NC)"
	@echo ""
	@echo "$(WHITE)Available Commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "$(GREEN)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(WHITE)Environment Variables:$(NC)"
	@echo "$(CYAN)ENVIRONMENT$(NC)         Target environment (dev/staging/production)"
	@echo "$(CYAN)VERSION$(NC)             Application version ($(VERSION))"
	@echo "$(CYAN)REGISTRY$(NC)            Container registry ($(REGISTRY))"

# ==============================================================================
# Development Environment Setup
# ==============================================================================

setup-dev: ## Setup development environment
	@echo "$(BLUE)Setting up development environment...$(NC)"
	@./tools/scripts/setup-dev.sh
	@make install-tools
	@make setup-git-hooks
	@echo "$(GREEN)✅ Development environment ready!$(NC)"

install-tools: ## Install required development tools
	@echo "$(BLUE)Installing development tools...$(NC)"
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)❌ Docker is required$(NC)"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "$(RED)❌ kubectl is required$(NC)"; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo "$(RED)❌ Helm is required$(NC)"; exit 1; }
	@echo "$(GREEN)✅ All required tools are installed$(NC)"

setup-git-hooks: ## Setup Git pre-commit hooks
	@echo "$(BLUE)Setting up Git hooks...$(NC)"
	@cp tools/scripts/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "$(GREEN)✅ Git hooks configured$(NC)"

# ==============================================================================
# Testing
# ==============================================================================

test-all: test-unit test-integration test-security test-performance ## Run all tests
	@echo "$(GREEN)✅ All tests completed successfully!$(NC)"

test-unit: ## Run unit tests
	@echo "$(BLUE)Running unit tests...$(NC)"
	@cd testing/unit && ./run-tests.sh
	@echo "$(GREEN)✅ Unit tests passed$(NC)"

test-integration: ## Run integration tests
	@echo "$(BLUE)Running integration tests...$(NC)"
	@cd testing/integration && ./run-tests.sh
	@echo "$(GREEN)✅ Integration tests passed$(NC)"

test-security: ## Run security tests
	@echo "$(BLUE)Running security tests...$(NC)"
	@cd testing/security && ./run-security-tests.sh
	@echo "$(GREEN)✅ Security tests passed$(NC)"

test-performance: ## Run performance tests
	@echo "$(BLUE)Running performance tests...$(NC)"
	@cd testing/performance && ./run-performance-tests.sh
	@echo "$(GREEN)✅ Performance tests passed$(NC)"

test-coverage: ## Generate test coverage report
	@echo "$(BLUE)Generating coverage report...$(NC)"
	@./tools/scripts/coverage-report.sh
	@echo "$(GREEN)✅ Coverage report generated$(NC)"

# ==============================================================================
# Code Quality and Security
# ==============================================================================

lint: ## Run code linting
	@echo "$(BLUE)Running code linting...$(NC)"
	@./tools/scripts/lint.sh
	@echo "$(GREEN)✅ Linting completed$(NC)"

format: ## Format code
	@echo "$(BLUE)Formatting code...$(NC)"
	@./tools/scripts/format.sh
	@echo "$(GREEN)✅ Code formatted$(NC)"

security-scan: ## Run security scans
	@echo "$(BLUE)Running security scans...$(NC)"
	@./security/scanning/run-scans.sh
	@echo "$(GREEN)✅ Security scans completed$(NC)"

quality-check: lint test-unit security-scan ## Run quality checks
	@echo "$(GREEN)✅ Quality checks passed$(NC)"

# ==============================================================================
# Build and Package
# ==============================================================================

build: ## Build application
	@echo "$(BLUE)Building application...$(NC)"
	@./tools/scripts/build.sh $(VERSION)
	@echo "$(GREEN)✅ Application built successfully$(NC)"

build-docker: ## Build Docker image
	@echo "$(BLUE)Building Docker image $(DOCKER_IMAGE)...$(NC)"
	@docker build -t $(DOCKER_IMAGE) -t $(DOCKER_LATEST) .
	@echo "$(GREEN)✅ Docker image built: $(DOCKER_IMAGE)$(NC)"

push-docker: ## Push Docker image to registry
	@echo "$(BLUE)Pushing Docker image to registry...$(NC)"
	@docker push $(DOCKER_IMAGE)
	@docker push $(DOCKER_LATEST)
	@echo "$(GREEN)✅ Docker image pushed to registry$(NC)"

# ==============================================================================
# Deployment
# ==============================================================================

deploy-dev: ## Deploy to development environment
	@echo "$(BLUE)Deploying to development environment...$(NC)"
	@ENVIRONMENT=dev $(MAKE) deploy
	@echo "$(GREEN)✅ Deployed to development$(NC)"

deploy-staging: ## Deploy to staging environment
	@echo "$(BLUE)Deploying to staging environment...$(NC)"
	@ENVIRONMENT=staging $(MAKE) deploy
	@echo "$(GREEN)✅ Deployed to staging$(NC)"

deploy-production: ## Deploy to production environment
	@echo "$(RED)⚠️  PRODUCTION DEPLOYMENT$(NC)"
	@read -p "Continue with production deployment? (y/N): " confirm && [ "$$confirm" = "y" ]
	@ENVIRONMENT=production $(MAKE) deploy
	@echo "$(GREEN)✅ Deployed to production$(NC)"

deploy: ## Deploy to specified environment
	@echo "$(BLUE)Deploying to $(ENVIRONMENT) environment...$(NC)"
	@./tools/scripts/deploy.sh $(ENVIRONMENT) $(VERSION)
	@$(MAKE) health-check
	@echo "$(GREEN)✅ Deployment completed$(NC)"

# ==============================================================================
# Deployment Strategies
# ==============================================================================

deploy-blue-green: ## Deploy using blue-green strategy
	@echo "$(BLUE)Deploying with blue-green strategy...$(NC)"
	@cd deployment-strategies/blue-green && ./deploy.sh $(ENVIRONMENT) $(VERSION)
	@echo "$(GREEN)✅ Blue-green deployment completed$(NC)"

deploy-canary: ## Deploy using canary strategy
	@echo "$(BLUE)Deploying with canary strategy...$(NC)"
	@cd deployment-strategies/canary && ./deploy.sh $(ENVIRONMENT) $(VERSION)
	@echo "$(GREEN)✅ Canary deployment completed$(NC)"

deploy-rolling: ## Deploy using rolling update strategy
	@echo "$(BLUE)Deploying with rolling update strategy...$(NC)"
	@cd deployment-strategies/rolling && ./deploy.sh $(ENVIRONMENT) $(VERSION)
	@echo "$(GREEN)✅ Rolling deployment completed$(NC)"

# ==============================================================================
# Monitoring and Health Checks
# ==============================================================================

health-check: ## Run health checks
	@echo "$(BLUE)Running health checks...$(NC)"
	@./monitoring/health-checks/check-health.sh $(ENVIRONMENT)
	@echo "$(GREEN)✅ Health checks passed$(NC)"

metrics: ## Display deployment metrics
	@echo "$(BLUE)Fetching deployment metrics...$(NC)"
	@./monitoring/metrics/fetch-metrics.sh $(ENVIRONMENT)

dashboard: ## Open monitoring dashboard
	@echo "$(BLUE)Opening monitoring dashboard...$(NC)"
	@./monitoring/dashboards/open-dashboard.sh $(ENVIRONMENT)

alerts: ## Check active alerts
	@echo "$(BLUE)Checking active alerts...$(NC)"
	@./monitoring/alerting/check-alerts.sh $(ENVIRONMENT)

logs: ## View application logs
	@echo "$(BLUE)Fetching application logs...$(NC)"
	@kubectl logs -n $(NAMESPACE) -l app=$(APP_NAME) --tail=100

# ==============================================================================
# Pipeline Operations
# ==============================================================================

pipeline-validate: ## Validate CI/CD pipeline configuration
	@echo "$(BLUE)Validating pipeline configuration...$(NC)"
	@./tools/scripts/validate-pipeline.sh
	@echo "$(GREEN)✅ Pipeline configuration valid$(NC)"

pipeline-test: ## Test CI/CD pipeline locally
	@echo "$(BLUE)Testing pipeline locally...$(NC)"
	@./tools/scripts/test-pipeline.sh
	@echo "$(GREEN)✅ Pipeline test completed$(NC)"

pipeline-metrics: ## Show pipeline metrics
	@echo "$(BLUE)Generating pipeline metrics...$(NC)"
	@./tools/scripts/pipeline-metrics.sh

dora-metrics: ## Generate DORA metrics report
	@echo "$(BLUE)Generating DORA metrics report...$(NC)"
	@./tools/scripts/dora-metrics.sh

# ==============================================================================
# Rollback and Recovery
# ==============================================================================

rollback: ## Rollback to previous version
	@echo "$(RED)⚠️  ROLLBACK OPERATION$(NC)"
	@read -p "Continue with rollback? (y/N): " confirm && [ "$$confirm" = "y" ]
	@./tools/scripts/rollback.sh $(ENVIRONMENT)
	@$(MAKE) health-check
	@echo "$(GREEN)✅ Rollback completed$(NC)"

rollback-to: ## Rollback to specific version
	@echo "$(RED)⚠️  ROLLBACK TO SPECIFIC VERSION$(NC)"
	@read -p "Enter version to rollback to: " version && \
	./tools/scripts/rollback.sh $(ENVIRONMENT) $$version
	@$(MAKE) health-check
	@echo "$(GREEN)✅ Rollback completed$(NC)"

disaster-recovery: ## Execute disaster recovery procedures
	@echo "$(RED)🚨 DISASTER RECOVERY MODE$(NC)"
	@./tools/scripts/disaster-recovery.sh $(ENVIRONMENT)

# ==============================================================================
# Feature Flags and A/B Testing
# ==============================================================================

feature-flags: ## Manage feature flags
	@echo "$(BLUE)Managing feature flags...$(NC)"
	@cd deployment-strategies/feature-flags && ./manage-flags.sh

enable-feature: ## Enable specific feature flag
	@read -p "Enter feature flag name: " flag && \
	cd deployment-strategies/feature-flags && ./enable-flag.sh $$flag $(ENVIRONMENT)

disable-feature: ## Disable specific feature flag
	@read -p "Enter feature flag name: " flag && \
	cd deployment-strategies/feature-flags && ./disable-flag.sh $$flag $(ENVIRONMENT)

ab-test: ## Start A/B test
	@echo "$(BLUE)Starting A/B test...$(NC)"
	@cd deployment-strategies/feature-flags && ./ab-test.sh $(ENVIRONMENT)

# ==============================================================================
# Infrastructure Management
# ==============================================================================

infra-plan: ## Plan infrastructure changes
	@echo "$(BLUE)Planning infrastructure changes...$(NC)"
	@cd infrastructure/terraform && terraform plan -var="environment=$(ENVIRONMENT)"

infra-apply: ## Apply infrastructure changes
	@echo "$(BLUE)Applying infrastructure changes...$(NC)"
	@cd infrastructure/terraform && terraform apply -var="environment=$(ENVIRONMENT)" -auto-approve

infra-destroy: ## Destroy infrastructure
	@echo "$(RED)⚠️  DESTROYING INFRASTRUCTURE$(NC)"
	@read -p "Are you sure? Type 'destroy-$(ENVIRONMENT)': " confirm && [ "$$confirm" = "destroy-$(ENVIRONMENT)" ]
	@cd infrastructure/terraform && terraform destroy -var="environment=$(ENVIRONMENT)" -auto-approve

# ==============================================================================
# Kubernetes Operations
# ==============================================================================

k8s-status: ## Show Kubernetes deployment status
	@echo "$(BLUE)Kubernetes deployment status:$(NC)"
	@kubectl get deployments,services,ingress -n $(NAMESPACE)

k8s-describe: ## Describe Kubernetes resources
	@kubectl describe deployment $(APP_NAME) -n $(NAMESPACE)

k8s-shell: ## Open shell in running pod
	@kubectl exec -it -n $(NAMESPACE) deployment/$(APP_NAME) -- /bin/sh

k8s-port-forward: ## Port forward to application
	@echo "$(BLUE)Port forwarding to $(APP_NAME)...$(NC)"
	@kubectl port-forward -n $(NAMESPACE) service/$(APP_NAME) 8080:80

# ==============================================================================
# Utilities
# ==============================================================================

clean: ## Clean build artifacts and temporary files
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	@rm -rf build/ dist/ *.log
	@docker system prune -f --volumes
	@echo "$(GREEN)✅ Cleanup completed$(NC)"

backup: ## Backup current deployment configuration
	@echo "$(BLUE)Creating deployment backup...$(NC)"
	@./tools/scripts/backup.sh $(ENVIRONMENT)
	@echo "$(GREEN)✅ Backup created$(NC)"

restore: ## Restore deployment from backup
	@echo "$(BLUE)Restoring deployment from backup...$(NC)"
	@./tools/scripts/restore.sh $(ENVIRONMENT)
	@echo "$(GREEN)✅ Restore completed$(NC)"

docs: ## Generate documentation
	@echo "$(BLUE)Generating documentation...$(NC)"
	@./tools/scripts/generate-docs.sh
	@echo "$(GREEN)✅ Documentation generated$(NC)"

version: ## Show version information
	@echo "$(BLUE)Version Information:$(NC)"
	@echo "Application: $(GREEN)$(VERSION)$(NC)"
	@echo "Environment: $(GREEN)$(ENVIRONMENT)$(NC)"
	@echo "Registry: $(GREEN)$(REGISTRY)$(NC)"
	@echo "Namespace: $(GREEN)$(NAMESPACE)$(NC)"

status: ## Show overall system status
	@echo "$(BLUE)System Status:$(NC)"
	@$(MAKE) k8s-status
	@$(MAKE) health-check
	@$(MAKE) metrics

# ==============================================================================
# CI/CD Pipeline Specific Commands
# ==============================================================================

github-actions-validate: ## Validate GitHub Actions workflows
	@echo "$(BLUE)Validating GitHub Actions workflows...$(NC)"
	@cd pipelines/github-actions && ./validate-workflows.sh

jenkins-validate: ## Validate Jenkins pipelines
	@echo "$(BLUE)Validating Jenkins pipelines...$(NC)"
	@cd pipelines/jenkins && ./validate-pipelines.sh

gitlab-validate: ## Validate GitLab CI pipelines
	@echo "$(BLUE)Validating GitLab CI pipelines...$(NC)"
	@cd pipelines/gitlab-ci && ./validate-pipelines.sh

setup-github-actions: ## Setup GitHub Actions environment
	@echo "$(BLUE)Setting up GitHub Actions...$(NC)"
	@cd pipelines/github-actions && ./setup.sh

setup-jenkins: ## Setup Jenkins environment
	@echo "$(BLUE)Setting up Jenkins...$(NC)"
	@cd pipelines/jenkins && ./setup.sh

setup-gitlab: ## Setup GitLab CI environment
	@echo "$(BLUE)Setting up GitLab CI...$(NC)"
	@cd pipelines/gitlab-ci && ./setup.sh

# ==============================================================================
# Development Helpers
# ==============================================================================

dev-reset: clean setup-dev ## Reset development environment
	@echo "$(GREEN)✅ Development environment reset$(NC)"

dev-test: test-unit test-integration ## Run development tests
	@echo "$(GREEN)✅ Development tests completed$(NC)"

dev-deploy: build-docker deploy-dev health-check ## Full development deployment
	@echo "$(GREEN)✅ Development deployment completed$(NC)"

staging-deploy: build-docker push-docker deploy-staging health-check ## Full staging deployment
	@echo "$(GREEN)✅ Staging deployment completed$(NC)"

production-deploy: build-docker push-docker deploy-production health-check ## Full production deployment
	@echo "$(GREEN)✅ Production deployment completed$(NC)"
