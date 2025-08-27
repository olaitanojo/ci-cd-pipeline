# Automated CI/CD Pipeline Deployment Script
# This script will automatically continue the deployment once the GitHub repository is created

Write-Host "🚀 AUTOMATED CI/CD PIPELINE DEPLOYMENT" -ForegroundColor Magenta
Write-Host "======================================" -ForegroundColor Magenta

function Test-GitHubRepo {
    param([string]$RepoUrl)
    try {
        $response = Invoke-WebRequest -Uri $RepoUrl -Method Head -TimeoutSec 10 -UseBasicParsing
        return $response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

function Deploy-CIPipelines {
    Write-Host "🚀 Step 2: Pushing to GitHub Repository..." -ForegroundColor Cyan
    
    try {
        git push -u origin master
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
            Write-Host "   Repository: https://github.com/olaitanojo/ci-cd-pipelines" -ForegroundColor Gray
            return $true
        }
        else {
            Write-Host "❌ Failed to push to GitHub" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Error pushing to GitHub: $_" -ForegroundColor Red
        return $false
    }
}

function Run-DistributionScript {
    Write-Host "🤖 Step 3: Running Distribution Script..." -ForegroundColor Cyan
    Write-Host "This will distribute CI/CD pipelines to all 9 repositories..." -ForegroundColor Yellow
    Write-Host ""
    
    # Ask for confirmation before running
    $confirmation = Read-Host "Do you want to proceed with distributing pipelines to all repositories? (y/N)"
    
    if ($confirmation -eq 'y' -or $confirmation -eq 'Y' -or $confirmation -eq 'yes') {
        try {
            Write-Host "🚀 Starting pipeline distribution..." -ForegroundColor Green
            & .\distribute-pipelines.ps1
            Write-Host "✅ Distribution completed!" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Error running distribution script: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "⏸️ Distribution skipped. You can run it manually later with: .\distribute-pipelines.ps1" -ForegroundColor Yellow
    }
}

function Show-SecretsConfiguration {
    Write-Host "🔐 Step 4: Repository Secrets Configuration Guide" -ForegroundColor Cyan
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "For each repository, configure these secrets in GitHub:" -ForegroundColor Yellow
    Write-Host "Navigate to: Repository Settings > Secrets and variables > Actions" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "🔵 Azure Integration Secrets:" -ForegroundColor Blue
    Write-Host "AZURE_CREDENTIALS={`"clientId`":`"xxx`",`"clientSecret`":`"xxx`",`"subscriptionId`":`"xxx`",`"tenantId`":`"xxx`"}" -ForegroundColor Gray
    Write-Host "ACR_USERNAME=your-container-registry-username" -ForegroundColor Gray
    Write-Host "ACR_PASSWORD=your-container-registry-password" -ForegroundColor Gray
    Write-Host "AKS_RESOURCE_GROUP=your-aks-resource-group-name" -ForegroundColor Gray
    Write-Host "AKS_CLUSTER_NAME=your-aks-cluster-name" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📊 Monitoring & Notifications:" -ForegroundColor Blue
    Write-Host "SLACK_WEBHOOK=https://hooks.slack.com/services/xxx" -ForegroundColor Gray
    Write-Host "GRAFANA_URL=https://your-grafana-instance.com" -ForegroundColor Gray
    Write-Host "GRAFANA_API_KEY=your-grafana-api-key" -ForegroundColor Gray
    Write-Host "PROMETHEUS_PUSHGATEWAY_URL=http://pushgateway.monitoring.svc:9091" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "🛡️ Security Scanning:" -ForegroundColor Blue
    Write-Host "SNYK_TOKEN=your-snyk-api-token" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "💰 Financial Services (for payment/remittance apps):" -ForegroundColor Blue
    Write-Host "COMPLIANCE_SLACK_WEBHOOK=https://hooks.slack.com/services/xxx" -ForegroundColor Gray
    Write-Host "EMERGENCY_SLACK_WEBHOOK=https://hooks.slack.com/services/xxx" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "📋 Priority Repositories for Secrets:" -ForegroundColor Yellow
    Write-Host "  1. 💱 Spx-options-trading-bot (Trading - HIGH PRIORITY)" -ForegroundColor Red
    Write-Host "  2. 💸 Naira-remit-node.js-app (Remittance - HIGH PRIORITY)" -ForegroundColor Red
    Write-Host "  3. 💳 Payment-gateway-api (Payments - HIGH PRIORITY)" -ForegroundColor Red
    Write-Host "  4. 📊 Market-data-api (Data - MEDIUM PRIORITY)" -ForegroundColor Yellow
    Write-Host "  5. 📈 Trading-strategy-backtester (Analytics - MEDIUM PRIORITY)" -ForegroundColor Yellow
}

# Main execution
Write-Host "Checking if GitHub repository exists..." -ForegroundColor Yellow

$repoUrl = "https://github.com/olaitanojo/ci-cd-pipelines"
$maxAttempts = 30
$attempt = 0

do {
    $attempt++
    Write-Host "  Attempt $attempt/$maxAttempts..." -ForegroundColor Gray
    
    if (Test-GitHubRepo $repoUrl) {
        Write-Host "✅ GitHub repository found!" -ForegroundColor Green
        Write-Host ""
        
        # Step 2: Push to GitHub
        if (Deploy-CIPipelines) {
            Write-Host ""
            
            # Step 3: Run distribution script
            Run-DistributionScript
            Write-Host ""
            
            # Step 4: Show secrets configuration
            Show-SecretsConfiguration
            Write-Host ""
            
            Write-Host "🎉 DEPLOYMENT COMPLETE!" -ForegroundColor Green
            Write-Host "======================" -ForegroundColor Green
            Write-Host "✅ Central repository created and populated" -ForegroundColor Green
            Write-Host "✅ Pipeline configurations ready for distribution" -ForegroundColor Green
            Write-Host "✅ Documentation and guides provided" -ForegroundColor Green
            Write-Host ""
            Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
            Write-Host "  1. Configure secrets in priority repositories" -ForegroundColor White
            Write-Host "  2. Test a deployment in development environment" -ForegroundColor White
            Write-Host "  3. Set up monitoring and alerting" -ForegroundColor White
            Write-Host "  4. Train your team on the new processes" -ForegroundColor White
            Write-Host ""
            Write-Host "📋 Documentation:" -ForegroundColor Cyan
            Write-Host "  • README.md - Main documentation" -ForegroundColor White
            Write-Host "  • QUICK_START.md - Quick deployment guide" -ForegroundColor White
            Write-Host "  • DEPLOYMENT_INSTRUCTIONS.md - Detailed instructions" -ForegroundColor White
            Write-Host ""
        }
        
        break
    }
    
    if ($attempt -ge $maxAttempts) {
        Write-Host "❌ Repository not found after $maxAttempts attempts" -ForegroundColor Red
        Write-Host "Please ensure you've created the repository manually:" -ForegroundColor Yellow
        Write-Host "  1. Go to https://github.com" -ForegroundColor White
        Write-Host "  2. Click '+' > 'New repository'" -ForegroundColor White
        Write-Host "  3. Name: ci-cd-pipelines" -ForegroundColor White
        Write-Host "  4. Public repository" -ForegroundColor White
        Write-Host "  5. Don't initialize with README" -ForegroundColor White
        Write-Host ""
        Write-Host "Then run this script again: .\auto-deploy.ps1" -ForegroundColor Cyan
        break
    }
    
    Start-Sleep -Seconds 5
} while ($true)

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
[void][System.Console]::ReadKey($true)
