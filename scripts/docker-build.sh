#!/bin/bash

# Docker Multi-Stage Build Script
# Supports both development and production builds with optimization

set -e

# Configuration
BACKEND_DIR="backend"
IMAGE_NAME="university-qa"
REGISTRY=""  # Set this if using a container registry

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to build development image
build_dev() {
    log_info "Building development image..."
    
    cd $BACKEND_DIR
    
    # Build with cache optimization
    docker build \
        --file Dockerfile.dev \
        --target development \
        --tag ${IMAGE_NAME}:dev \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        .
    
    cd ..
    log_success "Development image built successfully: ${IMAGE_NAME}:dev"
}

# Function to build production image
build_prod() {
    log_info "Building production image..."
    
    cd $BACKEND_DIR
    
    # Use production-specific dockerignore if it exists
    if [ -f ".dockerignore.prod" ]; then
        cp .dockerignore.prod .dockerignore.backup
        mv .dockerignore.prod .dockerignore
    fi
    
    # Build multi-stage production image
    docker build \
        --file Dockerfile.prod \
        --tag ${IMAGE_NAME}:prod \
        --tag ${IMAGE_NAME}:latest \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        .
    
    # Restore original dockerignore
    if [ -f ".dockerignore.backup" ]; then
        mv .dockerignore.backup .dockerignore
    fi
    
    cd ..
    log_success "Production image built successfully: ${IMAGE_NAME}:prod"
}

# Function to analyze image sizes
analyze_images() {
    log_info "Analyzing image sizes..."
    
    echo "Image Size Comparison:"
    echo "====================="
    
    if docker image inspect ${IMAGE_NAME}:dev >/dev/null 2>&1; then
        DEV_SIZE=$(docker image inspect ${IMAGE_NAME}:dev --format='{{.Size}}' | numfmt --to=iec)
        echo "Development: $DEV_SIZE"
    fi
    
    if docker image inspect ${IMAGE_NAME}:prod >/dev/null 2>&1; then
        PROD_SIZE=$(docker image inspect ${IMAGE_NAME}:prod --format='{{.Size}}' | numfmt --to=iec)
        echo "Production:  $PROD_SIZE"
    fi
    
    # Show layer information
    log_info "Production image layers:"
    docker history ${IMAGE_NAME}:prod --format "table {{.CreatedBy}}\t{{.Size}}" | head -10
}

# Function to test images
test_images() {
    log_info "Testing built images..."
    
    # Test production image
    if docker image inspect ${IMAGE_NAME}:prod >/dev/null 2>&1; then
        log_info "Testing production image security..."
        
        # Check if running as non-root user
        USER_CHECK=$(docker run --rm ${IMAGE_NAME}:prod whoami)
        if [ "$USER_CHECK" = "appuser" ]; then
            log_success "Production image runs as non-root user: $USER_CHECK"
        else
            log_warning "Production image may be running as root: $USER_CHECK"
        fi
        
        # Check if health endpoint is accessible
        log_info "Starting temporary container to test health endpoint..."
        CONTAINER_ID=$(docker run -d -p 8080:8000 ${IMAGE_NAME}:prod)
        
        # Wait for container to start
        sleep 10
        
        # Test health endpoint
        if curl -f http://localhost:8080/health >/dev/null 2>&1; then
            log_success "Health endpoint is accessible"
        else
            log_warning "Health endpoint test failed"
        fi
        
        # Cleanup
        docker stop $CONTAINER_ID >/dev/null
        docker rm $CONTAINER_ID >/dev/null
    fi
}

# Function to clean up old images
cleanup() {
    log_info "Cleaning up old images..."
    
    # Remove dangling images
    docker image prune -f
    
    log_success "Cleanup completed"
}

# Function to push images to registry
push_images() {
    if [ -z "$REGISTRY" ]; then
        log_warning "No registry configured. Skipping push."
        return
    fi
    
    log_info "Pushing images to registry: $REGISTRY"
    
    # Tag and push production image
    docker tag ${IMAGE_NAME}:prod ${REGISTRY}/${IMAGE_NAME}:prod
    docker tag ${IMAGE_NAME}:prod ${REGISTRY}/${IMAGE_NAME}:latest
    
    docker push ${REGISTRY}/${IMAGE_NAME}:prod
    docker push ${REGISTRY}/${IMAGE_NAME}:latest
    
    log_success "Images pushed to registry"
}

# Main script logic
case "$1" in
    "dev")
        build_dev
        ;;
    "prod")
        build_prod
        analyze_images
        test_images
        ;;
    "both")
        build_dev
        build_prod
        analyze_images
        test_images
        ;;
    "analyze")
        analyze_images
        ;;
    "test")
        test_images
        ;;
    "cleanup")
        cleanup
        ;;
    "push")
        push_images
        ;;
    "all")
        build_dev
        build_prod
        analyze_images
        test_images
        cleanup
        ;;
    *)
        echo "Usage: $0 {dev|prod|both|analyze|test|cleanup|push|all}"
        echo ""
        echo "Commands:"
        echo "  dev      - Build development image only"
        echo "  prod     - Build production image with analysis and testing"
        echo "  both     - Build both development and production images"
        echo "  analyze  - Analyze existing image sizes and layers"
        echo "  test     - Test existing images for security and functionality"
        echo "  cleanup  - Remove dangling images"
        echo "  push     - Push images to configured registry"
        echo "  all      - Build, analyze, test, and cleanup"
        exit 1
        ;;
esac