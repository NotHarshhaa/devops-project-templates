# 🌩️ Terraform AWS Infrastructure Template

A production-ready Terraform template for deploying AWS infrastructure with best practices.

## 🎯 Purpose

This template helps you:
- Deploy AWS infrastructure using Infrastructure as Code
- Implement security best practices
- Set up multi-environment deployments
- Practice Terraform workflows
- Learn AWS cloud architecture

## 📁 Structure

```text
terraform-aws-infra/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   ├── s3/
│   ├── security/
│   └── monitoring/
├── scripts/
│   ├── init.sh
│   ├── plan.sh
│   ├── apply.sh
│   └── destroy.sh
├── terraform.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── backend.tf
└── README.md
```

## 🚀 Quick Start

### 1. Prerequisites
```bash
# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure
```

### 2. Initialize Terraform
```bash
# Initialize backend and modules
terraform init

# Select workspace
terraform workspace new dev
terraform workspace select dev
```

### 3. Deploy Infrastructure
```bash
# Plan changes
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply changes
terraform apply -var-file="environments/dev/terraform.tfvars"
```

## 🏗️ Architecture Overview

### Core Components
- **VPC**: Isolated network with public/private subnets
- **EKS Cluster**: Kubernetes orchestration
- **RDS Database**: Managed PostgreSQL database
- **S3 Buckets**: Object storage with encryption
- **Security Groups**: Network access controls
- **IAM Roles**: Least-privilege access

### High Availability
- Multi-AZ deployment
- Auto Scaling Groups
- Load Balancing
- Database replication

### Security
- VPC with private subnets
- Security groups and NACLs
- IAM roles and policies
- Encryption at rest and in transit
- CloudTrail logging

## 📋 Module Structure

### VPC Module
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  environment = var.environment
  project     = var.project
  
  cidr_block           = "10.0.0.0/16"
  availability_zones   = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = local.tags
}
```

### EKS Module
```hcl
module "eks" {
  source = "./modules/eks"
  
  environment = var.environment
  project     = var.project
  
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  cluster_version = "1.28"
  
  node_groups = {
    main = {
      desired_capacity = 3
      max_capacity     = 6
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
  }
  
  tags = local.tags
}
```

### RDS Module
```hcl
module "rds" {
  source = "./modules/rds"
  
  environment = var.environment
  project     = var.project
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.database_subnet_ids
  security_group_ids = [module.security.database_security_group_id]
  
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  
  database_name = "myapp"
  username      = "myapp_user"
  
  storage_type      = "gp2"
  allocated_storage = 20
  max_allocated_storage = 100
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.project}-${var.environment}-final-snapshot"
  
  tags = local.tags
}
```

## 🔧 Configuration

### Environment Variables
```bash
# AWS Configuration
export AWS_PROFILE="my-aws-profile"
export AWS_REGION="us-west-2"

# Terraform Configuration
export TF_VAR_environment="dev"
export TF_VAR_project="my-app"
```

### Terraform Variables
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    "ManagedBy" = "Terraform"
    "Team"      = "Platform"
  }
}
```

### Backend Configuration
```hcl
terraform {
  backend "s3" {
    bucket         = "my-app-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## 🔒 Security Implementation

### IAM Roles
```hcl
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project}-${var.environment}-eks-cluster-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
  
  tags = local.tags
}
```

### Security Groups
```hcl
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project}-${var.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = local.tags
}
```

### Encryption
```hcl
# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# RDS encryption
resource "aws_db_instance" "main" {
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn
}
```

## 📊 Monitoring & Logging

### CloudWatch
```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  environment = var.environment
  project     = var.project
  
  vpc_id = module.vpc.vpc_id
  
  enable_cloudwatch_logs = true
  enable_xray_tracing    = true
  
  log_groups = [
    "/aws/eks/${module.eks.cluster_name}/cluster",
    "/aws/rds/${module.rds.instance_id}"
  ]
  
  tags = local.tags
}
```

### CloudTrail
```hcl
resource "aws_cloudtrail" "main" {
  name                          = "${var.project}-${var.environment}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  s3_key_prefix                 = "cloudtrail-logs/"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  
  tags = local.tags
}
```

## 🚀 Deployment Workflows

### CI/CD Integration
```yaml
# GitHub Actions workflow
name: Terraform Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        
      - name: Terraform Init
        run: terraform init
        
      - name: Terraform Plan
        run: terraform plan -var-file="environments/dev/terraform.tfvars"
        
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -var-file="environments/dev/terraform.tfvars" -auto-approve
```

### Multi-Environment Deployment
```bash
# Development
terraform workspace select dev
terraform apply -var-file="environments/dev/terraform.tfvars"

# Staging
terraform workspace select staging
terraform apply -var-file="environments/staging/terraform.tfvars"

# Production
terraform workspace select prod
terraform apply -var-file="environments/prod/terraform.tfvars"
```

## 🧪 Testing

### Terraform Validate
```bash
# Validate syntax
terraform validate

# Check formatting
terraform fmt -check

# Security scanning
tfsec .
```

### Integration Tests
```bash
# Test infrastructure
terratest run test/

# Validate resources
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)
aws eks describe-cluster --name $(terraform output -raw cluster_name)
```

## 🔧 Management Commands

### Common Operations
```bash
# Import existing resources
terraform import aws_vpc.main vpc-12345678

# State management
terraform state list
terraform state show aws_vpc.main

# Resource tainting
terraform taint aws_instance.web

# Force unlock
terraform force-unlock LOCK_ID
```

### Drift Detection
```bash
# Plan for drift
terraform plan -detailed-exitcode

# Show drift
terraform show -json | jq '.values.root_module.resources[] | select(.mode == "managed") | select(.values != null)'
```

## 📈 Cost Optimization

### Resource Sizing
```hcl
variable "instance_types" {
  description = "EC2 instance types by environment"
  type        = map(string)
  default = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}
```

### Auto Scaling
```hcl
resource "aws_autoscaling_group" "web" {
  desired_capacity    = 2
  max_size           = 6
  min_size           = 1
  vpc_zone_identifier = module.vpc.private_subnet_ids
  
  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-web"
    propagate_at_launch = true
  }
}
```

## 🔄 Best Practices

### Code Organization
- Use modules for reusability
- Separate environments
- Consistent naming conventions
- Comprehensive tagging

### Security
- Least privilege IAM roles
- Network segmentation
- Encryption everywhere
- Regular security updates

### Reliability
- Multi-AZ deployments
- Auto Scaling
- Health checks
- Backup and recovery

### Cost Management
- Right-sized resources
- Scheduled scaling
- Resource tagging
- Regular cost reviews

## 📚 Learn More

- [Terraform Documentation](https://www.terraform.io/docs/)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/index.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## 🚀 Next Steps

- Add monitoring dashboards
- Implement backup strategies
- Set up disaster recovery
- Add compliance scanning
- Create custom modules
