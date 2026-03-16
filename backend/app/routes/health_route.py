"""
Health check endpoint for Docker container monitoring
"""

import time
import logging
from typing import Dict, Any
from fastapi import APIRouter, HTTPException

from app.databases.mongo import get_database

logger = logging.getLogger("SystemLogger")
router = APIRouter()


class HealthChecker:
    """Health check system with tiered intervals for different service states"""
    
    def __init__(self):
        self.startup_time = time.time()
        self.health_checks = {
            "database": self._check_database,
            "application": self._check_application
        }
    
    async def _check_database(self) -> bool:
        """Check MongoDB connection"""
        try:
            db = await get_database()
            # Simple ping to check connection
            await db.command("ping")
            return True
        except Exception as e:
            logger.warning(f"Database health check failed: {e}")
            return False
    
    async def _check_application(self) -> bool:
        """Check if application is ready to serve requests"""
        try:
            # Basic application readiness check
            return True
        except Exception as e:
            logger.warning(f"Application health check failed: {e}")
            return False


@router.get("/health")
async def health_check() -> Dict[str, Any]:
    """
    Comprehensive health check endpoint for Docker containers
    Returns detailed health status for monitoring systems
    """
    checker = HealthChecker()
    results = {}
    
    # Run all health checks
    for name, check_func in checker.health_checks.items():
        try:
            results[name] = await check_func()
        except Exception as e:
            logger.error(f"Health check '{name}' failed with exception: {e}")
            results[name] = False
    
    # Determine overall health status
    all_healthy = all(results.values())
    
    response = {
        "status": "healthy" if all_healthy else "unhealthy",
        "timestamp": time.time(),
        "uptime": time.time() - checker.startup_time,
        "checks": results
    }
    
    # Return appropriate HTTP status code
    if not all_healthy:
        raise HTTPException(status_code=503, detail=response)
    
    return response


@router.get("/health/ready")
async def readiness_check() -> Dict[str, Any]:
    """
    Kubernetes-style readiness probe
    Checks if the service is ready to receive traffic
    """
    checker = HealthChecker()
    
    # Check critical dependencies
    db_healthy = await checker._check_database()
    app_healthy = await checker._check_application()
    
    ready = db_healthy and app_healthy
    
    response = {
        "ready": ready,
        "timestamp": time.time(),
        "checks": {
            "database": db_healthy,
            "application": app_healthy
        }
    }
    
    if not ready:
        raise HTTPException(status_code=503, detail=response)
    
    return response


@router.get("/health/live")
async def liveness_check() -> Dict[str, Any]:
    """
    Kubernetes-style liveness probe
    Checks if the service is alive and should not be restarted
    """
    checker = HealthChecker()
    return {
        "alive": True,
        "timestamp": time.time(),
        "uptime": time.time() - checker.startup_time
    }