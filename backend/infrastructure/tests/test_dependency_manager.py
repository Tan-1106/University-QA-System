"""Unit tests for dependency management system."""

import pytest
import tempfile
from pathlib import Path
from unittest.mock import patch, MagicMock
import sys
import os

# Add the backend directory to Python path
backend_dir = Path(__file__).parent.parent.parent
sys.path.insert(0, str(backend_dir))

from infrastructure.managers.dependency_manager import DependencyManager


class TestDependencyManager:
    """Test cases for DependencyManager."""
    
    def setup_method(self):
        """Set up test fixtures."""
        self.dep_manager = DependencyManager()
        self.dep_manager.initialize()
    
    def test_parse_requirements_with_exact_versions(self):
        """Test parsing requirements with exact versions."""
        # Create a temporary requirements file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("""# Test requirements
fastapi==0.104.1
starlette==0.27.0
uvicorn[standard]==0.24.0
# Another comment
pymongo==4.6.0
""")
            temp_file = f.name
        
        try:
            parsed_reqs = self.dep_manager.parse_requirements(temp_file)
            
            assert len(parsed_reqs) == 4
            
            # Check first requirement
            assert parsed_reqs[0]['name'] == 'fastapi'
            assert parsed_reqs[0]['operator'] == '=='
            assert parsed_reqs[0]['version'] == '0.104.1'
            assert parsed_reqs[0]['extras'] == ''
            
            # Check requirement with extras
            uvicorn_req = next(req for req in parsed_reqs if req['name'] == 'uvicorn')
            assert uvicorn_req['extras'] == '[standard]'
            assert uvicorn_req['operator'] == '=='
            assert uvicorn_req['version'] == '0.24.0'
            
        finally:
            os.unlink(temp_file)
    
    def test_parse_requirements_with_inexact_versions(self):
        """Test parsing requirements with inexact versions."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("""fastapi>=0.104.1
starlette~=0.27.0
uvicorn
pymongo==4.6.0
""")
            temp_file = f.name
        
        try:
            parsed_reqs = self.dep_manager.parse_requirements(temp_file)
            
            assert len(parsed_reqs) == 4
            
            # Check different operators
            fastapi_req = next(req for req in parsed_reqs if req['name'] == 'fastapi')
            assert fastapi_req['operator'] == '>='
            
            starlette_req = next(req for req in parsed_reqs if req['name'] == 'starlette')
            assert starlette_req['operator'] == '~='
            
            uvicorn_req = next(req for req in parsed_reqs if req['name'] == 'uvicorn')
            assert uvicorn_req['operator'] == ''  # No version specified
            
        finally:
            os.unlink(temp_file)
    
    def test_validate_exact_versions_success(self):
        """Test exact version validation with all exact versions."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("""fastapi==0.104.1
starlette==0.27.0
pymongo==4.6.0
""")
            temp_file = f.name
        
        try:
            result = self.dep_manager.validate_exact_versions(temp_file)
            assert result is True
        finally:
            os.unlink(temp_file)
    
    def test_validate_exact_versions_failure(self):
        """Test exact version validation with inexact versions."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("""fastapi>=0.104.1
starlette==0.27.0
pymongo
""")
            temp_file = f.name
        
        try:
            result = self.dep_manager.validate_exact_versions(temp_file)
            assert result is False
        finally:
            os.unlink(temp_file)
    
    def test_validate_critical_dependencies(self):
        """Test critical dependencies validation."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("""fastapi==0.104.1
openai==1.3.7
chromadb==0.4.18
sentence-transformers==2.2.2
""")
            temp_file = f.name
        
        try:
            result = self.dep_manager.validate_critical_dependencies(temp_file)
            assert result is True
        finally:
            os.unlink(temp_file)
    
    def test_validate_critical_dependencies_with_inexact(self):
        """Test critical dependencies validation with inexact versions."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("""fastapi>=0.104.1
openai==1.3.7
chromadb==0.4.18
""")
            temp_file = f.name
        
        try:
            result = self.dep_manager.validate_critical_dependencies(temp_file)
            assert result is False
        finally:
            os.unlink(temp_file)
    
    def test_get_critical_dependencies(self):
        """Test getting list of critical dependencies."""
        critical_deps = self.dep_manager.get_critical_dependencies()
        
        assert isinstance(critical_deps, set)
        assert 'fastapi' in critical_deps
        assert 'openai' in critical_deps
        assert 'chromadb' in critical_deps
        assert 'sentence-transformers' in critical_deps
    
    @patch('subprocess.run')
    def test_create_build_hash_success(self, mock_run):
        """Test successful build hash creation."""
        # Mock pip freeze output
        mock_run.return_value.stdout = "fastapi==0.104.1\nstarlette==0.27.0\n"
        mock_run.return_value.returncode = 0
        
        build_hash = self.dep_manager._create_build_hash("requirements.txt")
        
        assert build_hash is not None
        assert len(build_hash) == 64  # SHA256 hash length
        mock_run.assert_called_once()
    
    @patch('subprocess.run')
    def test_create_build_hash_failure(self, mock_run):
        """Test build hash creation failure."""
        # Mock subprocess failure
        mock_run.side_effect = Exception("Command failed")
        
        build_hash = self.dep_manager._create_build_hash("requirements.txt")
        
        assert build_hash is None
    
    def test_validate_lock_file_completeness_missing_file(self):
        """Test lock file validation with missing file."""
        result = self.dep_manager.validate_lock_file_completeness("nonexistent.txt")
        assert result is False
    
    def test_validate_lock_file_completeness_valid_file(self):
        """Test lock file validation with valid file."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("""# This file is autogenerated by pip-compile
fastapi==0.104.1 \\
    --hash=sha256:abc123def456
starlette==0.27.0 \\
    --hash=sha256:def456ghi789
""")
            temp_file = f.name
        
        try:
            result = self.dep_manager.validate_lock_file_completeness(temp_file)
            assert result is True
        finally:
            os.unlink(temp_file)
    
    def test_validate_lock_file_completeness_no_hashes(self):
        """Test lock file validation without hashes."""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("""fastapi==0.104.1
starlette==0.27.0
""")
            temp_file = f.name
        
        try:
            result = self.dep_manager.validate_lock_file_completeness(temp_file)
            assert result is False
        finally:
            os.unlink(temp_file)
    
    def test_get_dependency_report(self):
        """Test comprehensive dependency report generation."""
        # Create a test requirements file to ensure consistent results
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("""fastapi==0.104.1
starlette==0.27.0
pydantic==2.5.0
uvicorn==0.24.0
""")
            temp_file = f.name
        
        try:
            # Override the requirements file for this test
            self.dep_manager.requirements_file = temp_file
            report = self.dep_manager.get_dependency_report()
            
            assert isinstance(report, dict)
            assert 'requirements_file' in report
            assert 'lock_file' in report
            assert 'requirements_exists' in report
            assert 'dependency_count' in report
            assert 'exact_versions_valid' in report
            assert 'critical_dependencies_valid' in report
            
            # Should have found dependencies in the test file
            assert report['dependency_count'] > 0
            assert report['requirements_exists'] is True
        finally:
            os.unlink(temp_file)
    
    @patch('subprocess.run')
    def test_validate_dependency_compatibility_success(self, mock_run):
        """Test successful dependency compatibility validation."""
        mock_run.return_value.returncode = 0
        mock_run.return_value.stdout = ""
        mock_run.return_value.stderr = ""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("fastapi==0.104.1\n")
            temp_file = f.name
        
        try:
            result = self.dep_manager.validate_dependency_compatibility(temp_file)
            assert result is True
        finally:
            os.unlink(temp_file)
    
    @patch('subprocess.run')
    def test_validate_dependency_compatibility_failure(self, mock_run):
        """Test dependency compatibility validation failure."""
        from subprocess import CalledProcessError
        mock_run.side_effect = CalledProcessError(1, 'pip-compile', stderr="Conflict detected")
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("fastapi==0.104.1\n")
            temp_file = f.name
        
        try:
            result = self.dep_manager.validate_dependency_compatibility(temp_file)
            assert result is False
        finally:
            os.unlink(temp_file)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])