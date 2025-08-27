# Simplified CI/CD Pipeline Deployment Script
# This script handles the complete deployment process

Write-Host "CI/CD PIPELINE DEPLOYMENT" -ForegroundColor Magenta
Write-Host "=========================" -ForegroundColor Magenta
Write-Host ""

# Function to test if GitHub repository exists
function Test-Repository {
    try {
        $response = Invoke-WebRequest -Uri "https://github.com/olaitanojo/ci-cd-pipelines" -Method Head -TimeoutSec 5 -UseBasicParsing
        return $response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

Write-Host "Checking if GitHub repository exists..." -ForegroundColor Yellow
Write-Host ""

if (Test-Repository) {
    Write-Host "GitHub repository found! Proceeding with deployment..." -ForegroundColor Green
    Write-Host ""
    
    # Step 2: Push to GitHub
    Write-Host "Step 2: Pushing to GitHub..." -ForegroundColor Cyan
    git push -u origin master
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully pushed to GitHub!" -ForegroundColor Green
        Write-Host "Repository: https://github.com/olaitanojo/ci-cd-pipelines" -ForegroundColor Gray
        Write-Host ""
        
        # Step 3: Ask about distribution
        Write-Host "Step 3: Distribution Script" -ForegroundColor Cyan
        Write-Host "This will distribute CI/CD pipelines to all 9 repositories..." -ForegroundColor Yellow
        Write-Host ""
        
        $confirmation = Read-Host "Do you want to proceed with distributing pipelines? (y/N)"
        
        if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
            Write-Host "Starting pipeline distribution..." -ForegroundColor Green
            & .\distribute-pipelines.ps1
        }
        else {
            Write-Host "Distribution skipped. Run manually with: .\distribute-pipelines.ps1" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "Step 4: Secrets Configuration" -ForegroundColor Cyan
        Write-Host "=============================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Configure these secrets in each GitHub repository:" -ForegroundColor Yellow
        Write-Host "Navigate to: Repository Settings > Secrets and variables > Actions" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Azure Integration:" -ForegroundColor Blue
        Write-Host "  AZURE_CREDENTIALS" -ForegroundColor Gray
        Write-Host "  ACR_USERNAME" -ForegroundColor Gray
        Write-Host "  ACR_PASSWORD" -ForegroundColor Gray
        Write-Host "  AKS_RESOURCE_GROUP" -ForegroundColor Gray
        Write-Host "  AKS_CLUSTER_NAME" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Monitoring:" -ForegroundColor Blue
        Write-Host "  SLACK_WEBHOOK" -ForegroundColor Gray
        Write-Host "  GRAFANA_URL" -ForegroundColor Gray
        Write-Host "  GRAFANA_API_KEY" -ForegroundColor Gray
        Write-Host "  PROMETHEUS_PUSHGATEWAY_URL" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Security:" -ForegroundColor Blue
        Write-Host "  SNYK_TOKEN" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Priority Repositories:" -ForegroundColor Yellow
        Write-Host "  1. Spx-options-trading-bot (HIGH PRIORITY)" -ForegroundColor Red
        Write-Host "  2. Naira-remit-node.js-app (HIGH PRIORITY)" -ForegroundColor Red
        Write-Host "  3. Payment-gateway-api (HIGH PRIORITY)" -ForegroundColor Red
        Write-Host ""
        
        Write-Host "DEPLOYMENT COMPLETE!" -ForegroundColor Green
        Write-Host "===================" -ForegroundColor Green
        Write-Host "Central repository: https://github.com/olaitanojo/ci-cd-pipelines" -ForegroundColor Green
        Write-Host ""
        
    }
    else {
        Write-Host "Failed to push to GitHub. Please check your credentials." -ForegroundColor Red
    }
}
else {
    Write-Host "GitHub repository not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create the repository manually:" -ForegroundColor Yellow
    Write-Host "  1. Go to https://github.com" -ForegroundColor White
    Write-Host "  2. Click '+' > 'New repository'" -ForegroundColor White
    Write-Host "  3. Name: ci-cd-pipelines" -ForegroundColor White
    Write-Host "  4. Public repository" -ForegroundColor White
    Write-Host "  5. Don't initialize with README" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run this script again: .\deploy-simple.ps1" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
[void][System.Console]::ReadKey($true)
