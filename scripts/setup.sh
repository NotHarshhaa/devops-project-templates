#!/bin/bash

# DevOps Project Templates Setup Script
# This script helps set up the development environment for all templates

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install a tool (macOS)
install_macos() {
    if command_exists brew; then
        brew install "$1"
    else
        print_error "Homebrew not found. Please install Homebrew first."
        exit 1
    fi
}

# Function to install a tool (Ubuntu/Debian)
install_ubuntu() {
    sudo apt-get update && sudo apt-get install -y "$1"
}

# Function to install a tool (Windows)
install_windows() {
    if command_exists choco; then
        choco install "$1"
    elif command_exists winget; then
        winget install "$1"
    else
        print_error "Please install Chocolatey or Winget first."
        exit 1
    fi
}

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos";;
        Linux*)     
            if [ -f /etc/debian_version ]; then
                echo "ubuntu"
            else
                echo "linux"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)          echo "unknown";;
    esac
}

OS=$(detect_os)

print_status "Setting up DevOps Project Templates development environment..."
print_status "Detected OS: $OS"

# Check and install required tools
print_status "Checking required tools..."

# Docker
if command_exists docker; then
    print_success "Docker is installed"
else
    print_warning "Docker is not installed"
    case $OS in
        macos)
            print_status "Installing Docker Desktop for Mac..."
            install_macos docker
            ;;
        ubuntu)
            print_status "Installing Docker..."
            install_ubuntu docker.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            ;;
        windows)
            print_status "Please install Docker Desktop for Windows manually from https://docker.com"
            ;;
    esac
fi

# Docker Compose
if command_exists docker-compose || docker compose version &> /dev/null; then
    print_success "Docker Compose is installed"
else
    print_warning "Docker Compose is not installed"
    case $OS in
        macos)
            install_macos docker-compose
            ;;
        ubuntu)
            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            ;;
        windows)
            print_status "Docker Compose is included with Docker Desktop for Windows"
            ;;
    esac
fi

# Git
if command_exists git; then
    print_success "Git is installed"
else
    print_warning "Git is not installed"
    case $OS in
        macos)
            install_macos git
            ;;
        ubuntu)
            install_ubuntu git
            ;;
        windows)
            install_windows git
            ;;
    esac
fi

# Node.js and npm
if command_exists node && command_exists npm; then
    print_success "Node.js and npm are installed"
else
    print_warning "Node.js/npm is not installed"
    case $OS in
        macos)
            install_macos node
            ;;
        ubuntu)
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
            install_ubuntu nodejs
            ;;
        windows)
            install_windows nodejs
            ;;
    esac
fi

# kubectl
if command_exists kubectl; then
    print_success "kubectl is installed"
else
    print_warning "kubectl is not installed"
    case $OS in
        macos)
            install_macos kubectl
            ;;
        ubuntu)
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
            ;;
        windows)
            install_windows kubernetes-cli
            ;;
    esac
fi

# Helm
if command_exists helm; then
    print_success "Helm is installed"
else
    print_warning "Helm is not installed"
    case $OS in
        macos)
            install_macos helm
            ;;
        ubuntu)
            curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
            sudo mv linux-amd64/helm /usr/local/bin/
            ;;
        windows)
            install_windows kubernetes-helm
            ;;
    esac
fi

# Terraform
if command_exists terraform; then
    print_success "Terraform is installed"
else
    print_warning "Terraform is not installed"
    case $OS in
        macos)
            install_macos terraform
            ;;
        ubuntu)
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt-get update && install_ubuntu terraform
            ;;
        windows)
            install_windows terraform
            ;;
    esac
fi

# AWS CLI
if command_exists aws; then
    print_success "AWS CLI is installed"
else
    print_warning "AWS CLI is not installed"
    case $OS in
        macos)
            install_macos awscli
            ;;
        ubuntu)
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
            ;;
        windows)
            install_windows awscli
            ;;
    esac
fi

# Optional tools
print_status "Installing optional development tools..."

# yamllint for YAML validation
if command_exists yamllint; then
    print_success "yamllint is installed"
else
    case $OS in
        macos)
            install_macos yamllint
            ;;
        ubuntu)
            install_ubuntu yamllint
            ;;
        windows)
            pip install yamllint
            ;;
    esac
fi

# hadolint for Dockerfile validation
if command_exists hadolint; then
    print_success "hadolint is installed"
else
    case $OS in
        macos)
            install_macos hadolint
            ;;
        ubuntu)
            wget -O hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
            chmod +x hadolint
            sudo mv hadolint /usr/local/bin/
            ;;
        windows)
            choco install hadolint
            ;;
    esac
fi

# jq for JSON processing
if command_exists jq; then
    print_success "jq is installed"
else
    case $OS in
        macos)
            install_macos jq
            ;;
        ubuntu)
            install_ubuntu jq
            ;;
        windows)
            choco install jq
            ;;
    esac
fi

# Setup development environment
print_status "Setting up development environment..."

# Ensure scripts directory exists
mkdir -p scripts

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_status "Creating .env file..."
    cat > .env << EOF
# DevOps Project Templates Environment Variables
AWS_REGION=us-west-2
AWS_PROFILE=default
PROJECT_NAME=my-app
ENVIRONMENT=dev

# Docker Configuration
DOCKER_REGISTRY=docker.io
DOCKER_USERNAME=your-docker-username

# Kubernetes Configuration
KUBECONFIG=~/.kube/config

# Notification Configuration
SLACK_WEBHOOK_URL=your-slack-webhook-url
NOTIFICATION_EMAIL=your-email@company.com
EOF
    print_success "Created .env file. Please update it with your configurations."
fi

# Setup pre-commit hooks
print_status "Setting up pre-commit hooks..."
if command_exists pre-commit; then
    pre-commit install
else
    print_warning "pre-commit not found. Installing..."
    case $OS in
        macos|ubuntu)
            pip install pre-commit
            ;;
        windows)
            pip install pre-commit
            ;;
    esac
    pre-commit install
fi

# Create pre-commit configuration
if [ ! -f .pre-commit-config.yaml ]; then
    cat > .pre-commit-config.yaml << EOF
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-merge-conflict

  - repo: https://github.com/hadolint/hadolint
    rev: v2.12.0
    hooks:
      - id: hadolint-docker
        files: Dockerfile.*

  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.33.0
    hooks:
      - id: markdownlint
        args: [--fix]

  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.81.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
        args: [--args=--config-file=.tflint.hcl]
      - id: terraform_tfsec
EOF
    print_success "Created pre-commit configuration."
fi

# Create tflint configuration
if [ ! -f .tflint.hcl ]; then
    cat > .tflint.hcl << EOF
config {
  format = "compact"
  call_module_type = "all"

  plugin_dir = "~/.tflint.d/plugins"

  disabled_by_default = false

  force = false

  varfile = ["terraform.tfvars"]

  vars = {
    environment = "dev"
  }
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_workspace_remote" {
  enabled = false
}
EOF
    print_success "Created tflint configuration."
fi

# Create VS Code settings
if [ ! -d .vscode ]; then
    print_status "Creating VS Code settings..."
    mkdir -p .vscode
    cat > .vscode/settings.json << EOF
{
    "terraform.format.enable": true,
    "terraform.validateOnSave": true,
    "terraform.lintOnSave": true,
    "terraform.codelens.referenceCount": true,
    "yaml.validate": true,
    "docker.languageserver.formatter.ignoreMultilineInstructions": true,
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/node_modules": true,
        "**/dist": true,
        "**/build": true
    },
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": true
    }
}
EOF
    print_success "Created VS Code settings."
fi

# Create useful scripts
print_status "Creating utility scripts..."

# Create validate-all.sh script
print_status "Creating validate-all.sh script..."
cat > scripts/validate-all.sh << 'EOF'
#!/bin/bash
# Validate all templates

echo "🧪 Validating all DevOps templates..."

# Validate Docker template
if [ -d "templates/docker-only" ]; then
    echo "🐳 Validating Docker template..."
    cd templates/docker-only
    docker build -t test-docker-template .
    docker-compose config
    cd ../..
else
    echo "⚠️  Docker template not found, skipping..."
fi

# Validate Kubernetes template
if [ -d "templates/kubernetes-app" ]; then
    echo "☸️  Validating Kubernetes template..."
    cd templates/kubernetes-app
    kubectl apply --dry-run=client -f k8s/
    helm lint helm-chart/
    cd ../..
else
    echo "⚠️  Kubernetes template not found, skipping..."
fi

# Validate Terraform template
if [ -d "templates/terraform-aws-infra" ]; then
    echo "🌩️  Validating Terraform template..."
    cd templates/terraform-aws-infra
    terraform init -backend=false
    terraform validate
    terraform fmt -check
    cd ../..
else
    echo "⚠️  Terraform template not found, skipping..."
fi

echo "✅ Template validation completed!"
EOF
chmod +x scripts/validate-all.sh

# Create clean-all.sh script
cat > scripts/clean-all.sh << 'EOF'
#!/bin/bash
# Clean up all Docker images and containers

echo "🧹 Cleaning up Docker resources..."

# Stop all containers
docker stop $(docker ps -aq) 2>/dev/null || true

# Remove all containers
docker rm $(docker ps -aq) 2>/dev/null || true

# Remove all images
docker rmi $(docker images -q) 2>/dev/null || true

# Clean up volumes
docker volume prune -f

# Clean up build cache
docker builder prune -f

echo "✅ Docker cleanup completed!"
EOF
chmod +x scripts/clean-all.sh

# Create deploy-all.sh script
print_status "Creating deploy-all.sh script..."
cat > scripts/deploy-all.sh << 'EOF'
#!/bin/bash
# Deploy all templates to development environment

echo "🚀 Deploying all templates to development environment..."

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "⚠️  .env file not found, using default values..."
fi

# Deploy Docker template
if [ -d "templates/docker-only" ]; then
    echo "🐳 Deploying Docker template..."
    cd templates/docker-only
    docker-compose up -d
    cd ../..
else
    echo "⚠️  Docker template not found, skipping..."
fi

# Deploy Terraform infrastructure
if [ -d "templates/terraform-aws-infra/environments/dev" ]; then
    echo "🌩️ Deploying Terraform infrastructure..."
    cd templates/terraform-aws-infra/environments/dev
    terraform init
    terraform apply -auto-approve
    cd ../../..
else
    echo "⚠️  Terraform template not found, skipping..."
fi

# Deploy Kubernetes application
if [ -d "templates/kubernetes-app" ] && command -v kubectl &> /dev/null; then
    echo "☸️  Deploying Kubernetes application..."
    if [ -n "$PROJECT_NAME" ]; then
        aws eks update-kubeconfig --name ${PROJECT_NAME}-dev-eks 2>/dev/null || echo "⚠️  Could not update kubeconfig"
    fi
    cd templates/kubernetes-app
    kubectl apply -f k8s/
    cd ../..
else
    echo "⚠️  Kubernetes template not found or kubectl not installed, skipping..."
fi

echo "✅ Deployment process completed!"
EOF
chmod +x scripts/deploy-all.sh

print_success "Created utility scripts in scripts/ directory."

# Final instructions
print_success "Setup completed successfully!"
echo ""
print_status "Next steps:"
echo "1. Update the .env file with your specific configurations"
echo "2. Configure your AWS credentials: aws configure"
echo "3. Test the setup: ./scripts/validate-all.sh"
echo "4. Start developing! 🚀"
echo ""
print_status "Useful commands:"
echo "- Validate all templates: ./scripts/validate-all.sh"
echo "- Clean up Docker resources: ./scripts/clean-all.sh"
echo "- Deploy all templates: ./scripts/deploy-all.sh"
echo ""
print_status "Happy coding! 🎉"
