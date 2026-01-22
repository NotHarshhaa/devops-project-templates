# 🚀 Getting Started Guide

Welcome to the DevOps Project Templates repository! This guide will help you get up and running quickly with our production-ready DevOps templates.

## 📋 Prerequisites

Before you begin, ensure you have the following tools installed:

### Required Tools
- **Docker** & **Docker Compose** - Containerization
- **Git** - Version control
- **Node.js** & **npm** - Package management
- **kubectl** - Kubernetes CLI
- **Helm** - Kubernetes package manager
- **Terraform** - Infrastructure as Code
- **AWS CLI** - AWS command line interface

### Quick Setup
```bash
# Clone the repository
git clone https://github.com/NotHarshhaa/devops-project-templates.git
cd devops-project-templates

# Run the setup script
chmod +x scripts/setup.sh
./scripts/setup.sh
```

## 🎯 Choose Your Template

We offer five comprehensive templates based on your needs:

### 1. 🐳 Docker-Only Template
**Best for:** Simple containerized applications
```bash
cd templates/docker-only
docker-compose up -d
```

### 2. 🔄 CI/CD GitHub Actions Template
**Best for:** Automated testing and deployment
```bash
cd templates/ci-cd-github-actions
# Configure GitHub secrets
# Push to trigger CI/CD pipeline
```

### 3. ☸️ Kubernetes Application Template
**Best for:** Container orchestration
```bash
cd templates/kubernetes-app
kubectl apply -f k8s/
# Or use Helm:
helm install my-app ./helm-chart
```

### 4. 🌩️ Terraform AWS Infrastructure Template
**Best for:** Cloud infrastructure deployment
```bash
cd templates/terraform-aws-infra/environments/dev
terraform init
terraform apply
```

### 5. 🚀 Full DevOps Pipeline Template
**Best for:** Complete end-to-end DevOps workflow
```bash
cd templates/full-devops-pipeline
# Follow the comprehensive setup guide
```

## 🔧 Environment Setup

### 1. Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region (us-west-2)
# Enter default output format (json)
```

### 2. Set Up Environment Variables
```bash
# Copy the environment template
cp .env.example .env

# Edit with your configurations
nano .env
```

### 3. Configure Docker Registry (Optional)
```bash
# Login to Docker Hub
docker login

# Or configure a private registry
docker login your-registry.com
```

## 📚 Template-Specific Guides

### Docker Template Quick Start
```bash
cd templates/docker-only

# Build and run
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Kubernetes Template Quick Start
```bash
cd templates/kubernetes-app

# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy application
kubectl apply -f k8s/

# Check deployment
kubectl get pods -n my-app

# Port forward for testing
kubectl port-forward svc/my-app-service 8080:80 -n my-app
```

### Terraform Template Quick Start
```bash
cd templates/terraform-aws-infra

# Initialize Terraform
terraform init

# Plan changes
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply infrastructure
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### CI/CD Template Quick Start
```bash
cd templates/ci-cd-github-actions

# Configure GitHub repository secrets:
# - DOCKER_USERNAME
# - DOCKER_PASSWORD
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - SLACK_WEBHOOK_URL

# Push to trigger pipeline
git add .
git commit -m "Initial commit"
git push origin main
```

## 🧪 Testing Your Setup

### Validate All Templates
```bash
# Run comprehensive validation
./scripts/validate-all.sh
```

### Test Individual Templates
```bash
# Test Docker template
cd templates/docker-only
docker build -t test-app .
docker run -p 8080:80 test-app

# Test Kubernetes template
cd templates/kubernetes-app
kubectl apply --dry-run=client -f k8s/

# Test Terraform template
cd templates/terraform-aws-infra
terraform validate
```

## 🔍 Common Issues & Solutions

### Docker Issues
**Problem:** Docker daemon not running
```bash
# Start Docker daemon
sudo systemctl start docker
sudo systemctl enable docker
```

**Problem:** Permission denied
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and log back in
```

### Kubernetes Issues
**Problem:** kubectl not configured
```bash
# Update kubeconfig for EKS
aws eks update-kubeconfig --name your-cluster-name

# Test connection
kubectl cluster-info
```

**Problem:** Pod stuck in Pending state
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check node resources
kubectl top nodes
```

### Terraform Issues
**Problem:** State lock error
```bash
# Force unlock (be careful!)
terraform force-unlock LOCK_ID

# Or check who has the lock
aws dynamodb get-item --table-name terraform-locks --key '{"LockID": {"S": "your-lock-id"}}'
```

**Problem:** Provider configuration error
```bash
# Re-initialize providers
terraform init -upgrade

# Check provider versions
terraform providers
```

## 📊 Monitoring & Debugging

### Docker Monitoring
```bash
# View container stats
docker stats

# View container logs
docker logs <container-name>

# Inspect container
docker inspect <container-name>
```

### Kubernetes Monitoring
```bash
# View pod logs
kubectl logs -f <pod-name> -n <namespace>

# View events
kubectl get events --sort-by=.metadata.creationTimestamp

# Describe resources
kubectl describe pod <pod-name> -n <namespace>
```

### Terraform Debugging
```bash
# Enable detailed logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log

# Show current state
terraform show

# Import existing resources
terraform import aws_vpc.main vpc-12345678
```

## 🚀 Next Steps

### 1. Customize Templates
- Modify configurations to fit your needs
- Add your own application code
- Adjust resource sizes and scaling

### 2. Set Up Monitoring
- Configure Prometheus and Grafana
- Set up alerting rules
- Create custom dashboards

### 3. Implement Security
- Add security scanning
- Configure network policies
- Set up IAM roles and policies

### 4. Optimize Costs
- Right-size resources
- Set up auto-scaling
- Monitor spending

### 5. Automate Everything
- Create custom scripts
- Set up scheduled tasks
- Implement GitOps workflows

## 📖 Additional Resources

### Documentation
- [Architecture Overview](architecture.md)
- [Security Best Practices](security.md)
- [Monitoring Setup](monitoring.md)
- [Troubleshooting Guide](troubleshooting.md)

### External Resources
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [AWS Documentation](https://docs.aws.amazon.com/)

### Community
- [GitHub Issues](https://github.com/NotHarshhaa/devops-project-templates/issues)
- [Discussions](https://github.com/NotHarshhaa/devops-project-templates/discussions)
- [Slack Community](https://your-slack-workspace.com)

## 🆘 Getting Help

If you run into issues:

1. **Check the logs** - Most problems are logged somewhere
2. **Search existing issues** - Someone might have solved it already
3. **Ask the community** - We're here to help
4. **Create an issue** - Include logs and steps to reproduce

## 🎉 Success Metrics

You're successfully set up when you can:

- ✅ Build and run Docker containers
- ✅ Deploy to Kubernetes clusters
- ✅ Provision infrastructure with Terraform
- ✅ Run CI/CD pipelines
- ✅ Monitor your applications
- ✅ Scale resources automatically

Happy DevOps-ing! 🚀
