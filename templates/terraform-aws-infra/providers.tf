# AWS Provider Configuration
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
        "Provider"    = "AWS"
      }
    )
  }
}

# Additional AWS Provider for us-east-1 (required for some resources like ACM certificates)
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.aws_profile

  default_tags {
    tags = merge(
      local.common_tags,
      {
        "ManagedBy"   = "Terraform"
        "Project"     = var.project
        "Environment" = var.environment
        "Provider"    = "AWS"
      }
    )
  }
}

# Kubernetes Provider Configuration
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}

# Helm Provider Configuration
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}

# Random Provider Configuration
provider "random" {}

# Null Provider Configuration
provider "null" {}

# Local Provider Configuration
provider "local" {}

# Template Provider Configuration
provider "template" {}

# Data Sources

# Current AWS Region
data "aws_region" "current" {}

# Current AWS Caller Identity
data "aws_caller_identity" "current" {}

# AWS Partition
data "aws_partition" "current" {}

# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# AMI Data
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EKS Optimized AMI
data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Data
data "aws_vpc" "default" {
  default = true
}

# Subnet Data
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# IAM Policy Documents
data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "rds_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "eks_cluster_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:Describe*",
      "ec2:CreateSecurityGroup",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:ModifyNetworkInterfaceAttribute",
      "elasticloadbalancing:*",
      "iam:CreateServiceLinkedRole",
      "iam:GetRole",
      "iam:PassRole",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "eks_node_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVolumes",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:UpdateAutoScalingGroup",
      "eks:DescribeCluster",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:CreateNodegroup",
      "eks:DeleteNodegroup",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",
      "eks:TagResource",
      "eks:UntagResource",
      "cloudformation:DescribeStacks",
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStackResources",
      "cloudformation:GetTemplate",
      "cloudformation:ListStackResources",
      "iam:CreateServiceLinkedRole",
      "iam:GetRole",
      "iam:PassRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfiles",
      "iam:ListRolePolicies",
      "iam:GetInstanceProfile",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:ListRoles",
      "iam:ListUsers",
      "iam:ListGroups",
      "iam:ListAccessKeys",
      "iam:ListSSHPublicKeys",
      "iam:GetSSHPublicKey",
      "iam:UpdateSSHPublicKey",
      "iam:DeleteSSHPublicKey",
      "iam:UploadSSHPublicKey",
      "iam:CreateSSHPublicKey",
      "iam:DeleteAccessKey",
      "iam:CreateAccessKey",
      "iam:UpdateAccessKey",
      "iam:ListServiceSpecificCredentials",
      "iam:ResetServiceSpecificCredential",
      "iam:GenerateServiceSpecificCredentials",
      "iam:UpdateServiceSpecificCredential",
      "iam:DeleteServiceSpecificCredential",
      "iam:CreateServiceSpecificCredential",
      "sts:GetCallerIdentity",
      "sts:AssumeRole",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:FilterLogEvents",
      "logs:GetLogEvents",
      "logs:ListTagsLogGroup",
      "logs:TagLogGroup",
      "logs:UntagLogGroup"
    ]
    resources = ["*"]
  }
}

# KMS Key Policy
data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow EKS to use the key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}
