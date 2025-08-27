# 🔐 GitHub Repository Secrets Configuration Guide

This guide provides detailed instructions for configuring all required secrets in your GitHub repositories to enable the CI/CD pipelines.

## 📍 How to Configure Secrets

For each repository, follow these steps:

1. **Go to your repository on GitHub**
2. **Click on "Settings"** (in the repository tab bar)
3. **Navigate to**: `Secrets and variables` → `Actions`
4. **Click "New repository secret"**
5. **Add each secret** from the lists below

---

## 🔵 **AZURE INTEGRATION SECRETS** (Required for Production)

### `AZURE_CREDENTIALS`
**Format**: JSON object with your Azure service principal
```json
{
  "clientId": "your-azure-client-id-here",
  "clientSecret": "your-azure-client-secret-here", 
  "subscriptionId": "your-azure-subscription-id-here",
  "tenantId": "your-azure-tenant-id-here"
}
```

**How to get these values:**
1. Go to Azure Portal → Azure Active Directory → App registrations
2. Create a new app registration or use existing one
3. Note down: Application (client) ID, Directory (tenant) ID
4. Create a client secret in "Certificates & secrets"
5. Get your subscription ID from Azure Portal → Subscriptions

### `ACR_USERNAME`
**Value**: Your Azure Container Registry username
**Example**: `myregistry` (if your ACR is myregistry.azurecr.io)

### `ACR_PASSWORD`
**Value**: Your Azure Container Registry password/access key
**How to get**: Azure Portal → Container Registry → Access keys → Enable admin user

### `AKS_RESOURCE_GROUP`
**Value**: Your Azure Kubernetes Service resource group name
**Example**: `my-kubernetes-rg`

### `AKS_CLUSTER_NAME`
**Value**: Your Azure Kubernetes Service cluster name
**Example**: `my-aks-cluster`

---

## 📊 **MONITORING & NOTIFICATIONS SECRETS** (Recommended)

### `SLACK_WEBHOOK`
**Value**: Your Slack webhook URL for deployment notifications
**Format**: `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX`
**How to get**: Slack → Apps → Incoming Webhooks → Create New App

### `GRAFANA_URL`
**Value**: Your Grafana instance URL
**Example**: `https://your-company-grafana.com` or `https://grafana.example.com`

### `GRAFANA_API_KEY`
**Value**: Grafana API key for updating dashboards
**How to get**: Grafana → Configuration → API Keys → Add API Key (Editor role)

### `PROMETHEUS_PUSHGATEWAY_URL`
**Value**: Prometheus Pushgateway URL for metrics
**Example**: `http://pushgateway.monitoring.svc.cluster.local:9091`
**Local example**: `http://localhost:9091`

---

## 🛡️ **SECURITY SCANNING SECRETS** (Recommended)

### `SNYK_TOKEN`
**Value**: Your Snyk API token for vulnerability scanning
**How to get**: 
1. Sign up at https://snyk.io
2. Go to Account Settings → General → Auth Token
3. Copy the token

---

## 💰 **FINANCIAL SERVICES SECRETS** (For Payment/Trading Apps)

### `COMPLIANCE_SLACK_WEBHOOK`
**Value**: Slack webhook for compliance team notifications
**Format**: `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX`

### `EMERGENCY_SLACK_WEBHOOK`
**Value**: Slack webhook for emergency notifications
**Format**: `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX`

---

## 🎯 **PRIORITY REPOSITORIES FOR CONFIGURATION**

Configure secrets in this order:

### 🔴 **HIGH PRIORITY - Configure First**

#### 1. **SPX Options Trading Bot** 
- **Repository**: https://github.com/olaitanojo/Spx-options-trading-bot
- **Required Secrets**: All Azure secrets + SLACK_WEBHOOK + SNYK_TOKEN
- **Deployment Strategy**: Canary (10% → 25% → 50% → 100%)
- **Why Priority**: Trading system requires robust deployment validation

**Direct Link to Configure Secrets**:
👉 **[Configure SPX Bot Secrets](https://github.com/olaitanojo/Spx-options-trading-bot/settings/secrets/actions)**

---

### 🟡 **MEDIUM PRIORITY - Configure Next**

#### 2. **Market Data API**
- **Repository**: https://github.com/olaitanojo/Market-data-api
- **Required Secrets**: Azure secrets + SLACK_WEBHOOK + SNYK_TOKEN
- **Deployment Strategy**: Rolling Updates
- **Why Priority**: Data processing with continuous updates

**Direct Link to Configure Secrets**:
👉 **[Configure Market Data Secrets](https://github.com/olaitanojo/Market-data-api/settings/secrets/actions)**

#### 3. **Trading Strategy Backtester**
- **Repository**: https://github.com/olaitanojo/Trading-strategy-backtester
- **Required Secrets**: Azure secrets + SLACK_WEBHOOK + SNYK_TOKEN
- **Deployment Strategy**: Canary
- **Why Priority**: Analytics system with performance validation

**Direct Link to Configure Secrets**:
👉 **[Configure Backtester Secrets](https://github.com/olaitanojo/Trading-strategy-backtester/settings/secrets/actions)**

---

## 🧪 **TESTING YOUR CONFIGURATION**

After configuring secrets, test your setup:

### 1. **Trigger a Test Deployment**
```bash
# Push a small change to trigger the pipeline
git add .
git commit -m "Test: Trigger CI/CD pipeline"
git push origin main
```

### 2. **Monitor the Pipeline**
- Go to your repository → Actions tab
- Watch the workflow execution
- Check each step for any secret-related errors

### 3. **Verify Integration**
- Azure: Check if containers are built and pushed
- Slack: Verify notifications are received
- Security: Check if vulnerability scans run
- Monitoring: Verify metrics are published

---

## 🚨 **TROUBLESHOOTING**

### Common Secret Issues:

1. **Azure Authentication Fails**
   ```
   Error: AADSTS70011: The provided value for the input parameter 'scope' is not valid
   ```
   **Solution**: Verify AZURE_CREDENTIALS format is valid JSON with correct values

2. **Container Registry Access Denied**
   ```
   Error: unauthorized: authentication required
   ```
   **Solution**: Check ACR_USERNAME and ACR_PASSWORD are correct and admin user is enabled

3. **Kubernetes Access Issues**
   ```
   Error: error: You must be logged in to the server (Unauthorized)
   ```
   **Solution**: Verify AKS_RESOURCE_GROUP and AKS_CLUSTER_NAME are correct

4. **Slack Notifications Not Received**
   **Solution**: Test webhook URL manually with curl or check webhook is active in Slack

---

## 📋 **SECRETS CHECKLIST**

Use this checklist to track your configuration:

### SPX Options Trading Bot:
- [ ] AZURE_CREDENTIALS
- [ ] ACR_USERNAME  
- [ ] ACR_PASSWORD
- [ ] AKS_RESOURCE_GROUP
- [ ] AKS_CLUSTER_NAME
- [ ] SLACK_WEBHOOK
- [ ] SNYK_TOKEN

### Market Data API:
- [ ] AZURE_CREDENTIALS
- [ ] ACR_USERNAME
- [ ] ACR_PASSWORD  
- [ ] AKS_RESOURCE_GROUP
- [ ] AKS_CLUSTER_NAME
- [ ] SLACK_WEBHOOK
- [ ] SNYK_TOKEN

### Trading Strategy Backtester:
- [ ] AZURE_CREDENTIALS
- [ ] ACR_USERNAME
- [ ] ACR_PASSWORD
- [ ] AKS_RESOURCE_GROUP
- [ ] AKS_CLUSTER_NAME
- [ ] SLACK_WEBHOOK
- [ ] SNYK_TOKEN

---

## 🎯 **QUICK START - MINIMUM VIABLE CONFIGURATION**

If you want to start with the basics, configure just these secrets first:

1. **AZURE_CREDENTIALS** - For Azure integration
2. **SLACK_WEBHOOK** - For notifications
3. **SNYK_TOKEN** - For security scanning

This will get your pipelines running with basic functionality.

---

## 📞 **NEED HELP?**

If you encounter issues:
1. Check the GitHub Actions logs for specific error messages
2. Verify secret names match exactly (case-sensitive)
3. Test Azure credentials manually using Azure CLI
4. Verify webhook URLs by testing them directly

---

**🎉 Once configured, your repositories will have enterprise-grade CI/CD with automated deployments, security scanning, and monitoring!**
