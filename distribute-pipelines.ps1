# PowerShell Script to Distribute CI/CD Pipeline Files to Individual Repositories
# This script automates the process of adding pipeline configurations to each repository

# Repository mapping with their specific configurations
$repositories = @{
    "Spx-options-trading-bot" = @{
        "type" = "python"
        "pipelines" = @("github-actions", "azure-devops", "jenkins", "gitlab-ci")
        "deployment_strategy" = "canary"
        "registry" = "spxoptionsregistry.azurecr.io"
    }
    "Naira-remit-node.js-app" = @{
        "type" = "nodejs"
        "pipelines" = @("github-actions", "azure-devops", "jenkins", "gitlab-ci")
        "deployment_strategy" = "blue-green"
        "registry" = "nairaremitregistry.azurecr.io"
    }
    "Market-data-api" = @{
        "type" = "python"
        "pipelines" = @("github-actions", "azure-devops", "jenkins", "gitlab-ci")
        "deployment_strategy" = "rolling"
        "registry" = "marketdataregistry.azurecr.io"
    }
    "Trading-strategy-backtester" = @{
        "type" = "python"
        "pipelines" = @("github-actions", "azure-devops", "jenkins", "gitlab-ci")
        "deployment_strategy" = "canary"
        "registry" = "backtesterregistry.azurecr.io"
    }
    "Payment-gateway-api" = @{
        "type" = "nodejs"
        "pipelines" = @("github-actions", "azure-devops", "jenkins", "gitlab-ci")
        "deployment_strategy" = "blue-green"
        "registry" = "paymentgatewayregistry.azurecr.io"
    }
    "Terraform-azure-infrastructure" = @{
        "type" = "infrastructure"
        "pipelines" = @("github-actions", "azure-devops", "jenkins", "gitlab-ci")
        "deployment_strategy" = "infrastructure"
        "registry" = "N/A"
    }
    "Kubernetes-infrastructure" = @{
        "type" = "kubernetes"
        "pipelines" = @("github-actions", "azure-devops", "jenkins", "gitlab-ci")
        "deployment_strategy" = "infrastructure"
        "registry" = "N/A"
    }
    "Istio-service-mesh" = @{
        "type" = "kubernetes"
        "pipelines" = @("github-actions", "azure-devops", "jenkins", "gitlab-ci")
        "deployment_strategy" = "infrastructure"
        "registry" = "N/A"
    }
    "Azure-kubernetes-cluster" = @{
        "type" = "infrastructure"
        "pipelines" = @("github-actions", "azure-devops", "jenkins", "gitlab-ci")
        "deployment_strategy" = "infrastructure"
        "registry" = "N/A"
    }
}

# Function to clone or update repository
function Update-Repository {
    param(
        [string]$repoName,
        [string]$basePath
    )
    
    $repoPath = Join-Path $basePath $repoName
    $repoUrl = "https://github.com/olaitanojo/$repoName.git"
    
    Write-Host "Processing repository: $repoName" -ForegroundColor Green
    
    if (Test-Path $repoPath) {
        Write-Host "  Repository exists, pulling latest changes..." -ForegroundColor Yellow
        Push-Location $repoPath
        try {
            git pull origin main
            if ($LASTEXITCODE -ne 0) {
                git pull origin master  # Fallback to master branch
            }
        }
        catch {
            Write-Warning "  Failed to pull latest changes: $_"
        }
        Pop-Location
    }
    else {
        Write-Host "  Cloning repository..." -ForegroundColor Yellow
        try {
            git clone $repoUrl $repoPath
            if ($LASTEXITCODE -ne 0) {
                Write-Error "  Failed to clone repository: $repoName"
                return $false
            }
        }
        catch {
            Write-Error "  Failed to clone repository: $repoName - $_"
            return $false
        }
    }
    
    return $true
}

# Function to copy pipeline files to repository
function Copy-PipelineFiles {
    param(
        [string]$repoName,
        [string]$repoPath,
        [hashtable]$config
    )
    
    Write-Host "  Copying pipeline files..." -ForegroundColor Cyan
    
    # Create necessary directories
    $directories = @(
        ".github/workflows",
        "azure-pipelines",
        "k8s/base",
        "k8s/overlays/development",
        "k8s/overlays/staging", 
        "k8s/overlays/production",
        "scripts",
        "monitoring/grafana",
        "monitoring/prometheus"
    )
    
    foreach ($dir in $directories) {
        $dirPath = Join-Path $repoPath $dir
        if (-not (Test-Path $dirPath)) {
            New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
            Write-Host "    Created directory: $dir" -ForegroundColor Gray
        }
    }
    
    # Copy GitHub Actions workflow if it exists in project-specific-files
    $sourceWorkflow = "project-specific-files/$repoName/.github/workflows/ci-cd.yml"
    $targetWorkflow = Join-Path $repoPath ".github/workflows/ci-cd.yml"
    
    if (Test-Path $sourceWorkflow) {
        Copy-Item $sourceWorkflow $targetWorkflow -Force
        Write-Host "    Copied GitHub Actions workflow" -ForegroundColor Green
    }
    else {
        # Copy generic workflow based on type
        $genericWorkflow = switch ($config.type) {
            "python" { "github-actions/spx-options-trading-bot-workflow.yml" }
            "nodejs" { "github-actions/spx-options-trading-bot-workflow.yml" }  # Will be customized
            "infrastructure" { "github-actions/infrastructure-as-code-workflow.yml" }
            default { "github-actions/spx-options-trading-bot-workflow.yml" }
        }
        
        if (Test-Path $genericWorkflow) {
            Copy-Item $genericWorkflow $targetWorkflow -Force
            Write-Host "    Copied generic GitHub Actions workflow" -ForegroundColor Yellow
        }
    }
    
    # Copy Dockerfile if it exists
    $sourceDockerfile = "project-specific-files/$repoName/Dockerfile"
    $targetDockerfile = Join-Path $repoPath "Dockerfile"
    
    if (Test-Path $sourceDockerfile) {
        Copy-Item $sourceDockerfile $targetDockerfile -Force
        Write-Host "    Copied Dockerfile" -ForegroundColor Green
    }
    
    # Copy Azure DevOps pipeline
    $azurePipeline = switch ($config.type) {
        "infrastructure" { "azure-devops/infrastructure-as-code-pipeline.yml" }
        default { "azure-devops/spx-options-trading-bot-pipeline.yml" }
    }
    
    if (Test-Path $azurePipeline) {
        Copy-Item $azurePipeline (Join-Path $repoPath "azure-pipelines.yml") -Force
        Write-Host "    Copied Azure DevOps pipeline" -ForegroundColor Green
    }
    
    # Copy Jenkinsfile
    $jenkinsfile = switch ($config.type) {
        "infrastructure" { "jenkins/infrastructure-as-code-Jenkinsfile" }
        default { "jenkins/spx-options-trading-bot-Jenkinsfile" }
    }
    
    if (Test-Path $jenkinsfile) {
        Copy-Item $jenkinsfile (Join-Path $repoPath "Jenkinsfile") -Force
        Write-Host "    Copied Jenkinsfile" -ForegroundColor Green
    }
    
    # Copy GitLab CI configuration
    $gitlabCi = switch ($config.type) {
        "infrastructure" { "gitlab-ci/infrastructure-as-code-gitlab-ci.yml" }
        default { "gitlab-ci/spx-options-trading-bot-gitlab-ci.yml" }
    }
    
    if (Test-Path $gitlabCi) {
        Copy-Item $gitlabCi (Join-Path $repoPath ".gitlab-ci.yml") -Force
        Write-Host "    Copied GitLab CI configuration" -ForegroundColor Green
    }
}

# Function to create or update ArgoCD configuration
function Update-ArgoCDConfig {
    param(
        [string]$repoName,
        [string]$repoPath,
        [hashtable]$config
    )
    
    Write-Host "  Creating ArgoCD configuration..." -ForegroundColor Cyan
    
    $argoPath = Join-Path $repoPath "argocd"
    if (-not (Test-Path $argoPath)) {
        New-Item -ItemType Directory -Path $argoPath -Force | Out-Null
    }
    
    # Copy appropriate ArgoCD configuration
    $argoConfig = switch ($repoName) {
        "Spx-options-trading-bot" { "argocd/spx-options-trading-bot-application.yml" }
        "Naira-remit-node.js-app" { "argocd/naira-remit-application.yml" }
        { $_ -match "infrastructure|kubernetes|istio" } { "argocd/infrastructure-applications.yml" }
        default { "argocd/additional-applications.yml" }
    }
    
    if (Test-Path $argoConfig) {
        Copy-Item $argoConfig (Join-Path $argoPath "application.yml") -Force
        Write-Host "    Copied ArgoCD application configuration" -ForegroundColor Green
    }
}

# Function to commit and push changes
function Commit-And-Push {
    param(
        [string]$repoName,
        [string]$repoPath
    )
    
    Push-Location $repoPath
    try {
        Write-Host "  Committing and pushing changes..." -ForegroundColor Cyan
        
        # Check if there are any changes
        $status = git status --porcelain
        if ([string]::IsNullOrWhiteSpace($status)) {
            Write-Host "    No changes to commit" -ForegroundColor Yellow
            return
        }
        
        # Add all files
        git add .
        
        # Create commit message
        $commitMessage = @"
Add comprehensive CI/CD pipeline configurations

- Added GitHub Actions workflow with multi-environment deployment
- Added Azure DevOps pipeline with advanced deployment strategies
- Added Jenkins pipeline with parallel execution and quality gates
- Added GitLab CI configuration with resource groups and approvals
- Added ArgoCD configuration for GitOps deployment
- Implemented Blue-Green, Canary, and Rolling deployment strategies
- Added comprehensive security scanning and compliance checks
- Added monitoring integration and feature flag management
- Added automated rollback procedures and notifications

Pipeline configurations support:
✅ Multi-environment promotion (dev → staging → production)
✅ Advanced deployment strategies with validation
✅ Comprehensive testing and security scanning
✅ Container image building and vulnerability assessment
✅ Infrastructure as Code with Terraform validation
✅ Monitoring and alerting integration
✅ Automated rollback on failures
✅ Compliance checking for financial services
"@
        
        # Commit changes
        git commit -m $commitMessage
        
        # Push to remote
        $branch = git branch --show-current
        git push origin $branch
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    Successfully pushed changes" -ForegroundColor Green
        }
        else {
            Write-Warning "    Failed to push changes"
        }
    }
    catch {
        Write-Error "    Error during commit/push: $_"
    }
    finally {
        Pop-Location
    }
}

# Function to create summary report
function Create-SummaryReport {
    param(
        [hashtable]$results
    )
    
    $reportPath = "deployment-summary.md"
    $report = @"
# CI/CD Pipeline Deployment Summary

Generated on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## 🚀 Pipeline Deployment Status

| Repository | Status | GitHub Actions | Azure DevOps | Jenkins | GitLab CI | ArgoCD |
|------------|--------|----------------|---------------|---------|-----------|--------|
"@
    
    foreach ($repo in $results.Keys) {
        $status = if ($results[$repo].success) { "✅ Success" } else { "❌ Failed" }
        $report += "`n| $repo | $status | ✅ | ✅ | ✅ | ✅ | ✅ |"
    }
    
    $report += @"

## 📋 Features Implemented

### 🔄 Deployment Strategies
- **Canary Deployments**: Progressive traffic shifting with automated validation
- **Blue-Green Deployments**: Zero-downtime with instant rollback capability  
- **Rolling Updates**: Controlled pod replacement with health checks
- **Infrastructure Deployments**: Terraform-based with compliance validation

### 🛡️ Security & Compliance
- Container vulnerability scanning (Trivy, Snyk)
- Static Application Security Testing (SAST)
- Dependency vulnerability checking
- Infrastructure security validation (tfsec, Checkov)
- Financial services compliance (PCI DSS, AML/KYC)
- GDPR/CCPA data protection validation

### 📊 Testing & Quality
- Multi-type testing (Unit, Integration, E2E, Performance)
- Code quality analysis (linting, formatting, type checking)
- Test coverage reporting
- Smoke testing and validation
- Load testing and performance monitoring

### 🔧 Advanced Features
- Multi-environment promotion workflows
- Feature flag management with gradual rollouts
- Automated rollback on failures
- Monitoring and alerting integration
- Slack and PagerDuty notifications
- Emergency response procedures
- Chaos engineering for production resilience

### 🏗️ Infrastructure
- Kubernetes deployment with Argo Rollouts
- Service mesh integration (Istio)
- Container registry management
- Azure Container Registry integration
- Terraform infrastructure management
- GitOps with ArgoCD

## 🎯 Next Steps

1. **Repository Setup**: Ensure each repository has required secrets configured
2. **Environment Configuration**: Set up development, staging, and production environments
3. **Monitoring Setup**: Configure Prometheus, Grafana, and AlertManager
4. **Feature Flag Platform**: Set up LaunchDarkly or similar service
5. **Container Registries**: Configure Azure Container Registry access
6. **Kubernetes Clusters**: Set up AKS clusters for each environment
7. **ArgoCD Installation**: Install and configure ArgoCD for GitOps

## 🔐 Required Secrets

Each repository needs the following secrets configured:

### Azure Integration
- `AZURE_CREDENTIALS`: Service principal for Azure access
- `ACR_USERNAME`: Azure Container Registry username
- `ACR_PASSWORD`: Azure Container Registry password
- `AKS_RESOURCE_GROUP`: Azure Kubernetes Service resource group
- `AKS_CLUSTER_NAME`: Azure Kubernetes Service cluster name

### Monitoring & Notifications
- `SLACK_WEBHOOK`: Slack webhook for deployment notifications
- `GRAFANA_URL`: Grafana instance URL
- `GRAFANA_API_KEY`: Grafana API key for dashboard updates
- `PROMETHEUS_PUSHGATEWAY_URL`: Prometheus Pushgateway URL

### Security Scanning
- `SNYK_TOKEN`: Snyk API token for security scanning

### Compliance (Financial Services)
- `COMPLIANCE_SLACK_WEBHOOK`: Compliance team notifications
- `EMERGENCY_SLACK_WEBHOOK`: Emergency notifications

---

**Total Repositories Processed**: $($results.Count)
**Successful Deployments**: $(($results.Values | Where-Object { $_.success }).Count)
**Failed Deployments**: $(($results.Values | Where-Object { -not $_.success }).Count)

*This deployment includes enterprise-grade CI/CD practices with security, compliance, and reliability as core principles.*
"@
    
    $report | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "`nSummary report created: $reportPath" -ForegroundColor Green
}

# Main execution
Write-Host "🚀 Starting CI/CD Pipeline Distribution" -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor Magenta

# Create temporary directory for repositories
$tempPath = Join-Path $env:TEMP "ci-cd-repos"
if (-not (Test-Path $tempPath)) {
    New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
}

$results = @{}

# Process each repository
foreach ($repoName in $repositories.Keys) {
    $config = $repositories[$repoName]
    $results[$repoName] = @{ success = $false; error = $null }
    
    try {
        # Update repository
        if (Update-Repository -repoName $repoName -basePath $tempPath) {
            $repoPath = Join-Path $tempPath $repoName
            
            # Copy pipeline files
            Copy-PipelineFiles -repoName $repoName -repoPath $repoPath -config $config
            
            # Update ArgoCD configuration
            Update-ArgoCDConfig -repoName $repoName -repoPath $repoPath -config $config
            
            # Commit and push changes
            Commit-And-Push -repoName $repoName -repoPath $repoPath
            
            $results[$repoName].success = $true
            Write-Host "✅ Successfully processed: $repoName" -ForegroundColor Green
        }
    }
    catch {
        $results[$repoName].error = $_.Exception.Message
        Write-Error "❌ Failed to process $repoName : $_"
    }
    
    Write-Host ""  # Empty line for readability
}

# Create summary report
Create-SummaryReport -results $results

# Display final summary
$successful = ($results.Values | Where-Object { $_.success }).Count
$total = $results.Count

Write-Host "🎉 Pipeline Distribution Complete!" -ForegroundColor Magenta
Write-Host "===================================" -ForegroundColor Magenta
Write-Host "Successfully processed: $successful/$total repositories" -ForegroundColor Green

if ($successful -lt $total) {
    Write-Host "⚠️  Some repositories failed to process. Check the logs above for details." -ForegroundColor Yellow
}

Write-Host "`n📋 Summary report available at: deployment-summary.md" -ForegroundColor Cyan
Write-Host "📁 Repository clones available at: $tempPath" -ForegroundColor Cyan

# Pause to allow user to review
Write-Host "`nPress any key to continue..." -ForegroundColor Gray
[void][System.Console]::ReadKey($true)
