"""Configuration data models for infrastructure."""

# Re-export from config.base for convenience
from ..config.base import (
    InfrastructureConfig,
    ResourceLimits,
    HealthCheckConfig,
    CacheConfig,
    SecurityConfig,
)

__all__ = [
    "InfrastructureConfig",
    "ResourceLimits",
    "HealthCheckConfig", 
    "CacheConfig",
    "SecurityConfig",
]