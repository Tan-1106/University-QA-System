"""Tests for infrastructure managers."""

import pytest
import asyncio
from pathlib import Path

from ..managers.version_manager import VersionConsistencyManager
from ..managers.dependency_manager import DependencyManager
from ..managers.resource_manager import ResourceManager
from ..managers.cache_manager import CacheManager
from ..managers.health_manager import HealthManager, ServiceState
from ..managers.security_manager import SecurityManager


class TestVersionConsistencyManager:
    """Test version consistency manager."""
    
    def test_manager_initialization(self, version_manager):
        """Test manager initialization."""
        assert version_manager.required_version == "3.12"
        assert hasattr(version_manager, "_initialized")
    
    def test_python_version_validation(self, version_manager):
        """Test Python version validation."""
        # This will depend on the actual Python version running the test
        result = version_manager.validate_python_version()
        assert isinstance(result, bool)
    
    def test_dockerfile_version_check(self, version_manager, temp_dir, sample_dockerfile_content):
        """Test Dockerfile Python version checking."""
        dockerfile_path = temp_dir / "Dockerfile"
        dockerfile_path.write_text(sample_dockerfile_content)
        
        result = version_manager.check_docker_python_version(str(dockerfile_path))
        assert result == True  # Sample Dockerfile uses Python 3.12
    
    def test_dockerfile_version_check_with_variants(self, version_manager, temp_dir):
        """Test Dockerfile Python version checking with different image variants."""
        # Test with slim variant
        dockerfile_slim = "FROM python:3.12-slim\nWORKDIR /app"
        dockerfile_path = temp_dir / "Dockerfile.slim"
        dockerfile_path.write_text(dockerfile_slim)
        
        result = version_manager.check_docker_python_version(str(dockerfile_path))
        assert result == True
        
        # Test with alpine variant
        dockerfile_alpine = "FROM python:3.12-alpine\nWORKDIR /app"
        dockerfile_path = temp_dir / "Dockerfile.alpine"
        dockerfile_path.write_text(dockerfile_alpine)
        
        result = version_manager.check_docker_python_version(str(dockerfile_path))
        assert result == True
    
    def test_version_mismatch_warning(self, version_manager):
        """Test version mismatch warning generation."""
        warning = version_manager.generate_version_mismatch_warning("3.12", "3.11", "test context")
        
        assert "⚠️  Python version mismatch detected" in warning
        assert "Expected: Python 3.12" in warning
        assert "Actual:   Python 3.11" in warning
        assert "test context" in warning
        assert "🔧 Remediation steps:" in warning
        assert "pyenv install 3.12" in warning
    
    def test_comprehensive_mismatch_report(self, version_manager):
        """Test comprehensive mismatch report generation."""
        report = version_manager.generate_comprehensive_mismatch_report()
        
        assert "timestamp" in report
        assert "required_version" in report
        assert "mismatches" in report
        assert "warnings" in report
        assert "remediation_required" in report
        assert isinstance(report["mismatches"], list)
        assert isinstance(report["warnings"], list)
    
    def test_version_files_creation(self, version_manager, temp_dir):
        """Test creation of version specification files."""
        version_manager.create_version_files(str(temp_dir))
        
        python_version_file = temp_dir / ".python-version"
        runtime_file = temp_dir / "runtime.txt"
        
        assert python_version_file.exists()
        assert runtime_file.exists()
        assert python_version_file.read_text() == "3.12"
        assert runtime_file.read_text() == "python-3.12"
    
    def test_version_files_not_overwritten(self, version_manager, temp_dir):
        """Test that existing version files are not overwritten."""
        # Create existing files with different content
        python_version_file = temp_dir / ".python-version"
        runtime_file = temp_dir / "runtime.txt"
        
        python_version_file.write_text("3.11")
        runtime_file.write_text("python-3.11")
        
        # Call create_version_files
        version_manager.create_version_files(str(temp_dir))
        
        # Files should not be overwritten
        assert python_version_file.read_text() == "3.11"
        assert runtime_file.read_text() == "python-3.11"
    
    def test_validate_all_docker_files(self, version_manager, temp_dir):
        """Test validation of all Docker files."""
        # Create multiple Docker files
        dockerfile_dev = temp_dir / "backend" / "Dockerfile.dev"
        dockerfile_dev.parent.mkdir(parents=True, exist_ok=True)
        dockerfile_dev.write_text("FROM python:3.12-slim\nWORKDIR /app")
        
        dockerfile_prod = temp_dir / "backend" / "Dockerfile.prod"
        dockerfile_prod.write_text("FROM python:3.12-alpine\nWORKDIR /app")
        
        # Change working directory temporarily
        import os
        original_cwd = os.getcwd()
        os.chdir(temp_dir)
        
        try:
            result = version_manager.validate_all_docker_files()
            assert result == True
        finally:
            os.chdir(original_cwd)
    
    def test_validate_version_files(self, version_manager, temp_dir):
        """Test validation of version specification files."""
        # Create correct version files
        python_version_file = temp_dir / ".python-version"
        runtime_file = temp_dir / "runtime.txt"
        
        python_version_file.write_text("3.12")
        runtime_file.write_text("python-3.12")
        
        # Change working directory temporarily
        import os
        original_cwd = os.getcwd()
        os.chdir(temp_dir)
        
        try:
            result = version_manager.validate_version_files()
            assert result == True
        finally:
            os.chdir(original_cwd)
    
    def test_enforce_version_consistency(self, version_manager, temp_dir):
        """Test version consistency enforcement."""
        # Change working directory temporarily
        import os
        original_cwd = os.getcwd()
        os.chdir(temp_dir)
        
        try:
            # Set project root to temp directory
            version_manager.project_root = str(temp_dir)
            result = version_manager.enforce_version_consistency()
            
            # Should create version files and validate
            assert isinstance(result, bool)
            
            # Check that version files were created
            python_version_file = temp_dir / ".python-version"
            runtime_file = temp_dir / "runtime.txt"
            assert python_version_file.exists()
            assert runtime_file.exists()
        finally:
            os.chdir(original_cwd)
    
    def test_version_report(self, version_manager):
        """Test version report generation."""
        report = version_manager.get_version_report()
        
        assert "required_version" in report
        assert "current_version" in report
        assert "is_consistent" in report
        assert "python_executable" in report
        assert "version_info" in report
        assert "environment_checks" in report
        
        # Check environment checks structure
        env_checks = report["environment_checks"]
        assert "python_version" in env_checks
        assert "docker_files" in env_checks
        assert "version_files" in env_checks
    
    def test_get_status(self, version_manager):
        """Test status report generation."""
        status = version_manager.get_status()
        
        assert "manager" in status
        assert "initialized" in status
        assert "config" in status
        assert "version_consistency" in status
        assert "required_version" in status
        assert "current_version" in status
        assert "all_checks_passed" in status


class TestDependencyManager:
    """Test dependency manager."""
    
    def test_manager_initialization(self, dependency_manager):
        """Test manager initialization."""
        assert hasattr(dependency_manager, "_initialized")
    
    def test_exact_versions_validation(self, dependency_manager, temp_dir, sample_requirements_content):
        """Test exact version validation."""
        requirements_file = temp_dir / "requirements.txt"
        requirements_file.write_text(sample_requirements_content)
        
        result = dependency_manager.validate_exact_versions(str(requirements_file))
        assert result == True  # Sample requirements use exact versions
    
    def test_inexact_versions_detection(self, dependency_manager, temp_dir):
        """Test detection of inexact versions."""
        inexact_requirements = """fastapi>=0.104.0
starlette~=0.27.0
uvicorn
"""
        requirements_file = temp_dir / "requirements.txt"
        requirements_file.write_text(inexact_requirements)
        
        result = dependency_manager.validate_exact_versions(str(requirements_file))
        assert result == False
    
    def test_dependency_report(self, dependency_manager, temp_dir, sample_requirements_content):
        """Test dependency report generation."""
        requirements_file = temp_dir / "requirements.txt"
        requirements_file.write_text(sample_requirements_content)
        
        report = dependency_manager.get_dependency_report()
        
        assert "requirements_file" in report
        assert "lock_file" in report
        assert "requirements_exists" in report
        assert "dependency_count" in report


class TestResourceManager:
    """Test resource manager."""
    
    def test_manager_initialization(self, resource_manager):
        """Test manager initialization."""
        assert hasattr(resource_manager, "_initialized")
        assert resource_manager.monitoring_enabled == True
    
    def test_memory_limit_parsing(self, resource_manager):
        """Test memory limit parsing."""
        assert resource_manager._parse_memory_limit("4G") == 4 * 1024 * 1024 * 1024
        assert resource_manager._parse_memory_limit("512M") == 512 * 1024 * 1024
        assert resource_manager._parse_memory_limit("1024K") == 1024 * 1024
        assert resource_manager._parse_memory_limit("1073741824") == 1073741824
    
    def test_cpu_limit_parsing(self, resource_manager):
        """Test CPU limit parsing."""
        assert resource_manager._parse_cpu_limit("2.0") == 2.0
        assert resource_manager._parse_cpu_limit("0.5") == 0.5
        assert resource_manager._parse_cpu_limit("4") == 4.0
    
    def test_current_usage_collection(self, resource_manager):
        """Test current resource usage collection."""
        usage = resource_manager.get_current_usage()
        
        assert hasattr(usage, "timestamp")
        assert hasattr(usage, "cpu_percent")
        assert hasattr(usage, "memory_percent")
        assert hasattr(usage, "memory_bytes")
        assert hasattr(usage, "disk_usage")
        assert hasattr(usage, "network_io")
    
    def test_docker_compose_config_generation(self, resource_manager):
        """Test Docker Compose configuration generation."""
        config = resource_manager.generate_docker_compose_config()
        
        assert "deploy" in config
        assert "resources" in config["deploy"]
        assert "limits" in config["deploy"]["resources"]
        assert "reservations" in config["deploy"]["resources"]
        assert "restart_policy" in config["deploy"]
    
    def test_resource_report(self, resource_manager):
        """Test resource report generation."""
        report = resource_manager.get_resource_report()
        
        assert "resource_limits" in report
        assert "current_usage" in report
        assert "alerts" in report
        assert "monitoring_enabled" in report


class TestCacheManager:
    """Test cache manager."""
    
    def test_manager_initialization(self, cache_manager):
        """Test manager initialization."""
        assert hasattr(cache_manager, "_initialized")
        assert cache_manager.cache_dir.exists()
        assert cache_manager.pip_cache_dir.exists()
        assert cache_manager.docker_cache_dir.exists()
        assert cache_manager.model_cache_dir.exists()
    
    def test_cache_key_generation(self, cache_manager):
        """Test cache key generation."""
        key1 = cache_manager._generate_cache_key("test content")
        key2 = cache_manager._generate_cache_key("test content")
        key3 = cache_manager._generate_cache_key("different content")
        
        assert key1 == key2  # Same content should generate same key
        assert key1 != key3  # Different content should generate different key
        assert len(key1) == 16  # Key should be 16 characters
    
    def test_pip_dependencies_caching(self, cache_manager):
        """Test pip dependencies caching."""
        requirements_content = "fastapi==0.104.1\nstarlette==0.27.0"
        
        # Cache dependencies
        cache_path = cache_manager.cache_pip_dependencies(requirements_content)
        assert cache_path != ""
        assert Path(cache_path).exists()
        
        # Retrieve cached dependencies
        cached_path = cache_manager.get_cached_pip_dependencies(requirements_content)
        assert cached_path == cache_path
    
    def test_cache_report(self, cache_manager):
        """Test cache report generation."""
        report = cache_manager.get_cache_report()
        
        assert "cache_config" in report
        assert "cache_stats" in report
        assert "total_cache_size" in report
        assert "pip_cache" in report["cache_stats"]
        assert "docker_cache" in report["cache_stats"]
        assert "model_cache" in report["cache_stats"]


class TestHealthManager:
    """Test health manager."""
    
    def test_manager_initialization(self, health_manager):
        """Test manager initialization."""
        assert hasattr(health_manager, "_initialized")
        assert health_manager.startup_time > 0
    
    def test_health_check_registration(self, health_manager):
        """Test health check registration."""
        async def dummy_check():
            return True
        
        health_manager.register_health_check("test_service", dummy_check)
        
        assert "test_service" in health_manager.health_checks
        assert "test_service" in health_manager.service_states
        assert health_manager.service_states["test_service"] == ServiceState.STARTING
    
    def test_check_interval_calculation(self, health_manager):
        """Test check interval calculation based on service state."""
        health_manager.service_states["test_service"] = ServiceState.STARTING
        assert health_manager.get_check_interval("test_service") == health_manager.health_config.startup_interval
        
        health_manager.service_states["test_service"] = ServiceState.RUNNING
        assert health_manager.get_check_interval("test_service") == health_manager.health_config.running_interval
        
        health_manager.service_states["test_service"] = ServiceState.FAILING
        assert health_manager.get_check_interval("test_service") == health_manager.health_config.failure_interval
    
    @pytest.mark.asyncio
    async def test_health_check_execution(self, health_manager):
        """Test health check execution."""
        async def healthy_check():
            return True
        
        async def unhealthy_check():
            return False
        
        health_manager.register_health_check("healthy_service", healthy_check)
        health_manager.register_health_check("unhealthy_service", unhealthy_check)
        
        # Test healthy service
        result = await health_manager.perform_health_check("healthy_service")
        assert result.is_healthy == True
        assert result.service_name == "healthy_service"
        
        # Test unhealthy service
        result = await health_manager.perform_health_check("unhealthy_service")
        assert result.is_healthy == False
        assert result.service_name == "unhealthy_service"
    
    def test_default_health_checks_setup(self, health_manager):
        """Test setup of default health checks."""
        health_manager.setup_default_health_checks()
        
        assert "database" in health_manager.health_checks
        assert "chromadb" in health_manager.health_checks
        assert "models" in health_manager.health_checks
    
    def test_health_report(self, health_manager):
        """Test health report generation."""
        report = health_manager.get_health_report()
        
        assert "health_config" in report
        assert "registered_services" in report
        assert "service_states" in report
        assert "recent_checks" in report
        assert "total_checks_performed" in report
        assert "uptime" in report


class TestSecurityManager:
    """Test security manager."""
    
    def test_manager_initialization(self, security_manager):
        """Test manager initialization."""
        assert hasattr(security_manager, "_initialized")
    
    def test_dockerfile_security_validation(self, security_manager, temp_dir, sample_dockerfile_content):
        """Test Dockerfile security validation."""
        dockerfile_path = temp_dir / "Dockerfile"
        dockerfile_path.write_text(sample_dockerfile_content)
        
        result = security_manager.validate_dockerfile_security(str(dockerfile_path))
        
        assert "valid" in result
        assert "violations" in result
        assert "total_violations" in result
    
    def test_insecure_dockerfile_detection(self, security_manager, temp_dir):
        """Test detection of insecure Dockerfile practices."""
        insecure_dockerfile = """FROM python:latest
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 8000
CMD ["python", "app.py"]
"""
        dockerfile_path = temp_dir / "Dockerfile"
        dockerfile_path.write_text(insecure_dockerfile)
        
        result = security_manager.validate_dockerfile_security(str(dockerfile_path))
        
        assert result["valid"] == False
        assert result["total_violations"] > 0
        
        # Should detect non-root user violation and latest tag usage
        violation_types = [v["type"] for v in result["violations"]]
        assert "non_root_user" in violation_types
        assert "latest_tag" in violation_types
    
    def test_secure_dockerfile_config_generation(self, security_manager):
        """Test secure Dockerfile configuration generation."""
        config = security_manager.generate_secure_dockerfile_config()
        
        assert "base_image" in config
        assert "non_root_user" in config
        assert "read_only_filesystem" in config
        assert "security_options" in config
        assert "health_check" in config
        
        assert config["non_root_user"]["enabled"] == True
        assert "--no-new-privileges" in config["security_options"]
    
    def test_docker_compose_security_config(self, security_manager):
        """Test Docker Compose security configuration generation."""
        config = security_manager.generate_docker_compose_security_config()
        
        assert "user" in config
        assert "security_opt" in config
        assert "cap_drop" in config
        assert "cap_add" in config
        
        assert "no-new-privileges:true" in config["security_opt"]
        assert "ALL" in config["cap_drop"]
    
    def test_secrets_management_validation(self, security_manager, temp_dir):
        """Test secrets management validation."""
        config_with_secrets = """
database_password = "super_secret_password"
api_key = "sk-1234567890abcdef"
secret_token = "very_secret_token_here"
"""
        config_file = temp_dir / "config.py"
        config_file.write_text(config_with_secrets)
        
        result = security_manager.validate_secrets_management([str(config_file)])
        
        assert result["secrets_management_valid"] == False
        assert result["total_violations"] > 0
        
        # Should detect hardcoded secrets
        violation_types = [v["type"] for v in result["violations"]]
        assert all(vtype == "hardcoded_secret" for vtype in violation_types)
    
    def test_security_report(self, security_manager):
        """Test security report generation."""
        report = security_manager.get_security_report()
        
        assert "security_config" in report
        assert "vulnerability_database" in report
        assert "security_violations" in report
        assert "security_recommendations" in report