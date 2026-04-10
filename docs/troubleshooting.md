# 🔧 Troubleshooting Guide

This comprehensive troubleshooting guide helps you diagnose and resolve common issues across all DevOps Project Templates.

## Table of Contents

- [General Troubleshooting Approach](#general-troubleshooting-approach)
- [Docker Issues](#docker-issues)
- [Kubernetes Issues](#kubernetes-issues)
- [Terraform Issues](#terraform-issues)
- [CI/CD Issues](#cicd-issues)
- [Networking Issues](#networking-issues)
- [Performance Issues](#performance-issues)
- [Security Issues](#security-issues)

---

## General Troubleshooting Approach

### Troubleshooting Methodology

1. **Define the Problem**
   - What is not working?
   - When did it start?
   - What changed recently?

2. **Gather Information**
   - Check logs
   - Review metrics
   - Examine configurations

3. **Isolate the Issue**
   - Narrow down the scope
   - Test individual components
   - Identify the root cause

4. **Implement Fix**
   - Apply the solution
   - Test thoroughly
   - Document changes

5. **Prevent Recurrence**
   - Update documentation
   - Add monitoring
   - Improve processes

### Diagnostic Commands

```bash
# System health
top
htop
df -h
free -m

# Network connectivity
ping
traceroute
nslookup
curl -v

# Process management
ps aux
systemctl status
journalctl -u service-name
```

---

## Docker Issues

### Container Won't Start

**Problem**: Container exits immediately after starting

```bash
# Check container logs
docker logs <container-id>

# Check container status
docker ps -a

# Run in interactive mode to see errors
docker run -it <image-name> /bin/sh

# Check entrypoint issues
docker inspect <image-name> | grep -A 10 "Entrypoint"
```

**Solution**:
- Fix entrypoint script errors
- Ensure all dependencies are installed
- Check file permissions
- Verify environment variables

### Docker Build Fails

**Problem**: Docker build fails with errors

```bash
# Build with no cache
docker build --no-cache -t myapp .

# Build with verbose output
docker build --progress=plain -t myapp .

# Check Dockerfile syntax
docker build --check -f Dockerfile .
```

**Common Issues**:
- Invalid Dockerfile syntax
- Missing dependencies
- Network issues during package download
- Insufficient disk space

### Docker Image Too Large

**Problem**: Docker image size is too large

```bash
# Check image size
docker images

# Analyze image layers
docker history <image-name>

# Use dive to analyze
dive <image-name>
```

**Solutions**:
- Use multi-stage builds
- Use alpine-based images
- Clean up package manager cache
- Combine RUN commands
- Use .dockerignore

### Volume Mount Issues

**Problem**: Volume mounts not working

```bash
# Check volume mounts
docker inspect <container-id> | grep -A 10 "Mounts"

# Test volume mount
docker run -v $(pwd):/app -it <image-name> ls /app

# Check permissions
ls -la /path/to/volume
```

**Solutions**:
- Check file paths
- Verify permissions
- Use absolute paths
- Check SELinux/AppArmor

### Resource Limits

**Problem**: Container runs out of memory or CPU

```bash
# Check container stats
docker stats

# Set resource limits
docker run -m 512m --cpus="1.5" <image-name>

# Check system resources
free -h
lscpu
```

---

## Kubernetes Issues

### Pod Stuck in Pending State

**Problem**: Pod remains in Pending state

```bash
# Check pod status
kubectl get pod <pod-name> -o wide

# Describe pod for events
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# Check resource availability
kubectl describe nodes
kubectl top nodes
```

**Common Causes**:
- Insufficient resources
- Node selector/affinity issues
- Taints and tolerations
- Persistent volume issues

### Pod CrashLoopBackOff

**Problem**: Pod keeps restarting

```bash
# Check pod logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous

# Check pod status
kubectl describe pod <pod-name>

# Check resource limits
kubectl describe pod <pod-name> | grep -A 5 "Limits"

# Exec into container (if running)
kubectl exec -it <pod-name> -- /bin/sh
```

**Common Causes**:
- Application errors
- Missing environment variables
- Incorrect startup commands
- Health check failures
- Resource constraints

### Service Not Accessible

**Problem**: Cannot access service

```bash
# Check service status
kubectl get svc <service-name>

# Describe service
kubectl describe svc <service-name>

# Check endpoints
kubectl get endpoints <service-name>

# Test service from cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -O- <service-name>

# Check network policies
kubectl get networkpolicies
```

**Common Causes**:
- Incorrect selector
- Wrong port configuration
- Network policies blocking
- DNS issues
- Service type misconfiguration

### Image Pull Errors

**Problem**: Cannot pull container image

```bash
# Check image pull policy
kubectl describe pod <pod-name> | grep Image

# Check image pull secrets
kubectl get secrets
kubectl describe secret <secret-name>

# Test image pull manually
docker pull <image-name>

# Check registry connectivity
curl -v https://registry-1.docker.io/v2/
```

**Solutions**:
- Check image name and tag
- Verify image pull secrets
- Check registry access
- Use correct image pull policy
- Check network connectivity

### ConfigMap/Secret Issues

**Problem**: ConfigMaps or Secrets not mounted

```bash
# Check ConfigMap
kubectl get configmap <configmap-name>
kubectl describe configmap <configmap-name>

# Check Secret
kubectl get secret <secret-name>
kubectl describe secret <secret-name>

# Verify mount in pod
kubectl describe pod <pod-name> | grep -A 10 "Mounts"

# Check if mounted correctly
kubectl exec -it <pod-name> -- ls /path/to/mount
```

---

## Terraform Issues

### State Lock Errors

**Problem**: Terraform state is locked

```bash
# Check state lock
terraform force-unlock LOCK_ID

# List state locks
aws dynamodb scan --table-name terraform-locks

# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

**Prevention**:
- Use remote state with locking
- Set appropriate timeout
- Implement proper workflow
- Use state locking in CI/CD

### Provider Configuration Errors

**Problem**: Provider not configured correctly

```bash
# Re-initialize
terraform init -upgrade

# Check provider versions
terraform providers

# Check provider configuration
terraform init -backend=false
terraform validate

# Debug provider
TF_LOG=DEBUG terraform plan
```

### Resource Already Exists

**Problem**: Terraform thinks resource doesn't exist but it does

```bash
# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Refresh state
terraform refresh

# Check state
terraform show
```

### Drift Detection

**Problem**: Infrastructure has drifted from Terraform state

```bash
# Plan to detect drift
terraform plan

# Refresh state
terraform refresh

# Import drifted resources
terraform import <resource_type>.<resource_name> <resource_id>
```

### Dependency Issues

**Problem**: Module dependencies not resolving

```bash
# Clean module cache
rm -rf .terraform/modules/

# Re-initialize
terraform init -upgrade

# Check module versions
terraform providers

# Use specific module versions
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
}
```

---

## CI/CD Issues

### Pipeline Fails

**Problem**: GitHub Actions pipeline fails

```bash
# Check workflow logs
# Go to Actions tab in GitHub
# Click on failed workflow
# Review logs for errors

# Test locally
# Replicate the steps locally
# Check environment variables
# Verify secrets
```

**Common Issues**:
- Missing secrets
- Incorrect permissions
- Timeout errors
- Resource limits
- Dependency conflicts

### Docker Build Fails in CI

**Problem**: Docker build succeeds locally but fails in CI

```bash
# Check CI environment
# Verify Docker version
# Check available resources
# Review build context

# Use buildx for better compatibility
docker buildx build --platform linux/amd64 -t myapp .
```

### Test Failures

**Problem**: Tests fail in CI but pass locally

```bash
# Check test environment
# Verify dependencies
# Check environment variables
# Review test configuration

# Run tests locally with CI environment
docker-compose -f docker-compose.ci.yml up
```

### Deployment Failures

**Problem**: Deployment step fails

```bash
# Check deployment logs
# Verify credentials
# Check target environment
# Review deployment configuration

# Test deployment manually
# Use dry-run mode
# Validate configuration
```

---

## Networking Issues

### DNS Resolution

**Problem**: Cannot resolve hostnames

```bash
# Check DNS resolution
nslookup hostname
dig hostname

# Check /etc/resolv.conf
cat /etc/resolv.conf

# Test DNS server
nslookup hostname 8.8.8.8

# Check Kubernetes DNS
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default
```

### Connectivity Issues

**Problem**: Cannot connect to service

```bash
# Test connectivity
telnet hostname port
nc -zv hostname port
curl -v http://hostname:port

# Check firewall rules
sudo iptables -L -n
sudo ufw status

# Check security groups
aws ec2 describe-security-groups
```

### SSL/TLS Issues

**Problem**: Certificate errors

```bash
# Check certificate
openssl s_client -connect hostname:443
openssl x509 -in certificate.crt -text -noout

# Check certificate chain
openssl s_client -connect hostname:443 -showcerts

# Test with curl
curl -v https://hostname
```

---

## Performance Issues

### High CPU Usage

**Problem**: System or application using too much CPU

```bash
# Check CPU usage
top
htop

# Check per-process CPU
ps aux --sort=-%cpu | head

# Profile application
# Use profiling tools
# Check for infinite loops
# Review algorithm complexity
```

### High Memory Usage

**Problem**: System or application using too much memory

```bash
# Check memory usage
free -m
top

# Check per-process memory
ps aux --sort=-%mem | head

# Check for memory leaks
# Use memory profiling tools
# Review code for leaks
# Check garbage collection
```

### Slow Response Times

**Problem**: Application responding slowly

```bash
# Check response time
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8080

# Check database queries
# Enable slow query log
# Analyze query performance
# Add indexes

# Check network latency
ping hostname
traceroute hostname
```

### Disk I/O Issues

**Problem**: Slow disk performance

```bash
# Check disk usage
df -h
du -sh /path/to/directory

# Check disk I/O
iostat -x 1
iotop

# Check disk health
smartctl -a /dev/sda
```

---

## Security Issues

### Unauthorized Access

**Problem**: Security breach or unauthorized access

```bash
# Check access logs
# Review authentication logs
# Check for suspicious activity

# Audit permissions
# Review IAM roles
# Check security groups
# Review RBAC policies
```

### Vulnerability Scanning

**Problem**: Security vulnerabilities found

```bash
# Scan Docker images
docker scan <image-name>
trivy image <image-name>

# Scan Terraform
tfsec .
checkov -d .

# Scan Kubernetes
kube-bench
kube-hunter
```

### Secret Exposure

**Problem**: Secrets exposed in logs or code

```bash
# Scan for secrets
git-secrets scan
trufflehog git https://github.com/repo

# Rotate exposed secrets
# Update configurations
# Invalidate old credentials
```

---

## Getting Help

### Log Collection

```bash
# Collect system logs
journalctl > system.log

# Collect application logs
tail -f /var/log/app.log > app.log

# Collect Kubernetes logs
kubectl logs <pod-name> > pod.log
kubectl logs <deployment-name> -n <namespace> --tail=1000 > deployment.log

# Collect Docker logs
docker logs <container-id> > container.log
```

### Debug Mode

```bash
# Enable debug logging
export DEBUG=*
export TF_LOG=DEBUG
export NODE_ENV=development

# Run with verbose output
terraform plan -debug
kubectl describe pod <pod-name>
docker build --progress=plain
```

### Community Resources

- [GitHub Issues](https://github.com/NotHarshhaa/devops-project-templates/issues)
- [GitHub Discussions](https://github.com/NotHarshhaa/devops-project-templates/discussions)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)

---

## Prevention

### Best Practices

- [ ] Implement comprehensive monitoring
- [ ] Set up alerting for critical metrics
- [ ] Regular security scans
- [ ] Automated testing
- [ ] Documentation
- [ ] Code reviews
- [ ] Incident response plan
- [ ] Regular backups

### Health Checks

```bash
# Application health check
curl http://localhost:8080/health

# Database health check
# Connect to database
# Run simple query

# Service health check
# Check service endpoints
# Verify dependencies
```

---

For more information, see:
- [Architecture Overview](architecture.md)
- [Security Best Practices](security.md)
- [Monitoring Setup](monitoring.md)
