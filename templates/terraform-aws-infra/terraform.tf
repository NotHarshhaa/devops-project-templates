terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }

  backend "s3" {
    bucket         = "my-app-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# Configure AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = merge(
      local.common_tags,
      {
        "ManagedBy"   = "Terraform"
        "Project"     = var.project
        "Environment" = var.environment
      }
    )
  }
}

# Configure Kubernetes Provider (after EKS creation)
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}

# Configure Helm Provider
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}

# Random resources for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Local values for common configurations
locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    "Team"        = var.team
    "Owner"       = var.owner
    "CostCenter"  = var.cost_center
    "Environment" = var.environment
    "Project"     = var.project
    "ManagedBy"   = "Terraform"
    "CreatedAt"   = timestamp()
  }

  tags = merge(local.common_tags, var.extra_tags)
}
