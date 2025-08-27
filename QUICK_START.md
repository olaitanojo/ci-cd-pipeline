# 🚀 Quick Start Guide - CI/CD Pipeline Distribution

This guide helps you quickly distribute comprehensive CI/CD pipeline configurations to all your GitHub repositories.

## 📋 Prerequisites

### Required Software
- ✅ **Git** - For repository operations
- ✅ **PowerShell 5.1+** - For running the distribution script
- ✅ **GitHub Account** - With push access to your repositories

### Required Access
- ✅ **GitHub Repository Access** - Push permissions to all target repositories
- ✅ **Azure Container Registry** - For container image storage (optional for testing)
- ✅ **Kubernetes Cluster** - AKS or equivalent for deployments (optional for testing)

## ⚡ Quick Deployment

### Option 1: Automated Distribution (Recommended)

1. **Clone this repository:**
   ```powershell
   git clone https://github.com/olaitanojo/ci-cd-pipelines.git
   cd ci-cd-pipelines
   ```

2. **Run the distribution script:**
   ```powershell
   .\distribute-pipelines.ps1
   ```

3. **Review the results:**
   - Check the console output for any errors
   - Review `deployment-summary.md` for detailed status
   - Verify changes in your GitHub repositories

### Option 2: Manual Distribution

1. **Choose your target repository**
2. **Navigate to project-specific files:**
   ```
   project-specific-files/
   ├── spx-options-trading-bot/
   ├── naira-remit-app/
   └── terraform-azure-infrastructure/
   ```
3. **Copy the appropriate files to your repository**
4. **Commit and push changes**

## 🔧 Configuration Files Included

### For Each Repository:
- **GitHub Actions Workflow** (`.github/workflows/ci-cd.yml`)
- **Azure DevOps Pipeline** (`azure-pipelines.yml`)
- **Jenkins Pipeline** (`Jenkinsfile`)
- **GitLab CI Configuration** (`.gitlab-ci.yml`)
- **ArgoCD Application** (`argocd/application.yml`)
- **Dockerfile** (where applicable)

### Directory Structure Created:
```
your-repo/
├── .github/workflows/ci-cd.yml
├── azure-pipelines.yml
├── Jenkinsfile
├── .gitlab-ci.yml
├── Dockerfile
├── argocd/application.yml
├── k8s/
│   ├── base/
│   └── overlays/
│       ├── development/
│       ├── staging/
│       └── production/
├── scripts/
├── monitoring/
│   ├── grafana/
│   └── prometheus/
└── README.md (updated)
```

## 🔐 Required Secrets Setup

After pipeline distribution, configure these secrets in each repository:

### GitHub Repository Secrets
Navigate to: `Settings > Secrets and variables > Actions`

```bash
# Azure Integration
AZURE_CREDENTIALS={"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}
ACR_USERNAME=your-registry-username
ACR_PASSWORD=your-registry-password
AKS_RESOURCE_GROUP=your-aks-resource-group
AKS_CLUSTER_NAME=your-aks-cluster-name

# Monitoring & Notifications
SLACK_WEBHOOK=https://hooks.slack.com/services/...
GRAFANA_URL=https://your-grafana-instance.com
GRAFANA_API_KEY=your-grafana-api-key
PROMETHEUS_PUSHGATEWAY_URL=http://pushgateway.monitoring.svc:9091

# Security Scanning
SNYK_TOKEN=your-snyk-api-token

# Financial Services (if applicable)
COMPLIANCE_SLACK_WEBHOOK=https://hooks.slack.com/services/...
EMERGENCY_SLACK_WEBHOOK=https://hooks.slack.com/services/...
```

## 🎯 Deployment Strategies by Repository

| Repository | Primary Strategy | Secondary | Use Case |
|------------|------------------|-----------|----------|
| SPX Options Trading Bot | Canary | Blue-Green | High-frequency trading |
| Naira Remit App | Blue-Green | Canary | Financial transactions |
| Market Data API | Rolling | Canary | Data processing |
| Payment Gateway | Blue-Green | Manual | Payment processing |
| Infrastructure | Manual | N/A | Infrastructure changes |

## 📊 Pipeline Features

### ✅ **Multi-Environment Support**
- Development (auto-deploy on feature branches)
- Staging (auto-deploy on staging branch)
- Production (manual approval required)

### ✅ **Advanced Testing**
- Unit Tests with coverage reporting
- Integration Tests with service dependencies
- End-to-End Tests for critical workflows
- Performance Tests for load validation
- Security Tests (SAST, dependency scanning)

### ✅ **Security & Compliance**
- Container vulnerability scanning (Trivy, Snyk)
- Infrastructure security validation (tfsec, Checkov)
- Financial services compliance (PCI DSS, AML/KYC)
- GDPR/CCPA data protection checks

### ✅ **Monitoring Integration**
- Prometheus metrics collection
- Grafana dashboard automation
- AlertManager notification setup
- Custom business metrics tracking

### ✅ **Rollback & Recovery**
- Automated rollback on failure detection
- Manual rollback procedures
- Emergency response workflows
- Incident notification systems

## 🚨 Troubleshooting

### Common Issues:

1. **Authentication Failed**
   ```bash
   # Ensure Git credentials are configured
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   
   # For HTTPS, use personal access token
   git config --global credential.helper manager-core
   ```

2. **Repository Access Denied**
   - Verify you have push permissions to target repositories
   - Check if repositories exist and are accessible
   - Ensure correct repository URLs in the script

3. **Pipeline Failures**
   - Verify all required secrets are configured
   - Check Azure/AWS credentials and permissions
   - Validate Kubernetes cluster access
   - Review container registry access

### Getting Help:

1. **Check the deployment summary:** `deployment-summary.md`
2. **Review console output** for specific error messages
3. **Verify repository access** and permissions
4. **Test with a single repository** first before bulk deployment

## 🎉 Post-Deployment Checklist

- [ ] All repositories have pipeline files
- [ ] Required secrets are configured
- [ ] Test a sample deployment in development environment
- [ ] Verify monitoring dashboards are accessible
- [ ] Confirm notification channels are working
- [ ] Review and approve production deployment settings
- [ ] Document any custom configurations
- [ ] Train team on new deployment processes

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the detailed pipeline logs
3. Validate your environment setup
4. Test with a minimal configuration first

---

**🎯 Ready to Deploy?**

Run: `.\distribute-pipelines.ps1` and watch the magic happen! ✨
