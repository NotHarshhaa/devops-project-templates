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
