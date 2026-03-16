"""Tests for infrastructure orchestrator."""

import pytest
from pathlib import Path

from ..orchestrator import InfrastructureOrchestrator, get_infrastructure, initialize_infrastructure
from ..config.base import InfrastructureConfig


class TestInfrastructureOrchestrator:
    """Test infrastructure orchestrator."""
    
    def test_orchestrator_initialization(self, temp_dir, sample_requirements_content):
        """Test orchestrator initialization."""
        # Create requirements file
        requirements_file = temp_dir / "requirements.txt"
        requirements_file.write_text(sample_requirements_content)
        
        # Initialize orchestrator
        orchestrator = InfrastructureOrchestrator()
        orchestrator.initialize(str(temp_dir))
        
        assert orchestrator._initialized == True
        assert orchestrator.version_manager is not None
        assert orchestrator.dependency_manager is not None
        assert orchestrator.resource_manager is not None
        assert orchestrator.cache_manager is not None
        assert orchestrator.health_manager is not None
        assert orchestrator.security_manager is not None
    
    def test_validation_all(self, temp_dir, sample_requirements_content):
        """Test validation of all components."""
        # Create requirements file
        requirements_file = temp_dir / "requirements.txt"
        requirements_file.write_text(sample_requirements_content)
        
        # Initialize and validate
        orchestrator = InfrastructureOrchestrator()
        orchestrator.initialize(str(temp_dir))
        
        validation_results = orchestrator.validate_all()
        
        assert isinstance(validation_results, dict)
        assert "version_manager" in validation_results
        assert "dependency_manager" in validation_results
        assert "resource_manager" in validation_results
        assert "cache_manager" in validation_results
        assert "health_manager" in validation_results
        assert "security_manager" in validation_results
        
        # Most should be valid (version manager might fail due to Python version mismatch)
        valid_count = sum(validation_results.values())
        assert valid_count >= 5  # At least 5 out of 6 should be valid
    
    def test_comprehensive_report(self, temp_dir, sample_requirements_content):
        """Test comprehensive infrastructure report."""
        # Create requirements file
        requirements_file = temp_dir / "requirements.txt"
        requirements_file.write_text(sample_requirements_content)
        
        # Initialize orchestrator
        orchestrator = InfrastructureOrchestrator()
        orchestrator.initialize(str(temp_dir))
        
        report = orchestrator.get_comprehensive_report()
        
        assert "infrastructure_config" in report
        assert "validation_status" in report
        assert "component_reports" in report
        assert "system_status" in report
        
        # Check component reports
        component_reports = report["component_reports"]
        assert "version" in component_reports
        assert "dependencies" in component_reports
        assert "resources" in component_reports
        assert "cache" in component_reports
        assert "health" in component_reports
        assert "security" in component_reports
        
        # Check system status
        system_status = report["system_status"]
        assert system_status["initialized"] == True
    
    def test_development_environment_setup(self, temp_dir, sample_requirements_content):
        """Test development environment setup."""
        # Create requirements file
        requirements_file = temp_dir / "requirements.txt"
        requirements_file.write_text(sample_requirements_content)
        
        # Initialize orchestrator
        orchestrator = InfrastructureOrchestrator()
        orchestrator.initialize(str(temp_dir))
        
        dev_config = orchestrator.setup_development_environment(str(temp_dir))
        
        assert isinstance(dev_config, dict)
        assert "environment" in dev_config
        assert "volumes" in dev_config
        assert "ENVIRONMENT=development" in dev_config["environment"]
        
        # Check that version files were created
        python_version_file = temp_dir / ".python-version"
        runtime_file = temp_dir / "runtime.txt"
        assert python_version_file.exists()
        assert runtime_file.exists()
    
    def test_production_environment_setup(self, temp_dir, sample_requirements_content, sample_dockerfile_content):
        """Test production environment setup."""
        # Create requirements file and Dockerfile
        requirements_file = temp_dir / "requirements.txt"
        requirements_file.write_text(sample_requirements_content)
        
        dockerfile = temp_dir / "Dockerfile"
        dockerfile.write_text(sample_dockerfile_content)
        
        # Initialize orchestrator
        orchestrator = InfrastructureOrchestrator()
        orchestrator.initialize(str(temp_dir))
        
        prod_config = orchestrator.setup_production_environment(str(temp_dir))
        
        assert isinstance(prod_config, dict)
        assert "environment" in prod_config
        assert "restart" in prod_config
        assert "logging" in prod_config
        assert "ENVIRONMENT=production" in prod_config["environment"]
        assert prod_config["restart"] == "unless-stopped"
    
    @pytest.mark.asyncio
    async def test_health_checks(self, temp_dir, sample_requirements_content):
        """Test comprehensive health checks."""
        # Create requirements file
        requirements_file = temp_dir / "requirements.txt"
        requirements_file.write_text(sample_requirements_content)
        
        # Initialize orchestrator
        orchestrator = InfrastructureOrchestrator()
        orchestrator.initialize(str(temp_dir))
        
        health_results = await orchestrator.perform_health_checks()
        
        assert "individual_results" in health_results
        assert "summary" in health_results
        
        # Check that default health checks are present
        individual_results = health_results["individual_results"]
        assert "database" in individual_results
        assert "chromadb" in individual_results
        assert "models" in individual_results
        
        # Check summary structure
        summary = health_results["summary"]
        assert "timestamp" in summary
        assert "uptime" in summary
        assert "services" in summary
        assert "overall_healthy" in summary
    
    def test_cleanup_resources(self, temp_dir, sample_requirements_content):
        """Test resource cleanup."""
        # Create requirements file
        requirements_file = temp_dir / "requirements.txt"
        requirements_file.write_text(sample_requirements_content)
        
        # Initialize orchestrator
        orchestrator = InfrastructureOrchestrator()
        orchestrator.initialize(str(temp_dir))
        
        # Should not raise any exceptions
        orchestrator.cleanup_resources()
        
        # Resource monitoring should be disabled
        assert orchestrator.resource_manager.monitoring_enabled == False
    
    def test_global_infrastructure_functions(self):
        """Test global infrastructure functions."""
        # Test get_infrastructure
        infra1 = get_infrastructure()
        infra2 = get_infrastructure()
        
        # Should return the same instance
        assert infra1 is infra2
        
        # Test initialize_infrastructure
        config = InfrastructureConfig(python_version="3.12")
        infra3 = initialize_infrastructure(config, ".")
        
        assert infra3._initialized == True
        assert infra3.config.python_version == "3.12"