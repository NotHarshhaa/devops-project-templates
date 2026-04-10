# 🔄 CI/CD GitHub Actions Template

A comprehensive CI/CD pipeline template using GitHub Actions for automated testing, building, and deployment.

## 🎯 Purpose

This template helps you:
- Implement automated testing and validation
- Build and containerize applications
- Deploy to multiple environments
- Practice DevOps best practices
- Learn GitHub Actions workflows

## 📁 Structure

```text
cicd-github-actions/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── cd.yml
│       ├── security.yml
│       └── cleanup.yml
├── Dockerfile
├── docker-compose.yml
├── app/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── tests/
│   ├── unit.test.js
│   └── e2e.test.js
├── scripts/
│   ├── build.sh
│   ├── deploy.sh
│   └── test.sh
└── README.md
```

## 🚀 Quick Start

### 1. CI Pipeline (ci.yml)
- **Trigger**: Push to main/develop branches
- **Steps**: Lint, Test, Build, Security Scan
- **Artifacts**: Build results, Test reports

### 2. CD Pipeline (cd.yml)
- **Trigger**: Manual dispatch or tag creation
- **Steps**: Deploy to staging/production
- **Environments**: Staging, Production

### 3. Security Pipeline (security.yml)
- **Trigger**: Weekly schedule + PR
- **Steps**: Vulnerability scanning, Dependency check
- **Reports**: Security findings

### 4. Cleanup Pipeline (cleanup.yml)
- **Trigger**: Monthly schedule
- **Steps**: Remove old artifacts, Clean resources

## 🔧 Environment Setup

### Required Secrets
```yaml
# GitHub Repository Secrets
DOCKER_REGISTRY_TOKEN:      # Docker Hub registry token
AWS_ACCESS_KEY_ID:         # AWS credentials (if using AWS)
AWS_SECRET_ACCESS_KEY:     # AWS secret key
KUBECONFIG:               # Kubernetes config (base64 encoded)
SLACK_WEBHOOK:            # Slack notifications (optional)
```

### Environment Variables
```yaml
# Repository Variables
DOCKER_REGISTRY:          # Docker registry URL
DOCKER_IMAGE_NAME:        # Docker image name
AWS_REGION:              # AWS region
KUBERNETES_NAMESPACE:    # K8s namespace
```

## 📋 Usage Instructions

### 1. Fork or Use Template
```bash
# Use as GitHub template
# Click "Use this template" button
```

### 2. Configure Secrets
1. Go to repository Settings > Secrets and variables > Actions
2. Add required secrets listed above
3. Configure environment variables

### 3. Customize Workflows
- Edit `.github/workflows/*.yml` files
- Adjust triggers, steps, and environments
- Add custom scripts as needed

### 4. Test Pipeline
```bash
# Create a test branch
git checkout -b test-ci-pipeline
git push origin test-ci-pipeline

# Monitor workflow in Actions tab
```

## 🎯 Pipeline Features

### ✅ CI Features
- Multi-language support (Node.js, Python, Java, Go)
- Parallel test execution
- Code coverage reporting
- Artifact caching
- Security vulnerability scanning
- Docker image building and pushing

### ✅ CD Features
- Multi-environment deployments
- Blue-green deployment strategy
- Rollback capabilities
- Health checks
- Slack/Email notifications
- Manual approval gates

### ✅ Security Features
- Dependency vulnerability scanning
- Container image scanning
- Secret leak detection
- SAST (Static Application Security Testing)
- License compliance checking

## 📊 Monitoring & Observability

### Workflow Metrics
- Success/failure rates
- Execution times
- Resource utilization
- Test coverage trends

### Alerts & Notifications
- Slack integration
- Email notifications
- GitHub status checks
- Custom webhooks

## 🛠️ Customization Examples

### Add New Test Type
```yaml
- name: Integration Tests
  run: |
    npm run test:integration
    coverage report
```

### Add Deployment Target
```yaml
- name: Deploy to Azure
  uses: azure/webapps-deploy@v2
  with:
    app-name: ${{ secrets.AZURE_APP_NAME }}
    publish-profile: ${{ secrets.AZURE_PUBLISH_PROFILE }}
```

### Add Security Step
```yaml
- name: Run Snyk Security Scan
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

## 📚 Best Practices

1. **Use Environments**: Separate staging and production
2. **Implement Gates**: Require approval for production deployments
3. **Monitor Failures**: Set up alerts for pipeline failures
4. **Cache Dependencies**: Speed up build times
5. **Use Matrix Builds**: Test across multiple versions
6. **Secure Secrets**: Never commit secrets to repository
7. **Document Workflows**: Maintain clear documentation

## 🚀 Advanced Features

### Matrix Strategy
```yaml
strategy:
  matrix:
    node-version: [16, 18, 20]
    os: [ubuntu-latest, windows-latest]
```

### Conditional Deployment
```yaml
if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

### Custom Actions
```yaml
- uses: ./.github/actions/custom-action
  with:
    parameter: value
```

## 🔍 Troubleshooting

### Common Issues
1. **Permission Errors**: Check repository permissions
2. **Secret Access**: Verify secrets are properly configured
3. **Timeout Issues**: Increase timeout values
4. **Resource Limits**: Check GitHub Actions limits

### Debug Commands
```bash
# Enable debug logging
ACTIONS_STEP_DEBUG=true

# Check runner status
gh run list --limit 10

# View workflow logs
gh run view <run-id> --log
```

## 📈 Next Steps

- Add monitoring dashboards
- Implement canary deployments
- Add performance testing
- Set up compliance scanning
- Create custom action templates

## 🔗 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Guide](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Security Best Practices](https://docs.github.com/en/actions/security-guides)
- [Community Actions](https://github.com/marketplace?type=actions)
