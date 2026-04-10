# Local modules for Terraform AWS Infrastructure

# VPC Module
module "vpc" {
  source = "./modules/vpc"
}

# Security Module  
module "security" {
  source = "./modules/security"
}

# EKS Module
module "eks" {
  source = "./modules/eks"
}

# RDS Module
module "rds" {
  source = "./modules/rds"
}

# S3 Module
module "s3" {
  source = "./modules/s3"
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
}

# Cost Estimation Module
module "cost_estimation" {
  source = "./modules/cost"
}
