"""
Unit tests for build reproducibility validation system.
Tests task 3.4: Implement build reproducibility validation.
"""

import pytest
import tempfile
import os
from pathlib import Path
from unittest.mock import patch, MagicMock
import sys

# Add the backend directory to Python path
backend_dir = Path(__file__).parent.parent.parent
sys.path.insert(0, str(backend_dir))

from infrastructure.managers.dependency_manager import DependencyManager


class TestBuildReproducibility:
    """Test cases for build reproducibility validation system."""
    
    def setup_method(self):
        """Set up test fixtures."""
        self.dep_manager = DependencyManager()
        self.dep_manager.initialize()
    
    def test_build_reproducibility_with_exact_versions(self):
        """Test build reproducibility validation with exact versions."""
        # Create requirements with exact versions
        exact_requirements = """fastapi==0.104.1
starlette==0.27.0
pydantic==2.5.0
uvicorn==0.24.0
"""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write(exact_requirements)
            temp_file = f.name
        
        try:
            # Test build reproducibility
            result = self.dep_manager.validate_build_reproducibility(temp_file, test_iterations=2)
            assert result is True
        finally:
            os.unlink(temp_file)
    
    def test_build_reproducibility_with_inexact_versions(self):
        """Test build reproducibility validation fails with inexact versions."""
        # Create requirements with inexact versions
        inexact_requirements = """fastapi>=0.104.1
starlette~=0.27.0
pydantic
uvicorn==0.24.0
"""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write(inexact_requirements)
            temp_file = f.name
        
        try:
            # Test build reproducibility should fail due to inexact versions
            result = self.dep_manager.validate_build_reproducibility(temp_file, test_iterations=2)
            assert result is False
        finally:
            os.unlink(temp_file)
    
    @patch('subprocess.run')
    def test_build_hash_creation_success(self, mock_run):
        """Test successful build hash creation."""
        # Mock consistent pip freeze output
        mock_run.return_value.stdout = "fastapi==0.104.1\nstarlette==0.27.0\npydantic==2.5.0\n"
        mock_run.return_value.returncode = 0
        
        build_hash = self.dep_manager._create_build_hash("requirements.txt")
        
        assert build_hash is not None
        assert len(build_hash) == 64  # SHA256 hash length
        assert isinstance(build_hash, str)
    
    @patch('subprocess.run')
    def test_build_hash_creation_failure(self, mock_run):
        """Test build hash creation handles subprocess failures."""
        # Mock subprocess failure
        mock_run.side_effect = Exception("pip freeze failed")
        
        build_hash = self.dep_manager._create_build_hash("requirements.txt")
        
        assert build_hash is None
    
    @patch('subprocess.run')
    def test_build_reproducibility_consistent_hashes(self, mock_run):
        """Test that identical environments produce identical build hashes."""
        # Mock consistent pip freeze output across multiple calls
        consistent_output = "fastapi==0.104.1\nstarlette==0.27.0\npydantic==2.5.0\n"
        mock_run.return_value.stdout = consistent_output
        mock_run.return_value.returncode = 0
        
        # Create requirements file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("fastapi==0.104.1\nstarlette==0.27.0\npydantic==2.5.0\n")
            temp_file = f.name
        
        try:
            # Test multiple iterations should produce same result
            result = self.dep_manager.validate_build_reproducibility(temp_file, test_iterations=3)
            assert result is True
            
            # Verify pip freeze was called multiple times
            assert mock_run.call_count >= 3
        finally:
            os.unlink(temp_file)
    
    @patch('subprocess.run')
    def test_build_reproducibility_inconsistent_hashes(self, mock_run):
        """Test that different environments produce different build hashes and fail validation."""
        # Mock inconsistent pip freeze output across calls
        outputs = [
            "fastapi==0.104.1\nstarlette==0.27.0\npydantic==2.5.0\n",
            "fastapi==0.104.1\nstarlette==0.27.0\npydantic==2.5.1\n",  # Different version
            "fastapi==0.104.1\nstarlette==0.27.0\npydantic==2.5.0\n"
        ]
        
        mock_run.side_effect = [
            MagicMock(stdout=output, returncode=0) for output in outputs
        ]
        
        # Create requirements file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("fastapi==0.104.1\nstarlette==0.27.0\npydantic==2.5.0\n")
            temp_file = f.name
        
        try:
            # Test should fail due to inconsistent hashes
            result = self.dep_manager.validate_build_reproducibility(temp_file, test_iterations=3)
            assert result is False
        finally:
            os.unlink(temp_file)
    
    def test_dependency_tree_validation_structure(self):
        """Test dependency tree validation returns proper structure."""
        # Create simple requirements file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write("fastapi==0.104.1\npydantic==2.5.0\n")
            temp_file = f.name
        
        try:
            tree_analysis = self.dep_manager.create_dependency_tree_validation(temp_file)
            
            # Should return a dictionary with expected keys
            assert isinstance(tree_analysis, dict)
            
            if "error" not in tree_analysis:
                # If pipdeptree is available, check structure
                assert "total_packages" in tree_analysis
                assert "direct_dependencies" in tree_analysis
                assert "transitive_dependencies" in tree_analysis
                assert "potential_conflicts" in tree_analysis
                
                assert isinstance(tree_analysis["direct_dependencies"], list)
                assert isinstance(tree_analysis["transitive_dependencies"], list)
                assert isinstance(tree_analysis["potential_conflicts"], list)
            else:
                # If pipdeptree is not available, should have error message
                assert isinstance(tree_analysis["error"], str)
        finally:
            os.unlink(temp_file)
    
    def test_build_reproducibility_missing_file(self):
        """Test build reproducibility validation with missing requirements file."""
        result = self.dep_manager.validate_build_reproducibility("nonexistent.txt")
        assert result is False
    
    def test_build_reproducibility_integration(self):
        """Integration test for complete build reproducibility validation."""
        # Use actual requirements.txt if it exists
        req_file = Path("requirements.txt")
        
        if req_file.exists():
            # Test with actual file
            result = self.dep_manager.validate_build_reproducibility(str(req_file), test_iterations=2)
            # Should pass if requirements.txt has exact versions
            assert isinstance(result, bool)
        else:
            # Skip if no requirements.txt
            pytest.skip("No requirements.txt file found for integration test")
    
    def test_build_artifact_comparison_concept(self):
        """Test the concept of build artifact comparison for reproducibility."""
        # This tests the core concept that identical inputs should produce identical outputs
        
        # Create two identical requirements files
        requirements_content = "fastapi==0.104.1\nstarlette==0.27.0\n"
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f1:
            f1.write(requirements_content)
            temp_file1 = f1.name
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f2:
            f2.write(requirements_content)
            temp_file2 = f2.name
        
        try:
            # Both files should have identical validation results
            result1 = self.dep_manager.validate_exact_versions(temp_file1)
            result2 = self.dep_manager.validate_exact_versions(temp_file2)
            
            assert result1 == result2
            assert result1 is True  # Both should pass exact version validation
            
            # Parse both files - should produce identical results
            parsed1 = self.dep_manager.parse_requirements(temp_file1)
            parsed2 = self.dep_manager.parse_requirements(temp_file2)
            
            assert len(parsed1) == len(parsed2)
            for req1, req2 in zip(parsed1, parsed2):
                assert req1['name'] == req2['name']
                assert req1['operator'] == req2['operator']
                assert req1['version'] == req2['version']
        
        finally:
            os.unlink(temp_file1)
            os.unlink(temp_file2)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])