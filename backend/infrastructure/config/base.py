"""Base configuration models for infrastructure components."""

from pydantic import BaseModel, ConfigDict
from typing import Dict, List, Optional


class ResourceLimits(BaseModel):
    """Resource limits configuration for containers."""
    cpu_limit: str = "2.0"
    memory_limit: str = "4G"
    cpu_reservation: str = "1.0"
    memory_reservation: str = "2G"


class HealthCheckConfig(BaseModel):
    """Health check configuration with tiered intervals."""
    interval: int = 30
    timeout: int = 10
    retries: int = 3
    start_period: int = 60
    startup_interval: int = 30
    running_interval: int = 10
    failure_interval: int = 5


class CacheConfig(BaseModel):
    """Caching configuration for various components."""
    pip_cache_enabled: bool = True
    docker_cache_enabled: bool = True
    model_cache_enabled: bool = True
    cache_ttl: int = 3600
    cache_dir: str = "/tmp/cache"


class SecurityConfig(BaseModel):
    """Security configuration for containers and services."""
    run_as_non_root: bool = True
    read_only_filesystem: bool = False
    vulnerability_scanning: bool = True
    secrets_management: bool = True
    network_segmentation: bool = True


class InfrastructureConfig(BaseModel):
    """Main infrastructure configuration combining all components."""
    model_config = ConfigDict(validate_assignment=True, extra="forbid")
    
    python_version: str = "3.12"
    resource_limits: ResourceLimits = ResourceLimits()
    health_check: HealthCheckConfig = HealthCheckConfig()
    cache: CacheConfig = CacheConfig()
    security: SecurityConfig = SecurityConfig()