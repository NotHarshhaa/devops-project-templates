# 🔒 Security Best Practices

This document outlines the security best practices implemented across all DevOps Project Templates and provides guidelines for maintaining a secure infrastructure.

## Table of Contents

- [Security Principles](#security-principles)
- [Container Security](#container-security)
- [Infrastructure Security](#infrastructure-security)
- [Kubernetes Security](#kubernetes-security)
- [Secret Management](#secret-management)
- [Network Security](#network-security)
- [Compliance & Auditing](#compliance--auditing)
- [Security Checklist](#security-checklist)

---

## Security Principles

### 1. **Defense in Depth**
- Multiple layers of security controls
- No single point of failure
- Redundant security measures

### 2. **Least Privilege**
- Minimum required permissions
- Role-based access control
- Regular permission audits

### 3. **Zero Trust**
- Verify every request
- Assume breach mentality
- Continuous authentication

### 4. **Encryption Everywhere**
- Data at rest encryption
- Data in transit encryption
- Key management

### 5. **Security by Design**
- Built-in security features
- Secure defaults
- Regular security updates

---

## Container Security

### Dockerfile Best Practices

```dockerfile
# Use specific base image versions
FROM node:18-alpine AS builder

# Run as non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup
USER appuser

# Minimal layers
RUN apk add --no-cache curl

# Security scanning
# Run: docker scan my-image:tag
```

### Container Security Checklist

- [ ] Use official base images
- [ ] Pin specific image versions
- [ ] Run containers as non-root user
- [ ] Scan images for vulnerabilities
- [ ] Use multi-stage builds
- [ ] Minimize attack surface
- [ ] Implement health checks
- [ ] Use read-only root filesystem
- [ ] Drop unnecessary capabilities
- [ ] Enable resource limits

### Image Scanning

```bash
# Scan with Docker
docker scan my-image:tag

# Scan with Trivy
trivy image my-image:tag

# Scan with Snyk
snyk container test my-image:tag
```

---

## Infrastructure Security

### Terraform Security

```hcl
# Enable encryption
resource "aws_ebs_volume" "example" {
  encrypted = true
  kms_key_id = aws_kms_key.example.arn
}

# Use security groups
resource "aws_security_group" "example" {
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# IAM roles with least privilege
resource "aws_iam_role_policy" "example" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "arn:aws:s3:::my-bucket/*"
      }
    ]
  })
}
```

### AWS Security Best Practices

- [ ] Enable MFA for root account
- [ ] Use IAM roles instead of access keys
- [ ] Enable CloudTrail for auditing
- [ ] Enable AWS Config for compliance
- [ ] Use VPC with private subnets
- [ ] Enable encryption at rest
- [ ] Use security groups
- [ ] Enable GuardDuty for threat detection
- [ ] Regular security assessments
- [ ] Enable S3 bucket policies

### Security Tools

```bash
# Terraform security scanning
terraform fmt -check
terraform validate
tfsec .
tflint --config .tflint.hcl

# AWS security assessment
aws guardduty list-detectors
aws config get-discovered-resource-counts
aws cloudtrail lookup-events
```

---

## Kubernetes Security

### Pod Security

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1001
    fsGroup: 1001
  containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

### RBAC Configuration

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

### Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### Kubernetes Security Checklist

- [ ] Enable RBAC
- [ ] Use network policies
- [ ] Run pods as non-root
- [ ] Use read-only root filesystem
- [ ] Drop all capabilities
- [ ] Enable Pod Security Policies
- [ ] Use service accounts
- [ ] Enable audit logging
- [ ] Regular image scanning
- [ ] Enable admission controllers

---

## Secret Management

### Best Practices

1. **Never commit secrets to version control**
2. **Use environment variables for configuration**
3. **Rotate secrets regularly**
4. **Use secret management tools**
5. **Encrypt secrets at rest**

### Kubernetes Secrets

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
stringData:
  # Use stringData for plain text values (Kubernetes auto-encodes)
  password: "REPLACE_WITH_ACTUAL_PASSWORD"
```

### AWS Secrets Manager

```bash
# Store secret
aws secretsmanager create-secret \
  --name my-app/password \
  --secret-string "my-secret-password"

# Retrieve secret
aws secretsmanager get-secret-value \
  --secret-id my-app/password
```

### Environment Variables

```bash
# Use .env files (never commit)
cp .env.example .env

# Load in production
export $(cat .env | xargs)
```

### Secret Rotation

```bash
# Rotate database password
1. Generate new password
2. Update application
3. Update database
4. Update secret manager
5. Verify access
6. Delete old password
```

---

## Network Security

### VPC Design

```
┌─────────────────────────────────────┐
│              VPC                    │
│  ┌──────────┐  ┌──────────┐        │
│  │ Public   │  │ Private  │        │
│  │ Subnet   │  │ Subnet   │        │
│  │ (DMZ)    │  │ (App)    │        │
│  └──────────┘  └──────────┘        │
│       │             │               │
│       ▼             ▼               │
│  ┌──────────┐  ┌──────────┐        │
│  │   ALB    │  │   EKS    │        │
│  └──────────┘  └──────────┘        │
└─────────────────────────────────────┘
```

### Security Groups

```hcl
resource "aws_security_group" "web" {
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### TLS/SSL Configuration

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - example.com
    secretName: example-tls
```

### Network Security Checklist

- [ ] Use VPC with private subnets
- [ ] Configure security groups
- [ ] Enable network ACLs
- [ ] Use TLS/SSL encryption
- [ ] Implement network policies
- [ ] Enable DDoS protection
- [ ] Use VPN for remote access
- [ ] Monitor network traffic
- [ ] Regular security updates
- [ ] Firewall rules review

---

## Compliance & Auditing

### CloudTrail Configuration

```hcl
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.logs.id
  include_global_service_events = true
  is_multi_region_trail         = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
```

### AWS Config

```hcl
resource "aws_config_configuration_recorder" "main" {
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported = true
  }
}
```

### Audit Logging

```bash
# View CloudTrail logs
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances

# View Config rules
aws config describe-compliance-by-config-rule
```

### Compliance Frameworks

- **SOC 2**: Security, availability, processing integrity
- **PCI DSS**: Payment card industry standards
- **HIPAA**: Healthcare information protection
- **GDPR**: Data protection and privacy

---

## Security Checklist

### Pre-Deployment

- [ ] All secrets removed from code
- [ ] Images scanned for vulnerabilities
- [ ] Security groups configured
- [ ] TLS/SSL certificates valid
- [ ] RBAC policies reviewed
- [ ] Network policies applied
- [ ] Monitoring enabled
- [ ] Backup procedures tested

### Post-Deployment

- [ ] Security monitoring enabled
- [ ] Alerting configured
- [ ] Regular vulnerability scans
- [ ] Access logs reviewed
- [ ] Compliance checks passed
- [ ] Incident response plan ready
- [ ] Security training completed
- [ ] Documentation updated

### Regular Maintenance

- [ ] Monthly security updates
- [ ] Quarterly penetration testing
- [ ] Annual security audit
- [ ] Regular secret rotation
- [ ] Access review
- [ ] Policy updates
- [ ] Training refresh
- [ ] Documentation review

---

## Incident Response

### Detection

1. Monitor security alerts
2. Review logs regularly
3. Analyze anomalies
4. Validate incidents

### Containment

1. Isolate affected systems
2. Block malicious IPs
3. Disable compromised accounts
4. Preserve evidence

### Eradication

1. Remove malware
2. Patch vulnerabilities
3. Update credentials
4. Clean systems

### Recovery

1. Restore from backups
2. Verify system integrity
3. Monitor for recurrence
4. Document lessons learned

---

## Resources

### Tools

- [Trivy](https://github.com/aquasecurity/trivy) - Container scanner
- [tfsec](https://github.com/aquasecurity/tfsec) - Terraform security scanner
- [Kube-bench](https://github.com/aquasecurity/kube-bench) - Kubernetes benchmark
- [Checkov](https://github.com/bridgecrewio/checkov) - Infrastructure security scanner

### Documentation

- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [AWS Security Best Practices](https://aws.amazon.com/security/)

---

For more information, see:
- [Architecture Overview](architecture.md)
- [Monitoring Setup](monitoring.md)
- [Troubleshooting Guide](troubleshooting.md)
