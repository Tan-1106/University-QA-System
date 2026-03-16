"""Infrastructure orchestration module for coordinating all components."""

import logging
from typing import Dict, List, Optional, Any
from pathlib import Path

from .config.base import InfrastructureConfig
from .config.settings import get_settings
from .managers.version_manager import VersionConsistencyManager
from .managers.dependency_manager import DependencyManager
from .managers.resource_manager import ResourceManager
from .managers.cache_manager import CacheManager
from .managers.health_manager import HealthManager
from .managers.security_manager import SecurityManager


class InfrastructureOrchestrator:
    """Orchestrates all infrastructure components."""
    
    def __init__(self, config: Optional[InfrastructureConfig] = None):
        """Initialize infrastructure orchestrator."""
        self.config = config or InfrastructureConfig()
        self.settings = get_settings()
        self.logger = logging.getLogger(__name__)
        
        # Initialize managers
        self.version_manager = None
        self.dependency_manager = None
        self.resource_manager = None
        self.cache_manager = None
        self.health_manager = None
        self.security_manager = None
        
        self._initialized = False
    
    def initialize(self, project_root: Optional[str] = None) -> None:
        """Initialize all infrastructure components."""
        if self._initialized:
            self.logger.warning("Infrastructure already initialized")
            return
        
        project_root = project_root or "."
        project_path = Path(project_root)
        
        self.logger.info("Initializing infrastructure orchestrator")
        
        # Initialize version manager
        self.version_manager = VersionConsistencyManager({
            "python_version": self.config.python_version
        })
        self.version_manager.initialize()
        
        # Initialize dependency manager
        self.dependency_manager = DependencyManager({
            "requirements_file": str(project_path / "requirements.txt"),
            "lock_file": str(project_path / "requirements-lock.txt")
        })
        self.dependency_manager.initialize()
        
        # Initialize resource manager
        self.resource_manager = ResourceManager({
            "resource_limits": self.config.resource_limits.model_dump(),
            "alert_threshold": 0.8
        })
        self.resource_manager.initialize()
        
        # Initialize cache manager
        cache_dir = project_path / ".cache"
        self.cache_manager = CacheManager({
            "cache": {
                **self.config.cache.model_dump(),
                "cache_dir": str(cache_dir)
            }
        })
        self.cache_manager.initialize()
        
        # Initialize health manager
        self.health_manager = HealthManager({
            "health_check": self.config.health_check.model_dump()
        })
        self.health_manager.initialize()
        self.health_manager.setup_default_health_checks()
        
        # Initialize security manager
        self.security_manager = SecurityManager({
            "security": self.config.security.model_dump()
        })
        self.security_manager.initialize()
        
        self._initialized = True
        self.logger.info("Infrastructure orchestrator initialized successfully")
    
    def validate_all(self) -> Dict[str, bool]:
        """Validate all infrastructure components."""
        if not self._initialized:
            raise RuntimeError("Infrastructure not initialized. Call initialize() first.")
        
        validation_results = {
            "version_manager": self.version_manager.validate(),
            "dependency_manager": self.dependency_manager.validate(),
            "resource_manager": self.resource_manager.validate(),
            "cache_manager": self.cache_manager.validate(),
            "health_manager": self.health_manager.validate(),
            "security_manager": self.security_manager.validate()
        }
        
        all_valid = all(validation_results.values())
        
        if all_valid:
            self.logger.info("All infrastructure components validated successfully")
        else:
            failed_components = [name for name, valid in validation_results.items() if not valid]
            self.logger.error(f"Infrastructure validation failed for: {failed_components}")
        
        return validation_results
    
    def get_comprehensive_report(self) -> Dict[str, Any]:
        """Get comprehensive infrastructure status report."""
        if not self._initialized:
            raise RuntimeError("Infrastructure not initialized. Call initialize() first.")
        
        report = {
            "infrastructure_config": {
                "python_version": self.config.python_version,
                "environment": self.settings.environment,
                "debug": self.settings.debug
            },
            "validation_status": self.validate_all(),
            "component_reports": {
                "version": self.version_manager.get_version_report(),
                "dependencies": self.dependency_manager.get_dependency_report(),
                "resources": self.resource_manager.get_resource_report(),
                "cache": self.cache_manager.get_cache_report(),
                "health": self.health_manager.get_health_report(),
                "security": self.security_manager.get_security_report()
            },
            "system_status": {
                "initialized": self._initialized,
                "all_components_valid": all(self.validate_all().values())
            }
        }
        
        return report
    
    def setup_development_environment(self, project_root: str = ".") -> None:
        """Set up development environment with optimized settings."""
        self.logger.info("Setting up development environment")
        
        # Create version files
        self.version_manager.create_version_files(project_root)
        
        # Set up cache directories
        cache_dir = Path(project_root) / ".cache"
        cache_dir.mkdir(exist_ok=True)
        
        # Generate development Docker configuration
        docker_config = self.resource_manager.generate_docker_compose_config()
        security_config = self.security_manager.generate_docker_compose_security_config()
        
        # Merge configurations
        dev_config = {
            **docker_config,
            **security_config,
            "environment": ["ENVIRONMENT=development"],
            "volumes": [
                f"{project_root}:/app",
                f"{cache_dir}:/app/.cache"
            ]
        }
        
        self.logger.info("Development environment setup completed")
        return dev_config
    
    def setup_production_environment(self, project_root: str = ".") -> None:
        """Set up production environment with security hardening."""
        self.logger.info("Setting up production environment")
        
        # Validate security requirements
        dockerfile_path = Path(project_root) / "Dockerfile"
        if dockerfile_path.exists():
            security_result = self.security_manager.validate_dockerfile_security(str(dockerfile_path))
            if not security_result["valid"]:
                critical_violations = [
                    v for v in security_result["violations"] 
                    if v["severity"] == "critical"
                ]
                if critical_violations:
                    raise RuntimeError(f"Critical security violations found: {critical_violations}")
        
        # Generate production Docker configuration
        docker_config = self.resource_manager.generate_docker_compose_config()
        security_config = self.security_manager.generate_docker_compose_security_config()
        
        # Merge configurations with production settings
        prod_config = {
            **docker_config,
            **security_config,
            "environment": ["ENVIRONMENT=production"],
            "restart": "unless-stopped",
            "logging": {
                "driver": "json-file",
                "options": {
                    "max-size": "10m",
                    "max-file": "3"
                }
            }
        }
        
        self.logger.info("Production environment setup completed")
        return prod_config
    
    async def perform_health_checks(self) -> Dict[str, Any]:
        """Perform comprehensive health checks."""
        if not self._initialized:
            raise RuntimeError("Infrastructure not initialized. Call initialize() first.")
        
        health_results = await self.health_manager.perform_all_health_checks()
        health_summary = self.health_manager.get_service_health_summary()
        
        return {
            "individual_results": {
                name: {
                    "healthy": result.is_healthy,
                    "response_time": result.response_time,
                    "timestamp": result.timestamp.isoformat(),
                    "error": result.error_message
                }
                for name, result in health_results.items()
            },
            "summary": health_summary
        }
    
    def cleanup_resources(self) -> None:
        """Clean up infrastructure resources."""
        if not self._initialized:
            return
        
        self.logger.info("Cleaning up infrastructure resources")
        
        # Clean up expired cache
        if self.cache_manager:
            cleanup_stats = self.cache_manager.cleanup_expired_cache()
            self.logger.info(f"Cache cleanup completed: {cleanup_stats}")
        
        # Stop resource monitoring
        if self.resource_manager:
            self.resource_manager.monitoring_enabled = False
        
        self.logger.info("Infrastructure cleanup completed")


# Global infrastructure instance
_infrastructure = None


def get_infrastructure() -> InfrastructureOrchestrator:
    """Get global infrastructure orchestrator instance."""
    global _infrastructure
    if _infrastructure is None:
        _infrastructure = InfrastructureOrchestrator()
    return _infrastructure


def initialize_infrastructure(config: Optional[InfrastructureConfig] = None, project_root: str = ".") -> InfrastructureOrchestrator:
    """Initialize global infrastructure orchestrator."""
    global _infrastructure
    _infrastructure = InfrastructureOrchestrator(config)
    _infrastructure.initialize(project_root)
    return _infrastructure