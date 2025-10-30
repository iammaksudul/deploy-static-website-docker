#!/bin/bash

# Deployment script for static website
# Author: Alam

set -e

PROJECT_NAME="devops-portfolio"
IMAGE_NAME="devops-portfolio"
CONTAINER_NAME="devops-portfolio"
PORT="8080"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        error "Docker is not running. Please start Docker and try again."
    fi
    log "Docker is running"
}

# Build Docker image
build_image() {
    log "Building Docker image: $IMAGE_NAME"
    
    if docker build -t "$IMAGE_NAME:latest" .; then
        log "Docker image built successfully"
    else
        error "Failed to build Docker image"
    fi
}

# Stop and remove existing container
cleanup_container() {
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        log "Stopping existing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME"
    fi
    
    if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
        log "Removing existing container: $CONTAINER_NAME"
        docker rm "$CONTAINER_NAME"
    fi
}

# Deploy container
deploy_container() {
    log "Deploying container: $CONTAINER_NAME"
    
    docker run -d \
        --name "$CONTAINER_NAME" \
        --restart unless-stopped \
        -p "$PORT:8080" \
        --health-cmd="curl -f http://localhost:8080/health || exit 1" \
        --health-interval=30s \
        --health-timeout=10s \
        --health-retries=3 \
        "$IMAGE_NAME:latest"
    
    log "Container deployed successfully"
}

# Wait for container to be healthy
wait_for_health() {
    log "Waiting for container to be healthy..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null | grep -q "healthy"; then
            log "Container is healthy!"
            return 0
        fi
        
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    error "Container failed to become healthy within timeout"
}

# Display deployment info
show_info() {
    echo ""
    log "=== Deployment Complete ==="
    log "Application URL: http://localhost:$PORT"
    log "Health Check: http://localhost:$PORT/health"
    log "Container Name: $CONTAINER_NAME"
    log "Image: $IMAGE_NAME:latest"
    echo ""
    log "Container Status:"
    docker ps -f name="$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    log "To view logs: docker logs $CONTAINER_NAME"
    log "To stop: docker stop $CONTAINER_NAME"
}

# Main deployment function
main() {
    log "Starting deployment of $PROJECT_NAME"
    
    check_docker
    build_image
    cleanup_container
    deploy_container
    wait_for_health
    show_info
    
    log "Deployment completed successfully!"
}

# Handle script arguments
case "${1:-deploy}" in
    "build")
        check_docker
        build_image
        ;;
    "deploy")
        main
        ;;
    "stop")
        log "Stopping $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" 2>/dev/null || warn "Container not running"
        ;;
    "logs")
        docker logs -f "$CONTAINER_NAME"
        ;;
    "clean")
        cleanup_container
        docker rmi "$IMAGE_NAME:latest" 2>/dev/null || warn "Image not found"
        log "Cleanup completed"
        ;;
    *)
        echo "Usage: $0 {build|deploy|stop|logs|clean}"
        echo "  build  - Build Docker image only"
        echo "  deploy - Full deployment (default)"
        echo "  stop   - Stop running container"
        echo "  logs   - Show container logs"
        echo "  clean  - Remove container and image"
        exit 1
        ;;
esac
