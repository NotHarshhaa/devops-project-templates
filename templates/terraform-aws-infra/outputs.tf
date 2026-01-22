output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = module.vpc.database_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  description = "Certificate authority data of the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "eks_node_group_iam_role_arn" {
  description = "IAM role ARN of the EKS node group"
  value       = module.eks.node_group_iam_role_arn
}

output "eks_node_group_name" {
  description = "Name of the EKS node group"
  value       = module.eks.node_group_name
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.rds.instance_id
}

output "rds_instance_arn" {
  description = "RDS instance ARN"
  value       = module.rds.instance_arn
}

output "rds_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.instance_endpoint
}

output "rds_instance_port" {
  description = "RDS instance port"
  value       = module.rds.instance_port
}

output "rds_instance_status" {
  description = "RDS instance status"
  value       = module.rds.instance_status
}

output "rds_subnet_group_name" {
  description = "RDS subnet group name"
  value       = module.rds.subnet_group_name
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.rds.security_group_id
}

output "s3_state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.s3.state_bucket_name
}

output "s3_state_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = module.s3.state_bucket_arn
}

output "s3_app_bucket_name" {
  description = "Name of the S3 bucket for application data"
  value       = module.s3.app_bucket_name
}

output "s3_app_bucket_arn" {
  description = "ARN of the S3 bucket for application data"
  value       = module.s3.app_bucket_arn
}

output "s3_logs_bucket_name" {
  description = "Name of the S3 bucket for logs"
  value       = module.s3.logs_bucket_name
}

output "s3_logs_bucket_arn" {
  description = "ARN of the S3 bucket for logs"
  value       = module.s3.logs_bucket_arn
}

output "security_group_eks_id" {
  description = "Security group ID for EKS cluster"
  value       = module.security.eks_security_group_id
}

output "security_group_rds_id" {
  description = "Security group ID for RDS"
  value       = module.security.rds_security_group_id
}

output "security_group_bastion_id" {
  description = "Security group ID for bastion host"
  value       = module.security.bastion_security_group_id
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = module.monitoring.cloudwatch_log_group_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = module.monitoring.sns_topic_arn
}

output "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = module.monitoring.cloudtrail_s3_bucket_name
}

output "cloudtrail_s3_bucket_arn" {
  description = "ARN of the S3 bucket for CloudTrail logs"
  value       = module.monitoring.cloudtrail_s3_bucket_arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.eks.load_balancer_dns_name
}

output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = "http://${module.eks.load_balancer_dns_name}"
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.security.bastion_public_ip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i ~/.ssh/bastion-key.pem ec2-user@${module.security.bastion_public_ip}"
}

output "kubernetes_config_map_aws_auth" {
  description = "Kubernetes ConfigMap for AWS IAM authentication"
  value       = module.eks.kubernetes_config_map_aws_auth
}

output "helm_release_status" {
  description = "Status of Helm releases"
  value       = module.eks.helm_release_status
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "project_name" {
  description = "Project name"
  value       = var.project
}

output "environment" {
  description = "Environment"
  value       = var.environment
}

output "tags" {
  description = "Tags applied to all resources"
  value       = local.tags
}

# Cost and Usage Outputs
output "estimated_monthly_cost" {
  description = "Estimated monthly cost in USD"
  value       = module.cost_estimation.monthly_cost
}

output "cost_breakdown" {
  description = "Cost breakdown by service"
  value       = module.cost_estimation.cost_breakdown
}

# Security Outputs
output "security_findings" {
  description = "Security scan findings"
  value       = module.security.security_findings
}

output "compliance_status" {
  description = "Compliance status"
  value       = module.security.compliance_status
}

# Monitoring Outputs
output "monitoring_dashboard_urls" {
  description = "URLs for monitoring dashboards"
  value       = module.monitoring.dashboard_urls
}

output "alert_endpoints" {
  description = "Alert notification endpoints"
  value       = module.monitoring.alert_endpoints
}
