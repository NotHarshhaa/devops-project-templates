# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project            = var.project
  environment        = var.environment
  aws_region         = var.aws_region
  
  cidr_block           = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_flow_logs     = var.enable_flow_logs
  
  tags = local.tags
}

# Security Module
module "security" {
  source = "./modules/security"
  
  project     = var.project
  environment = var.environment
  aws_region  = var.aws_region
  
  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = module.vpc.vpc_cidr_block
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  database_subnet_ids = module.vpc.database_subnet_ids
  
  enable_ssh_access    = var.enable_ssh_access
  ssh_allowed_cidrs    = var.ssh_allowed_cidrs
  enable_bastion_host  = var.enable_bastion_host
  
  tags = local.tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"
  
  project     = var.project
  environment = var.environment
  aws_region  = var.aws_region
  
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  cluster_name   = var.cluster_name != "" ? var.cluster_name : "${var.project}-${var.environment}-eks"
  cluster_version = var.cluster_version
  
  node_groups = var.node_groups
  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  
  cluster_security_group_id = module.security.eks_security_group_id
  node_security_group_id    = module.security.node_security_group_id
  
  tags = local.tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  project     = var.project
  environment = var.environment
  aws_region  = var.aws_region
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.database_subnet_ids
  security_group_ids = [module.security.rds_security_group_id]
  
  engine         = var.database_engine
  engine_version = var.database_engine_version
  instance_class = var.database_instance_class
  
  database_name = var.database_name
  username      = var.database_username
  password      = var.database_password != "" ? var.database_password : null
  
  allocated_storage     = var.database_allocated_storage
  max_allocated_storage = var.database_max_allocated_storage
  
  backup_retention_period = var.database_backup_retention_period
  backup_window          = var.database_backup_window
  maintenance_window     = var.database_maintenance_window
  
  skip_final_snapshot = var.database_skip_final_snapshot
  final_snapshot_identifier = var.database_skip_final_snapshot ? null : "${var.project}-${var.environment}-final-snapshot-${random_string.suffix.result}"
  
  tags = local.tags
}

# S3 Module
module "s3" {
  source = "./modules/s3"
  
  project     = var.project
  environment = var.environment
  aws_region  = var.aws_region
  
  bucket_name_prefix = var.s3_bucket_name_prefix
  
  enable_versioning = var.enable_s3_versioning
  enable_encryption = var.enable_s3_encryption
  
  lifecycle_rules = var.s3_lifecycle_rules
  
  tags = local.tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  
  project     = var.project
  environment = var.environment
  aws_region  = var.aws_region
  
  vpc_id = module.vpc.vpc_id
  
  enable_cloudwatch_metrics = var.enable_cloudwatch_metrics
  enable_xray_tracing      = var.enable_xray_tracing
  enable_sns_notifications = var.enable_sns_notifications
  enable_cloudtrail        = var.enable_cloudtrail
  enable_config           = var.enable_config
  
  notification_email = var.notification_email
  
  cluster_name = module.eks.cluster_name
  rds_instance_id = module.rds.instance_id
  
  tags = local.tags
}

# Random password generator for database
resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "_!%@"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

# Random password generator for Grafana default password
resource "random_password" "grafana_default" {
  length           = 24
  special          = true
  override_special = "_!%@"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

# Random string for unique identifiers
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Cost Estimation Module (Optional)
module "cost_estimation" {
  source = "./modules/cost"
  
  project     = var.project
  environment = var.environment
  
  # Cost calculation inputs
  eks_nodes = {
    count = sum([for ng in var.node_groups : ng.desired_capacity])
    type  = var.node_groups["main"].instance_types[0]
  }
  
  rds_instance = {
    class = var.database_instance_class
    storage = var.database_allocated_storage
  }
  
  ebs_volumes = {
    total_size = 100 # GB
    type       = "gp3"
  }
  
  data_transfer = {
    outbound_gb_per_month = 100
  }
  
  tags = local.tags
}

# Kubernetes Resources (deployed after EKS is created)
resource "kubernetes_namespace" "app" {
  metadata {
    name = "${var.project}-app"
    
    labels = {
      name        = "${var.project}-app"
      environment = var.environment
      project     = var.project
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  
  data = {
    NODE_ENV       = var.environment
    AWS_REGION     = var.aws_region
    CLUSTER_NAME   = module.eks.cluster_name
    RDS_ENDPOINT   = module.rds.instance_endpoint
    RDS_DATABASE   = var.database_name
    S3_BUCKET      = module.s3.app_bucket_name
  }
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "app-secrets"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  
  data = {
    DATABASE_PASSWORD = var.database_password != "" ? var.database_password : random_password.db_password.result
    RDS_USERNAME      = var.database_username
  }
  
  type = "Opaque"
}

# Helm Releases
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  
  create_namespace = true
  
  set {
    name  = "controller.replicaCount"
    value = var.environment == "prod" ? 3 : 1
  }
  
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  
  depends_on = [module.eks]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  
  create_namespace = true
  
  set {
    name  = "installCRDs"
    value = "true"
  }
  
  depends_on = [helm_release.nginx_ingress]
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  
  create_namespace = true
  
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "15d"
  }
  
  set {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_default.result
  }
  
  depends_on = [helm_release.cert_manager]
}

# External DNS (if domain is provided)
resource "helm_release" "external_dns" {
  count = var.domain_name != "" ? 1 : 0
  
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  namespace  = "external-dns"
  
  create_namespace = true
  
  set {
    name  = "provider"
    value = "aws"
  }
  
  set {
    name  = "aws.zoneType"
    value = "public"
  }
  
  set {
    name  = "domainFilters[0]"
    value = var.domain_name
  }
  
  depends_on = [helm_release.prometheus]
}

# Cluster Autoscaler
resource "helm_release" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0
  
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  
  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }
  
  set {
    name  = "awsRegion"
    value = var.aws_region
  }
  
  set {
    name  = "rbac.create"
    value = "true"
  }
  
  depends_on = [module.eks]
}

# Application Deployment (Example)
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "${var.project}-app"
    namespace = kubernetes_namespace.app.metadata[0].name
    
    labels = {
      app = var.project
    }
  }
  
  spec {
    replicas = var.environment == "prod" ? 3 : 1
    
    selector {
      match_labels = {
        app = var.project
      }
    }
    
    template {
      metadata {
        labels = {
          app = var.project
        }
      }
      
      spec {
        container {
          name  = "app"
          image = "nginx:latest"
          
          port {
            container_port = 80
          }
          
          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata[0].name
            }
          }
          
          env_from {
            secret_ref {
              name = kubernetes_secret.app_secrets.metadata[0].name
            }
          }
          
          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.project}-app-service"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  
  spec {
    selector = {
      app = var.project
    }
    
    port {
      port        = 80
      target_port = 80
    }
    
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress" "app" {
  metadata {
    name      = "${var.project}-app-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
    
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  
  spec {
    tls {
      hosts       = var.domain_name != "" ? [var.domain_name] : []
      secret_name = var.domain_name != "" ? "${var.project}-tls" : null
    }
    
    rule {
      host = var.domain_name != "" ? var.domain_name : null
      
      http {
        path {
          path = "/"
          
          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  
  depends_on = [helm_release.cert_manager]
}
