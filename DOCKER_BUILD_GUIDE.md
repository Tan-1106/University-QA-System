# Multi-Stage Docker Build System Guide

This guide explains how to use the optimized multi-stage Docker build system for the University QA System.

## Overview

The system provides two optimized Docker configurations:

1. **Production Build** (`Dockerfile.prod`) - Optimized for security, performance, and minimal size
2. **Development Build** (`Dockerfile.dev`) - Optimized for fast rebuilds and debugging

## Key Features

### Production Build Features
- **Multi-stage build** with separate builder and runtime stages
- **Minimal base image** using Python 3.12-slim
- **Non-root user** execution for security
- **Security hardening** with proper permissions and constraints
- **Health checks** with appropriate intervals
- **Resource optimization** with minimal runtime dependencies

### Development Build Features
- **Hot reloading** with 1-second reload delay
- **Development tools** included (git, vim, htop, procps)
- **Fast rebuilds** with optimized caching
- **Debugging capabilities** with proper environment setup
- **Volume mounting** for live code changes

## Usage

### Building Images

#### Development Image
```bash
# Build development image
docker build -f backend/Dockerfile.dev -t university-qa:dev backend/

# Or use docker-compose
docker-compose -f docker-compose.dev.yml build
```

#### Production Image
```bash
# Build production image
docker build -f backend/Dockerfile.prod -t university-qa:prod backend/

# Or use docker-compose
docker-compose -f docker-compose.prod.yml build
```

#### Using the Build Script (Linux/macOS)
```bash
# Make script executable
chmod +x scripts/docker-build.sh

# Build development image
./scripts/docker-build.sh dev

# Build production image with analysis
./scripts/docker-build.sh prod

# Build both images
./scripts/docker-build.sh both

# Analyze image sizes
./scripts/docker-build.sh analyze
```

### Running Containers

#### Development Environment
```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up

# Start with rebuild
docker-compose -f docker-compose.dev.yml up --build
```

#### Production Environment
```bash
# Start production environment
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f backend
```

## Configuration Details

### Production Configuration

#### Resource Limits
- **CPU**: 2.0 cores limit, 1.0 core reservation
- **Memory**: 4GB limit, 2GB reservation
- **Restart Policy**: On failure with 3 max attempts

#### Security Features
- Non-root user execution (`appuser`)
- No new privileges security option
- Temporary filesystem for `/tmp`
- Read-only filesystem support (configurable)

#### Health Checks
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Retries**: 3 attempts
- **Start Period**: 60 seconds

### Development Configuration

#### Volume Mounts
- **Source Code**: `./backend/app:/app/app:cached` (live reload)
- **HuggingFace Cache**: `./hf_cache:/root/.cache/huggingface:cached`
- **Uploads**: `./uploads:/app/uploads:delegated`

#### Environment Variables
- `WATCHFILES_FORCE_POLLING=true` - Force polling for file changes
- `PYTHONPATH=/app` - Python path configuration
- `PYTHONUNBUFFERED=1` - Unbuffered Python output

## Health Check Endpoints

The system provides multiple health check endpoints:

### `/health`
Comprehensive health check with detailed status:
```json
{
  "status": "healthy",
  "timestamp": 1703123456.789,
  "uptime": 3600.0,
  "checks": {
    "database": true,
    "application": true
  }
}
```

### `/health/ready`
Kubernetes-style readiness probe:
```json
{
  "ready": true,
  "timestamp": 1703123456.789,
  "checks": {
    "database": true,
    "application": true
  }
}
```

### `/health/live`
Kubernetes-style liveness probe:
```json
{
  "alive": true,
  "timestamp": 1703123456.789,
  "uptime": 3600.0
}
```

## Performance Optimizations

### Build Cache Optimization
- **Layer caching** for dependencies
- **Multi-stage builds** to separate build and runtime
- **Minimal base images** to reduce size
- **Build context optimization** with `.dockerignore`

### Runtime Optimizations
- **Non-root user** for security
- **Resource limits** to prevent resource exhaustion
- **Health checks** with appropriate intervals
- **Restart policies** for automatic recovery

## Expected Performance Improvements

Based on the design requirements:

1. **Image Size Reduction**: At least 30% smaller than unoptimized builds
2. **Build Performance**: 50% faster builds with caching enabled
3. **Development Reload**: Service reload in less than 3 seconds
4. **Security**: Non-root execution and container hardening

## Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clear Docker cache
docker builder prune -a

# Rebuild without cache
docker build --no-cache -f backend/Dockerfile.prod -t university-qa:prod backend/
```

#### Permission Issues
```bash
# Check container user
docker run --rm university-qa:prod whoami

# Check file permissions
docker run --rm university-qa:prod ls -la /app
```

#### Health Check Failures
```bash
# Test health endpoint manually
curl http://localhost:8000/health

# Check container logs
docker logs <container_id>
```

### Performance Analysis

#### Image Size Comparison
```bash
# Compare image sizes
docker images | grep university-qa

# Analyze layers
docker history university-qa:prod
```

#### Build Time Analysis
```bash
# Time the build process
time docker build -f backend/Dockerfile.prod -t university-qa:prod backend/
```

## Security Considerations

### Production Security
- Containers run as non-root user (`appuser`)
- No new privileges security option enabled
- Minimal runtime dependencies
- Regular security scanning recommended

### Development Security
- Development tools included for debugging
- Source code mounted as volumes
- Less restrictive for development convenience

## Monitoring and Logging

### Container Monitoring
- Resource usage tracking via Docker stats
- Health check monitoring
- Log aggregation support

### Application Monitoring
- Structured logging with JSON format
- Error context capture
- Performance metrics collection

## Next Steps

1. **Set up CI/CD pipeline** for automated builds
2. **Configure container registry** for image distribution
3. **Implement monitoring stack** for production deployment
4. **Set up automated security scanning** for vulnerabilities
5. **Configure log aggregation** for centralized logging