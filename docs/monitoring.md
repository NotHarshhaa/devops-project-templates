# 📊 Monitoring Setup Guide

This document provides comprehensive guidance on setting up monitoring and observability for your DevOps infrastructure.

## Table of Contents

- [Monitoring Overview](#monitoring-overview)
- [Metrics Collection](#metrics-collection)
- [Logging](#logging)
- [Alerting](#alerting)
- [Dashboards](#dashboards)
- [Tracing](#tracing)
- [Monitoring Tools](#monitoring-tools)

---

## Monitoring Overview

### The Three Pillars of Observability

1. **Metrics** - Numerical data points over time
2. **Logs** - Discrete events with context
3. **Traces** - Distributed request paths

### Monitoring Strategy

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Metrics    │    │    Logs     │    │   Traces    │
│  Collection │    │ Collection  │    │ Collection  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                  │                  │
       ▼                  ▼                  ▼
┌─────────────────────────────────────────────────┐
│           Monitoring & Alerting System           │
│  ┌─────────┐  ┌─────────┐  ┌───────────────┐   │
│  │Prometheus│  │ Grafana │  │ AlertManager  │   │
│  └─────────┘  └─────────┘  └───────────────┘   │
└─────────────────────────────────────────────────┘
```

---

## Metrics Collection

### Application Metrics

```javascript
// Node.js example with Prometheus client
const promClient = require('prom-client');

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'code'],
  buckets: [0.1, 0.5, 1, 1.5, 2, 5]
});

app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  next();
});
```

### Kubernetes Metrics

```yaml
# Prometheus ServiceMonitor for Kubernetes
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
  - port: http
    path: /metrics
    interval: 15s
```

### AWS CloudWatch Metrics

```hcl
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

### Key Metrics to Monitor

**Application Metrics**
- Request rate
- Error rate
- Response time (P50, P95, P99)
- Active connections
- Queue length

**Infrastructure Metrics**
- CPU utilization
- Memory usage
- Disk I/O
- Network traffic
- Disk space

**Business Metrics**
- Transactions per second
- Revenue per minute
- Active users
- Conversion rate

---

## Logging

### Structured Logging

```javascript
// Winston logger configuration
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// Usage
logger.info('User login', {
  userId: '123',
  ip: '192.168.1.1',
  userAgent: 'Mozilla/5.0...'
});
```

### Kubernetes Logging

```yaml
# Fluentd DaemonSet for log collection
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch
        env:
        - name: FLUENT_ELASTICSEARCH_HOST
          value: "elasticsearch.logging"
        - name: FLUENT_ELASTICSEARCH_PORT
          value: "9200"
```

### CloudWatch Logs

```hcl
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/my-app"
  retention_in_days = 7

  tags = {
    Environment = var.environment
  }
}

resource "aws_lambda_function" "log_forwarder" {
  function_name = "log-forwarder"
  role         = aws_iam_role.lambda_role.arn
  handler      = "index.handler"
  runtime      = "nodejs18.x"

  environment {
    variables = {
      LOG_GROUP = aws_cloudwatch_log_group.app.name
    }
  }
}
```

### Log Levels

- **ERROR**: Error conditions that should be investigated
- **WARN**: Warning conditions that might need attention
- **INFO**: Informational messages about normal operation
- **DEBUG**: Detailed diagnostic information
- **TRACE**: Very detailed tracing information

### Log Retention

```bash
# Configure log retention
aws logs put-retention-policy \
  --log-group-name /ecs/my-app \
  --retention-in-days 30
```

---

## Alerting

### AlertManager Configuration

```yaml
# alertmanager.yml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'

  routes:
  - match:
      severity: critical
    receiver: 'pagerduty'
  - match:
      severity: warning
    receiver: 'slack'

receivers:
- name: 'default'
  email_configs:
  - to: 'alerts@company.com'

- name: 'slack'
  slack_configs:
  - api_url: 'https://hooks.slack.com/services/...'
    channel: '#alerts'

- name: 'pagerduty'
  pagerduty_configs:
  - service_key: 'YOUR_SERVICE_KEY'
```

### Prometheus Alert Rules

```yaml
# alerting_rules.yml
groups:
- name: application_alerts
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value }} errors/sec"

  - alert: HighLatency
    expr: histogram_quantile(0.95, http_request_duration_seconds) > 1
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "High latency detected"
      description: "P95 latency is {{ $value }}s"

  - alert: PodCrashLooping
    expr: rate(kube_pod_container_status_restarts_total[1h]) > 0
    for: 15m
    labels:
      severity: critical
    annotations:
      summary: "Pod is crash looping"
      description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is crash looping"
```

### AWS CloudWatch Alarms

```hcl
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "MyApp"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
  name = "application-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "alerts@company.com"
}
```

### Alert Severity Levels

- **Critical**: Immediate action required
- **Warning**: Attention needed soon
- **Info**: Informational only
- **Debug**: For troubleshooting

---

## Dashboards

### Grafana Dashboard Example

```json
{
  "dashboard": {
    "title": "Application Overview",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{status=~'5..'}[5m])"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Response Time",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, http_request_duration_seconds)"
          }
        ],
        "type": "graph"
      }
    ]
  }
}
```

### CloudWatch Dashboard

```hcl
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "main-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "my-app"]
          ]
          period = 300
          stat   = "Average"
          region = "us-west-2"
          title  = "ECS CPU Utilization"
        }
      }
    ]
  })
}
```

### Key Dashboard Metrics

**Overview Dashboard**
- Request rate
- Error rate
- Response time
- Active users
- System health

**Infrastructure Dashboard**
- CPU utilization
- Memory usage
- Disk I/O
- Network traffic
- Container status

**Application Dashboard**
- Business metrics
- Transaction volume
- Revenue tracking
- User engagement
- Conversion rates

---

## Tracing

### Distributed Tracing with Jaeger

```yaml
# Jaeger deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:latest
        ports:
        - containerPort: 16686
        - containerPort: 14268
        env:
        - name: COLLECTOR_ZIPKIN_HOST_PORT
          value: ":9411"
```

### AWS X-Ray Tracing

```javascript
// Node.js X-Ray integration
const AWSXRay = require('aws-xray-sdk-core');
const express = require('express');

const app = express();
AWSXRay.captureHTTPsGlobal(require('http'));
AWSXRay.captureExpress(app);

app.get('/', (req, res) => {
  res.send('Hello World');
});
```

### OpenTelemetry Setup

```javascript
const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');
const { BatchSpanProcessor } = require('@opentelemetry/sdk-trace-base');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');

const provider = new NodeTracerProvider({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'my-app',
  }),
});

const exporter = new JaegerExporter({
  endpoint: 'http://jaeger:14268/api/traces',
});

provider.addSpanProcessor(new BatchSpanProcessor(exporter));
provider.register();
```

---

## Monitoring Tools

### Prometheus

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
    - role: pod
    relabel_configs:
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
      action: keep
      regex: true
```

### Grafana

```bash
# Install Grafana Helm chart
helm install grafana stable/grafana \
  --set persistence.enabled=true \
  --set persistence.size=10Gi \
  --set adminPassword=admin
```

### ELK Stack

```yaml
# Elasticsearch configuration
elasticsearch:
  replicas: 3
  volumeClaimTemplate:
    accessModes: [ "ReadWriteOnce" ]
    storageClassName: "gp2"
    resources:
      requests:
        storage: 100Gi

kibana:
  replicas: 1

logstash:
  replicas: 2
```

### CloudWatch

```bash
# Install CloudWatch agent
aws s3 cp s3://amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip .
unzip AmazonCloudWatchAgent.zip
sudo ./install.sh

# Configure agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

---

## Best Practices

### General Monitoring

- [ ] Monitor all critical services
- [ ] Set up alerting for important metrics
- [ ] Create dashboards for visibility
- [ ] Regularly review and tune alerts
- [ ] Document monitoring procedures
- [ ] Test alerting regularly
- [ ] Keep retention policies appropriate
- [ ] Monitor the monitoring system itself

### Metrics Best Practices

- [ ] Use meaningful metric names
- [ ] Include relevant labels
- [ ] Keep cardinality low
- [ ] Use appropriate data types
- [ ] Set up aggregation rules
- [ ] Monitor metric collection
- [ ] Document metric definitions

### Logging Best Practices

- [ ] Use structured logging
- [ ] Include correlation IDs
- [ ] Log at appropriate levels
- [ ] Avoid logging sensitive data
- [ ] Centralize log collection
- [ ] Set up log retention
- [ ] Monitor log volume

### Alerting Best Practices

- [ ] Alert on symptoms, not causes
- [ ] Set appropriate thresholds
- [ ] Include actionable information
- [ ] Avoid alert fatigue
- [ ] Route alerts to right teams
- [ ] Document runbooks
- [ ] Review alerts regularly

---

## Troubleshooting

### Common Issues

**High Memory Usage**
```bash
# Check container memory
kubectl top pods
kubectl describe pod <pod-name>

# Check memory leaks
docker stats
```

**Slow Response Times**
```bash
# Check latency metrics
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8080

# Check database queries
# Enable slow query log
```

**Missing Metrics**
```bash
# Check Prometheus targets
curl http://prometheus:9090/api/v1/targets

# Check metric endpoint
curl http://app:8080/metrics
```

---

For more information, see:
- [Architecture Overview](architecture.md)
- [Security Best Practices](security.md)
- [Troubleshooting Guide](troubleshooting.md)
