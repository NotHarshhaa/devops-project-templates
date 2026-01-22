# ☸️ Kubernetes Application Template

A production-ready Kubernetes deployment template with manifests, Helm charts, and best practices.

## 🎯 Purpose

This template helps you:
- Deploy applications to Kubernetes
- Implement Kubernetes best practices
- Set up monitoring and logging
- Practice GitOps workflows
- Learn Kubernetes concepts

## 📁 Structure

```text
kubernetes-app/
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   └── serviceaccount.yaml
├── helm-chart/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-prod.yaml
│   ├── values-staging.yaml
│   └── templates/
├── monitoring/
│   ├── servicemonitor.yaml
│   ├── prometheusrule.yaml
│   └── dashboard.json
├── scripts/
│   ├── deploy.sh
│   ├── rollback.sh
│   └── cleanup.sh
├── Dockerfile
├── app/
└── README.md
```

## 🚀 Quick Start

### 1. Prerequisites
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install Helm
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar xz
sudo mv linux-amd64/helm /usr/local/bin/

# Verify cluster access
kubectl cluster-info
```

### 2. Deploy with Manifests
```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy application
kubectl apply -f k8s/

# Check deployment
kubectl get pods -n my-app
```

### 3. Deploy with Helm
```bash
# Install Helm chart
helm install my-app ./helm-chart --namespace my-app --create-namespace

# Upgrade deployment
helm upgrade my-app ./helm-chart --namespace my-app

# Uninstall
helm uninstall my-app --namespace my-app
```

## 📋 Kubernetes Resources

### Core Resources
- **Namespace**: Isolates application resources
- **Deployment**: Manages pod replicas and updates
- **Service**: Exposes application internally
- **Ingress**: External access with TLS termination
- **ConfigMap**: Configuration data
- **Secret**: Sensitive data (base64 encoded)

### Advanced Resources
- **HPA**: Horizontal Pod Autoscaling
- **ServiceAccount**: Pod identity and permissions
- **NetworkPolicy**: Traffic rules
- **ResourceQuota**: Resource limits
- **PodSecurityPolicy**: Security constraints

## 🛠️ Configuration

### Environment Variables
```yaml
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-app-config
data:
  NODE_ENV: "production"
  API_URL: "https://api.myapp.com"
  LOG_LEVEL: "info"
```

### Secrets Management
```yaml
# Secret
apiVersion: v1
kind: Secret
metadata:
  name: my-app-secrets
type: Opaque
data:
  DATABASE_URL: <base64-encoded>
  API_KEY: <base64-encoded>
```

### Resource Limits
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## 📊 Monitoring & Observability

### Prometheus Metrics
```yaml
# ServiceMonitor
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app-monitor
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: metrics
    interval: 30s
```

### Health Checks
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Logging
- Structured JSON logging
- Log aggregation with Fluentd
- Centralized logging with ELK stack
- Log rotation and retention

## 🔒 Security Best Practices

### Pod Security
- Non-root containers
- Read-only filesystem
- Security contexts
- Network policies

### RBAC
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: my-app
  name: my-app-role
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "watch"]
```

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-app-netpol
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
  - Ingress
  - Egress
```

## 🔄 Deployment Strategies

### Rolling Update
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 25%
    maxSurge: 25%
```

### Blue-Green Deployment
```bash
# Deploy to green environment
kubectl apply -f k8s/green-deployment.yaml

# Switch traffic
kubectl patch service my-app -p '{"spec":{"selector":{"version":"green"}}}'
```

### Canary Deployment
```bash
# Deploy canary with 10% traffic
kubectl apply -f k8s/canary-deployment.yaml
```

## 📈 Scaling

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
        averageUtilization: 70
```

### Vertical Pod Autoscaler
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  updatePolicy:
    updateMode: "Auto"
```

## 🌐 Ingress Configuration

### Basic Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - myapp.com
    secretName: my-app-tls
  rules:
  - host: myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

## 📝 Environment-Specific Configs

### Staging
```yaml
# values-staging.yaml
replicaCount: 1
image:
  tag: staging
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
```

### Production
```yaml
# values-prod.yaml
replicaCount: 3
image:
  tag: latest
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

## 🧪 Testing

### Unit Tests
```bash
# Test manifests
kubectl apply --dry-run=client -f k8s/

# Validate Helm chart
helm lint ./helm-chart
```

### Integration Tests
```bash
# Deploy to test namespace
kubectl apply -f k8s/ -n test

# Run tests
kubectl run test-pod --image=curlimages/curl --rm -i --restart=Never -- curl http://my-app-service/health
```

## 🔧 Troubleshooting

### Common Issues
1. **Pod CrashLoopBackOff**: Check logs and resource limits
2. **ImagePullBackOff**: Verify image name and registry access
3. **Pending Pods**: Check resource quotas and node availability
4. **Service Not Accessible**: Verify service selectors and network policies

### Debug Commands
```bash
# Check pod status
kubectl get pods -n my-app -o wide

# View pod logs
kubectl logs -f deployment/my-app -n my-app

# Describe resources
kubectl describe pod <pod-name> -n my-app

# Port forward for debugging
kubectl port-forward svc/my-app-service 8080:80 -n my-app

# Exec into pod
kubectl exec -it <pod-name> -n my-app -- /bin/sh
```

## 🚀 Advanced Features

### Custom Resource Definitions (CRDs)
- Application CRDs for complex deployments
- Operator patterns for automation
- Custom controllers

### Service Mesh
- Istio integration
- Traffic management
- Security policies

### GitOps
- ArgoCD integration
- Flux CD workflows
- Automated synchronization

## 📚 Learn More

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Monitoring with Prometheus](https://prometheus.io/docs/)

## 🔄 Next Steps

- Add monitoring dashboards
- Implement backup strategies
- Set up disaster recovery
- Add compliance scanning
- Create operator patterns
