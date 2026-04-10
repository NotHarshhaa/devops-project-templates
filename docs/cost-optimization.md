# 💰 Cost Optimization Guide

This document provides comprehensive guidance on optimizing costs across your DevOps infrastructure while maintaining performance and reliability.

## Table of Contents

- [Cost Optimization Strategy](#cost-optimization-strategy)
- [Compute Optimization](#compute-optimization)
- [Storage Optimization](#storage-optimization)
- [Network Optimization](#network-optimization)
- [Database Optimization](#database-optimization)
- [Container Optimization](#container-optimization)
- [Monitoring Costs](#monitoring-costs)
- [Cost Management Tools](#cost-management-tools)

---

## Cost Optimization Strategy

### Cost Optimization Framework

```
┌─────────────────────────────────────────────────────┐
│              Cost Optimization Strategy              │
│                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌───────────┐  │
│  │   Right    │  │   Auto     │  │  Monitor  │  │
│  │  Sizing    │  │  Scaling   │  │   & Alert │  │
│  └─────────────┘  └─────────────┘  └───────────┘  │
│         │                │                │         │
│         ▼                ▼                ▼         │
│  ┌─────────────┐  ┌─────────────┐  ┌───────────┐  │
│  │   Spot &   │  │   Storage   │  │  Reserved │  │
│  │  Reserved  │  │ Lifecycle   │  │ Instances │  │
│  └─────────────┘  └─────────────┘  └───────────┘  │
└─────────────────────────────────────────────────────┘
```

### Core Principles

1. **Right-Size Resources**: Use appropriately sized resources
2. **Auto-Scaling**: Scale based on demand
3. **Use Spot Instances**: Take advantage of spot pricing
4. **Reserved Instances**: Commit for discounts
5. **Storage Optimization**: Use appropriate storage tiers
6. **Monitor Continuously**: Track and alert on costs
7. **Eliminate Waste**: Remove unused resources

---

## Compute Optimization

### EC2 Instance Optimization

```hcl
# Use appropriate instance types
resource "aws_instance" "web" {
  # Development: t3.micro
  # Production: m5.large or c5.large
  instance_type = var.environment == "prod" ? "m5.large" : "t3.micro"

  # Enable detailed monitoring
  monitoring = true

  # Use spot instances for non-critical workloads
  spot_price    = var.environment == "prod" ? null : 0.005
  spot_type     = "one-time"

  tags = {
    Environment = var.environment
    CostCenter  = var.cost_center
  }
}
```

### Auto-Scaling Groups

```hcl
resource "aws_autoscaling_group" "web" {
  min_size = var.environment == "prod" ? 2 : 1
  max_size = var.environment == "prod" ? 10 : 3
  desired_capacity = var.environment == "prod" ? 3 : 1

  # Use mixed instances for cost optimization
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 50
      spot_allocation_strategy                 = "lowest-price"
    }

    override {
      instance_type     = "t3.medium"
      weighted_capacity = 1
    }
    override {
      instance_type     = "t3.small"
      weighted_capacity = 0.5
    }
  }

  # Scale based on CPU
  target_tracking_policy {
    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value       = 50.0
      disable_scale_in   = false
    }
  }
}
```

### Spot Instances

```hcl
# Use spot instances for stateless workloads
resource "aws_spot_instance_request" "worker" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.medium"
  spot_price    = "0.005"
  spot_type     = "persistent"

  # Use multiple instance types
  instance_interruption_behavior = "stop"

  tags = {
    Name = "spot-worker"
  }
}
```

### Reserved Instances

```bash
# Purchase reserved instances
aws ec2 purchase-reserved-instances-offering \
  --reserved-instances-offering-id <offering-id> \
  --instance-count 3 \
  --instance-type m5.large

# Analyze reserved instance recommendations
aws ce get-reservation-utilization
```

### Cost Savings Tips

- [ ] Use t3 instances for development
- [ ] Use spot instances for batch jobs
- [ ] Purchase reserved instances for steady workloads
- [ ] Enable auto-scaling for variable workloads
- [ ] Use scheduled scaling for predictable patterns
- [ ] Monitor instance utilization regularly
- [ ] Shut down non-production environments when not in use

---

## Storage Optimization

### S3 Storage Classes

```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-logs"

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 730
    }
  }
}
```

### EBS Volume Optimization

```hcl
resource "aws_ebs_volume" "data" {
  availability_zone = "us-west-2a"
  size              = 100
  type              = "gp3"  # Cost-effective general purpose SSD

  # Enable volume encryption
  encrypted = true

  tags = {
    Name = "data-volume"
  }
}
```

### EFS Optimization

```hcl
resource "aws_efs_file_system" "shared" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_DAYS"
  }
}
```

### Storage Lifecycle Policies

```bash
# Set up lifecycle policies
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-bucket \
  --lifecycle-configuration file://lifecycle.json

# Monitor storage costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --metric "BlendedCost" \
  --granularity MONTHLY \
  --group-by Type=DIMENSION,Key=SERVICE
```

### Storage Savings Tips

- [ ] Use S3 lifecycle policies
- [ ] Use appropriate storage classes
- [ ] Enable S3 versioning selectively
- [ ] Use gp3 instead of gp2 for EBS
- [ ] Delete unused snapshots
- [ ] Use EFS lifecycle policies
- [ ] Compress data before storage
- [ ] Use data compression for logs

---

## Network Optimization

### VPC Design

```hcl
# Use single NAT gateway for cost savings
resource "aws_nat_gateway" "main" {
  count = var.single_nat_gateway ? 1 : 3

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "main-nat-gateway"
  }
}
```

### Data Transfer Optimization

```hcl
# Use VPC endpoints to reduce data transfer costs
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = {
    Name = "s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"

  tags = {
    Name = "dynamodb-endpoint"
  }
}
```

### CloudFront CDN

```hcl
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  price_class         = "PriceClass_100"  # Use cheapest regions

  # Cache behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.website.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
}
```

### Network Savings Tips

- [ ] Use VPC endpoints for AWS services
- [ ] Enable CloudFront for static content
- [ ] Use appropriate price classes
- [ ] Optimize data transfer patterns
- [ ] Use private subnets where possible
- [ ] Monitor data transfer costs
- [ ] Use S3 Transfer Acceleration selectively

---

## Database Optimization

### RDS Instance Sizing

```hcl
resource "aws_db_instance" "main" {
  instance_class = var.environment == "prod" ? "db.t3.medium" : "db.t3.micro"

  # Enable multi-AZ for production
  multi_az = var.environment == "prod"

  # Use reserved instances for production
  # Purchase reserved instances separately

  # Enable storage autoscaling
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"

  # Enable backup retention
  backup_retention_period = var.environment == "prod" ? 7 : 1
}
```

### Aurora Serverless

```hcl
resource "aws_rds_cluster" "aurora" {
  engine                = "aurora-mysql"
  engine_version        = "5.7.mysql_aurora.2.10.1"
  database_name         = "mydb"
  master_username       = "admin"
  master_password       = var.db_password

  # Enable serverless for cost optimization
  enable_http_endpoint = true

  # Scaling configuration
  scaling_configuration {
    auto_pause               = true
    max_capacity             = 4
    min_capacity             = 1
    seconds_until_auto_pause = 300
  }
}
```

### ElastiCache

```hcl
resource "aws_elasticache_cluster" "redis" {
  cluster_id      = "redis-cluster"
  engine          = "redis"
  node_type       = "cache.t3.micro"
  num_cache_nodes = 1
  engine_version  = "6.x"

  # Use reserved instances for production
  # Enable automatic failover for production
  automatic_failover_enabled = var.environment == "prod"
}
```

### Database Savings Tips

- [ ] Use appropriate instance sizes
- [ ] Use Aurora Serverless for variable workloads
- [ ] Enable read replicas for scaling
- [ ] Use reserved instances for production
- [ ] Optimize query performance
- [ ] Archive old data
- [ ] Use appropriate backup retention

---

## Container Optimization

### Kubernetes Resource Limits

```yaml
apiVersion: v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: app
        image: my-app:latest
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
```

### Horizontal Pod Autoscaler

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
```

### Node Auto-Scaling

```hcl
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 1
  }

  # Use spot instances
  instance_types = ["t3.medium", "t3.small"]
  capacity_type  = "SPOT"
}
```

### Container Savings Tips

- [ ] Set appropriate resource requests/limits
- [ ] Enable HPA for scaling
- [ ] Use spot instances for node groups
- [ ] Right-size node instances
- [ ] Use node auto-scaling
- [ ] Optimize image sizes
- [ ] Remove unused containers

---

## Monitoring Costs

### CloudWatch Costs

```bash
# Set up CloudWatch alarms for cost monitoring
aws cloudwatch put-metric-alarm \
  --alarm-name high-cost-alarm \
  --alarm-description "Alert when costs exceed threshold" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 21600 \
  --evaluation-periods 1 \
  --threshold 100 \
  --comparison-operator GreaterThanThreshold
```

### Cost Anomaly Detection

```bash
# Enable cost anomaly detection
aws ce enable-cost-anomaly-monitor \
  --monitor-arn <monitor-arn>

aws ce create-anomaly-subscription \
  --monitor-arn <monitor-arn> \
  --threshold 100 \
  --frequency DAILY \
  --subscriber email:alerts@company.com
```

### Budget Alerts

```bash
# Create cost budget
aws budgets create-budget \
  --account-id <account-id> \
  --budget file://budget.json

# budget.json example
{
  "BudgetLimit": {
    "Amount": "100",
    "Unit": "USD"
  },
  "TimePeriod": {
    "Start": "2024-01-01",
    "End": "2024-12-31"
  },
  "BudgetType": "COST"
}
```

### Cost Monitoring Commands

```bash
# Get cost and usage
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --metric "BlendedCost" \
  --granularity MONTHLY

# Get cost forecast
aws ce get-cost-forecast \
  --time-period Start=2024-02-01,End=2024-03-01 \
  --metric "BlendedCost" \
  --granularity MONTHLY

# Get cost categories
aws ce describe-cost-categories
```

---

## Cost Management Tools

### AWS Cost Explorer

```bash
# Access Cost Explorer console
# https://console.aws.amazon.com/cost-management/home

# Use Cost Explorer API
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --metric "BlendedCost" \
  --granularity DAILY \
  --group-by Type=DIMENSION,Key=SERVICE
```

### AWS Budgets

```bash
# Create budget
aws budgets create-budget \
  --account-id <account-id> \
  --budget file://budget.json

# List budgets
aws budgets describe-budgets \
  --account-id <account-id>
```

### Trusted Advisor

```bash
# Check cost optimization recommendations
aws support describe-trusted-advisor-checks \
  --language en

# Get cost optimization checks
aws support describe-trusted-advisor-check-result \
  --check-id <check-id> \
  --language en
```

### Third-Party Tools

- **CloudHealth**: Cloud cost management
- **Cloudability**: Cloud cost optimization
- **Spot.io**: Automated cloud cost savings
- **ParkMyCloud**: Automated cloud resource scheduling
- **Infracost**: Cost estimation for Terraform

---

## Cost Optimization Checklist

### Daily
- [ ] Review CloudWatch cost metrics
- [ ] Check for unusual cost spikes
- [ ] Review cost anomaly alerts

### Weekly
- [ ] Review cost and usage reports
- [ ] Check resource utilization
- [ ] Identify unused resources
- [ ] Review auto-scaling metrics

### Monthly
- [ ] Review monthly cost report
- [ ] Analyze cost trends
- [ ] Update cost budgets
- [ ] Review reserved instances
- [ ] Check spot instance savings

### Quarterly
- [ ] Comprehensive cost analysis
- [ ] Review and update cost strategy
- [ ] Evaluate new cost-saving opportunities
- [ ] Review and optimize storage
- [ ] Audit all resources

---

## Best Practices

1. **Monitor Continuously**
   - Set up cost alerts
   - Review costs regularly
   - Track cost trends

2. **Right-Size Resources**
   - Use appropriate instance types
   - Set resource limits
   - Monitor utilization

3. **Use Auto-Scaling**
   - Scale based on demand
   - Use spot instances
   - Configure scaling policies

4. **Optimize Storage**
   - Use lifecycle policies
   - Choose appropriate storage classes
   - Archive old data

5. **Leverage Discounts**
   - Purchase reserved instances
   - Use spot instances
   - Use savings plans

6. **Eliminate Waste**
   - Remove unused resources
   - Clean up old snapshots
   - Delete unused volumes

7. **Automate Cost Management**
   - Automate resource scheduling
   - Use cost optimization tools
   - Implement cost policies

---

For more information, see:
- [Architecture Overview](architecture.md)
- [Monitoring Setup](monitoring.md)
- [Security Best Practices](security.md)
