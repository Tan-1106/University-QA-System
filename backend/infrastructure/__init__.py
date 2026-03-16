"""
Infrastructure management package for University QA System.

This package provides comprehensive infrastructure optimization including:
- Version consistency management
- Dependency management with lock files
- Multi-stage Docker build optimization
- Resource management and monitoring
- Caching systems
- Health check systems
- Configuration management
- Security hardening
- Development experience optimization
"""

from .config.base import InfrastructureConfig
from .managers.version_manager import VersionConsistencyManager
from .managers.dependency_manager import DependencyManager
from .managers.resource_manager import ResourceManager
from .managers.cache_manager import CacheManager
from .managers.health_manager import HealthManager
from .managers.security_manager import SecurityManager
from .orchestrator import InfrastructureOrchestrator, get_infrastructure, initialize_infrastructure

__all__ = [
    "InfrastructureConfig",
    "VersionConsistencyManager", 
    "DependencyManager",
    "ResourceManager",
    "CacheManager",
    "HealthManager",
    "SecurityManager",
    "InfrastructureOrchestrator",
    "get_infrastructure",
    "initialize_infrastructure",
]