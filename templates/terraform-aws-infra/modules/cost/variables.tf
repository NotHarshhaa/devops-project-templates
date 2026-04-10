variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "eks_nodes" {
  description = "EKS node configuration"
  type        = any
  default     = {}
}

variable "rds_instance" {
  description = "RDS instance configuration"
  type        = any
  default     = {}
}

variable "ebs_volumes" {
  description = "EBS volume configuration"
  type        = any
  default     = {}
}

variable "data_transfer" {
  description = "Data transfer configuration"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
