# Deploy Static Website with Docker

A production-ready static website deployment using Docker with multi-stage builds, security best practices, and automated deployment scripts.

## 🚀 Features

- **Multi-stage Docker Build**: Optimized image size and security
- **Nginx Web Server**: High-performance static file serving
- **Security Hardened**: Non-root user, security headers, minimal attack surface
- **Health Checks**: Built-in application health monitoring
- **Docker Compose**: Easy multi-container orchestration
- **Automated Deployment**: One-command deployment scripts
- **Production Ready**: Gzip compression, caching, and optimization

## 📁 Project Structure

```
├── src/                    # Website source files
│   ├── index.html         # Main HTML file
│   ├── styles.css         # CSS styles
│   └── script.js          # JavaScript functionality
├── nginx/                 # Nginx configuration
│   ├── nginx.conf         # Main nginx config
│   └── default.conf       # Server configuration
├── scripts/               # Deployment scripts
│   └── deploy.sh          # Automated deployment
├── Dockerfile             # Multi-stage Docker build
├── docker-compose.yml     # Container orchestration
└── README.md             # This file
```

## 🛠️ Quick Start

### Prerequisites
- Docker 20.0+
- Docker Compose 2.0+
- curl (for health checks)

### 1. Clone and Deploy
```bash
git clone https://github.com/iammaksudul/deploy-static-website-docker.git
cd deploy-static-website-docker

# One-command deployment
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 2. Access Application
- **Website**: http://localhost:8080
- **Health Check**: http://localhost:8080/health

## 🐳 Docker Commands

### Manual Docker Build
```bash
# Build image
docker build -t devops-portfolio .

# Run container
docker run -d \
  --name devops-portfolio \
  -p 8080:8080 \
  --restart unless-stopped \
  devops-portfolio
```

### Docker Compose
```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 🔧 Deployment Script Usage

The `deploy.sh` script provides multiple deployment options:

```bash
# Full deployment (default)
./scripts/deploy.sh

# Build image only
./scripts/deploy.sh build

# Stop container
./scripts/deploy.sh stop

# View logs
./scripts/deploy.sh logs

# Clean up (remove container and image)
./scripts/deploy.sh clean
```

## 🏗️ Multi-Stage Build Process

### Stage 1: Base
- Alpine Linux with Nginx
- Security updates
- Non-root user creation

### Stage 2: Builder
- Copy and optimize source files
- Minify CSS and JavaScript
- Prepare optimized assets

### Stage 3: Production
- Copy optimized files
- Configure Nginx
- Set security permissions
- Health check setup

## 🔒 Security Features

### Container Security
- **Non-root User**: Runs as nginx user (UID 1001)
- **Minimal Base Image**: Alpine Linux for reduced attack surface
- **Read-only Filesystem**: Immutable container filesystem
- **Security Updates**: Automated security patch installation

### Web Security
- **Security Headers**: XSS protection, content type options
- **Content Security Policy**: Prevents code injection
- **Hidden File Protection**: Denies access to sensitive files
- **Server Token Hiding**: Removes nginx version disclosure

### Network Security
- **Custom Port**: Runs on port 8080 (non-privileged)
- **Health Checks**: Automated container health monitoring
- **Isolated Networks**: Docker network isolation

## ⚡ Performance Optimizations

### Nginx Optimizations
- **Gzip Compression**: Reduces bandwidth usage
- **Static Asset Caching**: Browser caching for static files
- **Keep-Alive Connections**: Reduces connection overhead
- **Worker Process Tuning**: Optimized for container environment

### Docker Optimizations
- **Layer Caching**: Efficient Docker layer reuse
- **Multi-stage Build**: Minimal production image size
- **Asset Optimization**: Minified CSS and JavaScript

## 📊 Monitoring and Health Checks

### Built-in Health Check
```bash
# Docker health check
curl -f http://localhost:8080/health

# Container health status
docker inspect --format='{{.State.Health.Status}}' devops-portfolio
```

### Monitoring Endpoints
- `/health` - Application health status
- Nginx access logs: `/var/log/nginx/access.log`
- Nginx error logs: `/var/log/nginx/error.log`

## 🚀 Production Deployment

### Environment Variables
```bash
# Optional environment variables
NGINX_WORKER_PROCESSES=auto
NGINX_WORKER_CONNECTIONS=1024
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-portfolio
spec:
  replicas: 3
  selector:
    matchLabels:
      app: devops-portfolio
  template:
    metadata:
      labels:
        app: devops-portfolio
    spec:
      containers:
      - name: web
        image: devops-portfolio:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Docker Swarm Deployment
```yaml
version: '3.8'
services:
  web:
    image: devops-portfolio:latest
    ports:
      - "8080:8080"
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
      resources:
        limits:
          memory: 128M
        reservations:
          memory: 64M
```

## 🔧 Customization

### Modify Website Content
1. Edit files in `src/` directory
2. Rebuild and deploy:
```bash
./scripts/deploy.sh
```

### Custom Nginx Configuration
1. Modify `nginx/default.conf`
2. Rebuild container:
```bash
./scripts/deploy.sh build
./scripts/deploy.sh deploy
```

### Add SSL/TLS
```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /etc/ssl/certs/cert.pem;
    ssl_certificate_key /etc/ssl/private/key.pem;
    # ... rest of configuration
}
```

## 📈 Scaling and Load Balancing

### Horizontal Scaling
```bash
# Scale with Docker Compose
docker-compose up -d --scale web=3

# Scale with Docker Swarm
docker service scale portfolio_web=5
```

### Load Balancer Configuration
```nginx
upstream backend {
    server web1:8080;
    server web2:8080;
    server web3:8080;
}

server {
    location / {
        proxy_pass http://backend;
    }
}
```

## 🐛 Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check logs
docker logs devops-portfolio

# Check container status
docker ps -a
```

#### Health Check Failing
```bash
# Test health endpoint
curl -v http://localhost:8080/health

# Check nginx configuration
docker exec devops-portfolio nginx -t
```

#### Permission Issues
```bash
# Check file permissions
docker exec devops-portfolio ls -la /usr/share/nginx/html/
```

### Debug Mode
```bash
# Run container interactively
docker run -it --rm devops-portfolio sh

# Execute commands in running container
docker exec -it devops-portfolio sh
```

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Alam** - DevOps Engineer
- GitHub: [@iammaksudul](https://github.com/iammaksudul)
- Email: kh.maksudul.alam.cse@gmail.com

---

*This project demonstrates production-ready Docker deployment practices with security, performance, and scalability in mind.*
