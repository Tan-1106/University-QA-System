"""Pytest configuration and fixtures for infrastructure tests."""

import pytest
import tempfile
import shutil
from pathlib import Path
from typing import Dict, Any

from ..config.base import InfrastructureConfig, ResourceLimits, HealthCheckConfig, CacheConfig, SecurityConfig
from ..managers.version_manager import VersionConsistencyManager
from ..managers.dependency_manager import DependencyManager
from ..managers.resource_manager import ResourceManager
from ..managers.cache_manager import CacheManager
from ..managers.health_manager import HealthManager
from ..managers.security_manager import SecurityManager


@pytest.fixture
def temp_dir():
    """Create a temporary directory for tests."""
    temp_path = tempfile.mkdtemp()
    yield Path(temp_path)
    shutil.rmtree(temp_path)


@pytest.fixture
def sample_requirements_content():
    """Sample requirements.txt content for testing."""
    return """fastapi==0.104.1
starlette==0.27.0
uvicorn==0.24.0
pydantic==2.5.0
"""


@pytest.fixture
def sample_dockerfile_content():
    """Sample Dockerfile content for testing."""
    return """FROM python:3.12-slim

RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app/ ./app/
USER appuser

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \\
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
"""


@pytest.fixture
def infrastructure_config():
    """Sample infrastructure configuration."""
    return InfrastructureConfig(
        python_version="3.12",
        resource_limits=ResourceLimits(
            cpu_limit="2.0",
            memory_limit="4G",
            cpu_reservation="1.0",
            memory_reservation="2G"
        ),
        health_check=HealthCheckConfig(
            interval=30,
            timeout=10,
            retries=3,
            start_period=60
        ),
        cache=CacheConfig(
            pip_cache_enabled=True,
            docker_cache_enabled=True,
            model_cache_enabled=True,
            cache_ttl=3600
        ),
        security=SecurityConfig(
            run_as_non_root=True,
            read_only_filesystem=False,
            vulnerability_scanning=True,
            secrets_management=True
        )
    )


@pytest.fixture
def version_manager(infrastructure_config):
    """Version consistency manager instance."""
    config = {"python_version": infrastructure_config.python_version}
    manager = VersionConsistencyManager(config)
    manager.initialize()
    return manager


@pytest.fixture
def dependency_manager(temp_dir):
    """Dependency manager instance."""
    config = {
        "requirements_file": str(temp_dir / "requirements.txt"),
        "lock_file": str(temp_dir / "requirements-lock.txt")
    }
    manager = DependencyManager(config)
    manager.initialize()
    return manager


@pytest.fixture
def resource_manager(infrastructure_config):
    """Resource manager instance."""
    config = {"resource_limits": infrastructure_config.resource_limits.dict()}
    manager = ResourceManager(config)
    manager.initialize()
    return manager


@pytest.fixture
def cache_manager(temp_dir, infrastructure_config):
    """Cache manager instance."""
    config = {
        "cache": {
            **infrastructure_config.cache.dict(),
            "cache_dir": str(temp_dir / "cache")
        }
    }
    manager = CacheManager(config)
    manager.initialize()
    return manager


@pytest.fixture
def health_manager(infrastructure_config):
    """Health manager instance."""
    config = {"health_check": infrastructure_config.health_check.dict()}
    manager = HealthManager(config)
    manager.initialize()
    return manager


@pytest.fixture
def security_manager(infrastructure_config):
    """Security manager instance."""
    config = {"security": infrastructure_config.security.dict()}
    manager = SecurityManager(config)
    manager.initialize()
    return manager