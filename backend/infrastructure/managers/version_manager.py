"""Version consistency management for Python environments."""

import sys
import subprocess
import os
from typing import Dict, List, Optional, Tuple, Any
from pathlib import Path
import re

from .base import BaseInfrastructureManager


class VersionConsistencyManager(BaseInfrastructureManager):
    """Manages Python version consistency across all environments."""
    
    REQUIRED_PYTHON_VERSION = "3.12"
    
    def __init__(self, config: Optional[Dict] = None):
        """Initialize version consistency manager."""
        super().__init__(config)
        self.required_version = self.config.get("python_version", self.REQUIRED_PYTHON_VERSION)
        self.project_root = self.config.get("project_root", ".")
    
    def validate(self) -> bool:
        """Validate Python version consistency across environments."""
        try:
            validations = [
                self.validate_python_version(),
                self.validate_all_docker_files(),
                self.validate_version_files()
            ]
            return all(validations)
        except Exception as e:
            self.logger.error(f"Version validation failed: {e}")
            return False
    
    def initialize(self) -> None:
        """Initialize version consistency checks."""
        self.logger.info("Initializing version consistency manager")
        self.create_version_files(self.project_root)
        self._initialized = True
    
    def validate_python_version(self) -> bool:
        """Validate current Python version matches requirements."""
        current_version = f"{sys.version_info.major}.{sys.version_info.minor}"
        is_valid = current_version == self.required_version
        
        if not is_valid:
            self.logger.warning(
                f"Python version mismatch: expected {self.required_version}, "
                f"got {current_version}"
            )
        
        return is_valid
    
    def check_docker_python_version(self, dockerfile_path: str) -> bool:
        """Validate Python version in Dockerfile."""
        try:
            dockerfile = Path(dockerfile_path)
            if not dockerfile.exists():
                self.logger.warning(f"Dockerfile not found: {dockerfile_path}")
                return False
            
            content = dockerfile.read_text()
            
            # Check for Python version in FROM statements
            python_pattern = rf"FROM\s+python:{re.escape(self.required_version)}(?:-\w+)?"
            matches = re.search(python_pattern, content, re.IGNORECASE)
            
            is_valid = matches is not None
            
            if not is_valid:
                self.logger.warning(
                    f"Dockerfile {dockerfile_path} does not use Python {self.required_version}"
                )
                # Generate detailed warning
                actual_version = self._extract_python_version_from_dockerfile(content)
                warning = self.generate_version_mismatch_warning(
                    self.required_version,
                    actual_version or "unknown",
                    f"Dockerfile {dockerfile_path}"
                )
                self.logger.warning(warning)
            
            return is_valid
            
        except Exception as e:
            self.logger.error(f"Error checking Dockerfile {dockerfile_path}: {e}")
            return False
    
    def validate_all_docker_files(self) -> bool:
        """Validate Python version in all Dockerfiles."""
        docker_files = [
            "backend/Dockerfile.dev",
            "backend/Dockerfile.prod",
            "Dockerfile"
        ]
        
        results = []
        for dockerfile in docker_files:
            if Path(dockerfile).exists():
                result = self.check_docker_python_version(dockerfile)
                results.append(result)
                self.logger.info(f"Docker validation for {dockerfile}: {'PASS' if result else 'FAIL'}")
        
        return all(results) if results else True
    
    def validate_version_files(self) -> bool:
        """Validate version specification files."""
        results = []
        
        # Check .python-version files
        python_version_files = [".python-version", "backend/.python-version"]
        for file_path in python_version_files:
            if Path(file_path).exists():
                result = self._validate_python_version_file(file_path)
                results.append(result)
        
        # Check runtime.txt files
        runtime_files = ["runtime.txt", "backend/runtime.txt"]
        for file_path in runtime_files:
            if Path(file_path).exists():
                result = self._validate_runtime_file(file_path)
                results.append(result)
        
        return all(results) if results else True
    
    def _validate_python_version_file(self, file_path: str) -> bool:
        """Validate .python-version file content."""
        try:
            content = Path(file_path).read_text().strip()
            is_valid = content == self.required_version
            
            if not is_valid:
                warning = self.generate_version_mismatch_warning(
                    self.required_version,
                    content,
                    f".python-version file {file_path}"
                )
                self.logger.warning(warning)
            
            return is_valid
        except Exception as e:
            self.logger.error(f"Error validating {file_path}: {e}")
            return False
    
    def _validate_runtime_file(self, file_path: str) -> bool:
        """Validate runtime.txt file content."""
        try:
            content = Path(file_path).read_text().strip()
            expected = f"python-{self.required_version}"
            is_valid = content == expected
            
            if not is_valid:
                warning = self.generate_version_mismatch_warning(
                    expected,
                    content,
                    f"runtime.txt file {file_path}"
                )
                self.logger.warning(warning)
            
            return is_valid
        except Exception as e:
            self.logger.error(f"Error validating {file_path}: {e}")
            return False
    
    def _extract_python_version_from_dockerfile(self, content: str) -> Optional[str]:
        """Extract Python version from Dockerfile content."""
        pattern = r"FROM\s+python:(\d+\.\d+)(?:-\w+)?"
        match = re.search(pattern, content, re.IGNORECASE)
        return match.group(1) if match else None
    
    def generate_version_mismatch_warning(
        self, 
        expected: str, 
        actual: str, 
        context: str = ""
    ) -> str:
        """Generate detailed warning message for version mismatches."""
        warning = f"⚠️  Python version mismatch detected"
        if context:
            warning += f" in {context}"
        
        warning += f":\n"
        warning += f"  Expected: Python {expected}\n"
        warning += f"  Actual:   Python {actual}\n"
        warning += f"\n🔧 Remediation steps:\n"
        warning += f"  1. Update your Python environment to version {expected}\n"
        warning += f"     - Using pyenv: pyenv install {expected} && pyenv local {expected}\n"
        warning += f"     - Using conda: conda install python={expected}\n"
        warning += f"  2. Update Dockerfile base image to python:{expected}\n"
        warning += f"  3. Update .python-version file: echo '{expected}' > .python-version\n"
        warning += f"  4. Update runtime.txt file: echo 'python-{expected}' > runtime.txt\n"
        warning += f"  5. Rebuild Docker containers after version updates\n"
        
        return warning
    
    def generate_comprehensive_mismatch_report(self) -> Dict[str, Any]:
        """Generate comprehensive report of all version mismatches."""
        report = {
            "timestamp": sys.version_info,
            "required_version": self.required_version,
            "mismatches": [],
            "warnings": [],
            "remediation_required": False
        }
        
        # Check current Python version
        current_version = f"{sys.version_info.major}.{sys.version_info.minor}"
        if current_version != self.required_version:
            mismatch = {
                "context": "current Python environment",
                "expected": self.required_version,
                "actual": current_version,
                "severity": "high"
            }
            report["mismatches"].append(mismatch)
            report["warnings"].append(
                self.generate_version_mismatch_warning(
                    self.required_version,
                    current_version,
                    "current Python environment"
                )
            )
        
        # Check Docker files
        docker_files = ["backend/Dockerfile.dev", "backend/Dockerfile.prod", "Dockerfile"]
        for dockerfile in docker_files:
            if Path(dockerfile).exists():
                content = Path(dockerfile).read_text()
                actual_version = self._extract_python_version_from_dockerfile(content)
                if actual_version and actual_version != self.required_version:
                    mismatch = {
                        "context": f"Dockerfile {dockerfile}",
                        "expected": self.required_version,
                        "actual": actual_version,
                        "severity": "high"
                    }
                    report["mismatches"].append(mismatch)
                    report["warnings"].append(
                        self.generate_version_mismatch_warning(
                            self.required_version,
                            actual_version,
                            f"Dockerfile {dockerfile}"
                        )
                    )
        
        report["remediation_required"] = len(report["mismatches"]) > 0
        return report
    
    def create_version_files(self, project_root: str) -> None:
        """Create version specification files."""
        root_path = Path(project_root)
        
        # Create .python-version for pyenv at root level
        python_version_file = root_path / ".python-version"
        if not python_version_file.exists():
            python_version_file.write_text(self.required_version)
            self.logger.info(f"Created {python_version_file}")
        else:
            self.logger.info(f"File {python_version_file} already exists")
        
        # Create runtime.txt for Heroku-style deployments at root level
        runtime_file = root_path / "runtime.txt"
        if not runtime_file.exists():
            runtime_file.write_text(f"python-{self.required_version}")
            self.logger.info(f"Created {runtime_file}")
        else:
            self.logger.info(f"File {runtime_file} already exists")
    
    def enforce_version_consistency(self) -> bool:
        """Enforce Python version consistency across all environments."""
        self.logger.info("Enforcing Python version consistency...")
        
        # Create version files if they don't exist
        self.create_version_files(self.project_root)
        
        # Validate all environments
        is_consistent = self.validate()
        
        if not is_consistent:
            # Generate comprehensive report
            report = self.generate_comprehensive_mismatch_report()
            
            self.logger.error("Version consistency check failed!")
            for warning in report["warnings"]:
                self.logger.error(warning)
            
            return False
        
        self.logger.info("✅ Python version consistency validated successfully")
        return True
    
    def get_version_report(self) -> Dict[str, Any]:
        """Get comprehensive version consistency report."""
        current_version = f"{sys.version_info.major}.{sys.version_info.minor}"
        
        report = {
            "required_version": self.required_version,
            "current_version": current_version,
            "is_consistent": current_version == self.required_version,
            "python_executable": sys.executable,
            "version_info": {
                "major": sys.version_info.major,
                "minor": sys.version_info.minor,
                "micro": sys.version_info.micro,
                "releaselevel": sys.version_info.releaselevel,
                "serial": sys.version_info.serial
            },
            "environment_checks": {
                "python_version": self.validate_python_version(),
                "docker_files": self.validate_all_docker_files(),
                "version_files": self.validate_version_files()
            }
        }
        
        if not report["is_consistent"]:
            report["warning"] = self.generate_version_mismatch_warning(
                self.required_version, 
                current_version,
                "current environment"
            )
        
        # Add comprehensive mismatch report if there are issues
        if not all(report["environment_checks"].values()):
            report["comprehensive_report"] = self.generate_comprehensive_mismatch_report()
        
        return report
    
    def get_status(self) -> Dict[str, Any]:
        """Get the current status of the version manager."""
        base_status = super().get_status()
        version_report = self.get_version_report()
        
        base_status.update({
            "version_consistency": version_report["is_consistent"],
            "required_version": self.required_version,
            "current_version": version_report["current_version"],
            "all_checks_passed": all(version_report["environment_checks"].values())
        })
        
        return base_status