# 🐳 Docker-Only Template

A minimal, production-ready Docker template for containerizing web applications.

## 🎯 Purpose

This template helps you:
- Containerize a simple web application
- Learn Docker best practices
- Create multi-stage builds
- Optimize Docker images
- Practice container security

## 📁 Structure

```text
docker-only/
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── app/
│   ├── index.html
│   ├── style.css
│   └── script.js
└── README.md
```

## 🚀 Quick Start

1. **Build the image**
   ```bash
   docker build -t my-app:latest .
   ```

2. **Run the container**
   ```bash
   docker run -p 8080:80 my-app:latest
   ```

3. **Or use Docker Compose**
   ```bash
   docker-compose up -d
   ```

4. **Access the app**
   Open http://localhost:8080 in your browser

## 🛠️ Features

- ✅ Multi-stage Docker build
- ✅ Optimized image size
- ✅ Non-root user for security
- ✅ Health checks
- ✅ Environment variables
- ✅ Docker Compose support
- ✅ Development and production configs

## 📝 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | `production` | Application environment |
| `PORT` | `80` | Application port |
| `APP_VERSION` | `1.0.0` | Application version |

## 🔧 Customization

1. **Update the application code** in the `app/` directory
2. **Modify the Dockerfile** for your specific needs
3. **Update docker-compose.yml** for development environment
4. **Add health checks** and monitoring as needed

## 📚 Learn More

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker Security](https://docs.docker.com/engine/security/)

## 🚀 Next Steps

- Add CI/CD pipeline (see ci-cd-github-actions template)
- Deploy to Kubernetes (see kubernetes-app template)
- Add monitoring and logging
- Implement security scanning
