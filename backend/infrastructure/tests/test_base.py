"""Tests for base infrastructure components."""

import pytest
from ..config.base import InfrastructureConfig, ResourceLimits, HealthCheckConfig, CacheConfig, SecurityConfig


class TestInfrastructureConfig:
    """Test infrastructure configuration models."""
    
    def test_default_config_creation(self):
        """Test creating config with default values."""
        config = InfrastructureConfig()
        
        assert config.python_version == "3.12"
        assert isinstance(config.resource_limits, ResourceLimits)
        assert isinstance(config.health_check, HealthCheckConfig)
        assert isinstance(config.cache, CacheConfig)
        assert isinstance(config.security, SecurityConfig)
    
    def test_custom_config_creation(self):
        """Test creating config with custom values."""
        config = InfrastructureConfig(
            python_version="3.11",
            resource_limits=ResourceLimits(cpu_limit="4.0", memory_limit="8G"),
            health_check=HealthCheckConfig(interval=60, timeout=20),
            cache=CacheConfig(cache_ttl=7200),
            security=SecurityConfig(run_as_non_root=False)
        )
        
        assert config.python_version == "3.11"
        assert config.resource_limits.cpu_limit == "4.0"
        assert config.resource_limits.memory_limit == "8G"
        assert config.health_check.interval == 60
        assert config.health_check.timeout == 20
        assert config.cache.cache_ttl == 7200
        assert config.security.run_as_non_root == False
    
    def test_config_validation(self):
        """Test configuration validation."""
        # Valid config should not raise
        config = InfrastructureConfig()
        assert config.python_version == "3.12"
        
        # Test that extra fields are forbidden
        with pytest.raises(ValueError):
            InfrastructureConfig(invalid_field="value")


class TestResourceLimits:
    """Test resource limits configuration."""
    
    def test_default_resource_limits(self):
        """Test default resource limits."""
        limits = ResourceLimits()
        
        assert limits.cpu_limit == "2.0"
        assert limits.memory_limit == "4G"
        assert limits.cpu_reservation == "1.0"
        assert limits.memory_reservation == "2G"
    
    def test_custom_resource_limits(self):
        """Test custom resource limits."""
        limits = ResourceLimits(
            cpu_limit="4.0",
            memory_limit="8G",
            cpu_reservation="2.0",
            memory_reservation="4G"
        )
        
        assert limits.cpu_limit == "4.0"
        assert limits.memory_limit == "8G"
        assert limits.cpu_reservation == "2.0"
        assert limits.memory_reservation == "4G"


class TestHealthCheckConfig:
    """Test health check configuration."""
    
    def test_default_health_check_config(self):
        """Test default health check configuration."""
        config = HealthCheckConfig()
        
        assert config.interval == 30
        assert config.timeout == 10
        assert config.retries == 3
        assert config.start_period == 60
        assert config.startup_interval == 30
        assert config.running_interval == 10
        assert config.failure_interval == 5
    
    def test_custom_health_check_config(self):
        """Test custom health check configuration."""
        config = HealthCheckConfig(
            interval=60,
            timeout=20,
            retries=5,
            start_period=120,
            startup_interval=60,
            running_interval=20,
            failure_interval=10
        )
        
        assert config.interval == 60
        assert config.timeout == 20
        assert config.retries == 5
        assert config.start_period == 120
        assert config.startup_interval == 60
        assert config.running_interval == 20
        assert config.failure_interval == 10


class TestCacheConfig:
    """Test cache configuration."""
    
    def test_default_cache_config(self):
        """Test default cache configuration."""
        config = CacheConfig()
        
        assert config.pip_cache_enabled == True
        assert config.docker_cache_enabled == True
        assert config.model_cache_enabled == True
        assert config.cache_ttl == 3600
        assert config.cache_dir == "/tmp/cache"
    
    def test_custom_cache_config(self):
        """Test custom cache configuration."""
        config = CacheConfig(
            pip_cache_enabled=False,
            docker_cache_enabled=False,
            model_cache_enabled=False,
            cache_ttl=7200,
            cache_dir="/custom/cache"
        )
        
        assert config.pip_cache_enabled == False
        assert config.docker_cache_enabled == False
        assert config.model_cache_enabled == False
        assert config.cache_ttl == 7200
        assert config.cache_dir == "/custom/cache"


class TestSecurityConfig:
    """Test security configuration."""
    
    def test_default_security_config(self):
        """Test default security configuration."""
        config = SecurityConfig()
        
        assert config.run_as_non_root == True
        assert config.read_only_filesystem == False
        assert config.vulnerability_scanning == True
        assert config.secrets_management == True
        assert config.network_segmentation == True
    
    def test_custom_security_config(self):
        """Test custom security configuration."""
        config = SecurityConfig(
            run_as_non_root=False,
            read_only_filesystem=True,
            vulnerability_scanning=False,
            secrets_management=False,
            network_segmentation=False
        )
        
        assert config.run_as_non_root == False
        assert config.read_only_filesystem == True
        assert config.vulnerability_scanning == False
        assert config.secrets_management == False
        assert config.network_segmentation == False