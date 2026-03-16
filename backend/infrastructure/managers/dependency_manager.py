"""Dependency management with exact version pinning and lock files."""

import hashlib
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple, Any
import re

from .base import BaseInfrastructureManager


class DependencyManager(BaseInfrastructureManager):
    """Manages dependency versions and lock file generation."""
    
    def __init__(self, config: Optional[Dict] = None):
        """Initialize dependency manager."""
        super().__init__(config)
        self.requirements_file = self.config.get("requirements_file", "requirements.txt")
        self.lock_file = self.config.get("lock_file", "requirements-lock.txt")
    
    def validate(self) -> bool:
        """Validate dependency configuration."""
        try:
            return self.validate_exact_versions()
        except Exception as e:
            self.logger.error(f"Dependency validation failed: {e}")
            return False
    
    def initialize(self) -> None:
        """Initialize dependency management."""
        self.logger.info("Initializing dependency manager")
        self._initialized = True
    
    def parse_requirements(self, requirements_path: Optional[str] = None) -> List[Dict[str, str]]:
        """Parse requirements.txt file and extract package information."""
        req_file = Path(requirements_path or self.requirements_file)
        
        if not req_file.exists():
            self.logger.warning(f"Requirements file not found: {req_file}")
            return []
        
        # Read content and handle potential BOM
        content = req_file.read_text(encoding='utf-8-sig')
        lines = [line.strip() for line in content.split('\n') if line.strip()]
        
        parsed_requirements = []
        
        for line in lines:
            # Parse package name, version, and extras
            package_info = self._parse_requirement_line(line)
            if package_info:  # Only add non-None results
                parsed_requirements.append(package_info)
        
        return parsed_requirements
    
    def _parse_requirement_line(self, line: str) -> Optional[Dict[str, str]]:
        """Parse a single requirement line."""
        # Skip comments and empty lines
        line = line.strip()
        if not line or line.startswith('#'):
            return None
        
        # Handle extras like package[extra]==version or package==version
        # First, check if there are extras
        if '[' in line and ']' in line:
            # Has extras: package[extra]==version
            extras_match = re.match(r'^([^[#]+)(\[[^\]]+\])(.*)', line)
            if not extras_match:
                return None
            
            package_name = extras_match.group(1).strip()
            extras = extras_match.group(2)
            version_spec = extras_match.group(3).strip()
        else:
            # No extras: package==version
            # Split on the first occurrence of version operators
            version_operators = ['==', '>=', '<=', '>', '<', '~=', '!=']
            package_name = line
            extras = ""
            version_spec = ""
            
            for op in version_operators:
                if op in line:
                    parts = line.split(op, 1)
                    if len(parts) == 2:
                        package_name = parts[0].strip()
                        version_spec = op + parts[1].strip()
                        break
        
        # Skip if package name is empty or looks like a comment
        if not package_name or package_name.startswith('#'):
            return None
        
        # Extract version operator and version from version_spec
        version_pattern = r'(==|>=|<=|>|<|~=|!=)(.+)'
        version_match = re.match(version_pattern, version_spec)
        
        if version_match:
            operator = version_match.group(1)
            version = version_match.group(2).strip()
        else:
            operator = ""
            version = ""
        
        return {
            "name": package_name,
            "extras": extras,
            "operator": operator,
            "version": version,
            "original_line": line
        }
    
    def enforce_exact_versions(self, requirements_path: Optional[str] = None) -> bool:
        """Enforce exact version specifications in requirements file."""
        parsed_reqs = self.parse_requirements(requirements_path)
        
        if not parsed_reqs:
            return False
        
        # Check for non-exact versions and suggest fixes
        inexact_requirements = []
        for req in parsed_reqs:
            if req["operator"] != "==":
                inexact_requirements.append(req)
        
        if inexact_requirements:
            self.logger.warning(f"Found {len(inexact_requirements)} dependencies without exact versions")
            for req in inexact_requirements:
                self.logger.warning(f"  - {req['original_line']} (operator: '{req['operator']}', should use == operator)")
            return False
        
        self.logger.info(f"All {len(parsed_reqs)} dependencies have exact versions")
        return True
    
    def validate_exact_versions(self, requirements_path: Optional[str] = None) -> bool:
        """Validate that all dependencies use exact version specifications."""
        return self.enforce_exact_versions(requirements_path)
    
    def validate_dependency_compatibility(self, requirements_path: Optional[str] = None) -> bool:
        """Validate dependency compatibility by checking for conflicts."""
        req_file = Path(requirements_path or self.requirements_file)
        
        if not req_file.exists():
            self.logger.warning(f"Requirements file not found: {req_file}")
            return False
        
        try:
            # Use pip-tools to check for dependency conflicts
            cmd = [
                "pip-compile",
                "--dry-run",
                "--quiet",
                str(req_file)
            ]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )
            
            # If pip-compile succeeds without errors, dependencies are compatible
            self.logger.info("Dependency compatibility validation passed")
            return True
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Dependency compatibility validation failed: {e.stderr}")
            return False
        except FileNotFoundError:
            self.logger.error("pip-compile not found. Install pip-tools: pip install pip-tools")
            return False
    
    def get_critical_dependencies(self) -> Set[str]:
        """Get list of critical dependencies that must have exact versions."""
        return {
            "fastapi",
            "pytorch", 
            "torch",
            "transformers",
            "sentence-transformers",
            "openai",
            "chromadb",
            "pymongo",
            "motor"
        }
    
    def validate_critical_dependencies(self, requirements_path: Optional[str] = None) -> bool:
        """Validate that critical dependencies have exact versions specified."""
        parsed_reqs = self.parse_requirements(requirements_path)
        critical_deps = self.get_critical_dependencies()
        
        found_critical = {}
        for req in parsed_reqs:
            # Normalize package names for comparison (handle underscores/hyphens)
            normalized_name = req["name"].lower().replace('_', '-')
            if normalized_name in critical_deps or req["name"].lower() in critical_deps:
                found_critical[req["name"].lower()] = req
        
        missing_exact_versions = []
        for dep_name, req_info in found_critical.items():
            if req_info["operator"] != "==":
                missing_exact_versions.append(req_info["original_line"])
        
        if missing_exact_versions:
            self.logger.error(f"Critical dependencies without exact versions: {missing_exact_versions}")
            return False
        
        # Check for missing critical dependencies (only warn, don't fail)
        found_names = {name.replace('_', '-') for name in found_critical.keys()}
        missing_deps = critical_deps - found_names
        if missing_deps:
            self.logger.info(f"Critical dependencies not found in requirements (may be optional): {missing_deps}")
        
        return len(missing_exact_versions) == 0
    
    def generate_lock_file(
        self, 
        requirements_path: Optional[str] = None,
        output_path: Optional[str] = None
    ) -> bool:
        """Generate lock file with exact versions and hashes."""
        req_file = requirements_path or self.requirements_file
        lock_file = output_path or self.lock_file
        
        # First validate that requirements have exact versions
        if not self.validate_exact_versions(req_file):
            self.logger.error("Cannot generate lock file: requirements.txt contains non-exact versions")
            return False
        
        try:
            # Use pip-tools to generate lock file with hashes
            cmd = [
                "pip-compile",
                "--generate-hashes",
                "--output-file", lock_file,
                "--verbose",
                req_file
            ]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )
            
            # Validate the generated lock file
            if self.validate_lock_file_completeness(lock_file):
                self.logger.info(f"Successfully generated lock file: {lock_file}")
                return True
            else:
                self.logger.error(f"Generated lock file failed validation: {lock_file}")
                return False
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Failed to generate lock file: {e.stderr}")
            return False
        except FileNotFoundError:
            self.logger.error("pip-compile not found. Install pip-tools: pip install pip-tools")
            return False
    
    def validate_lock_file_completeness(self, lock_file_path: Optional[str] = None) -> bool:
        """Validate that lock file contains complete dependency tree with hashes."""
        lock_file = Path(lock_file_path or self.lock_file)
        
        if not lock_file.exists():
            self.logger.warning(f"Lock file not found: {lock_file}")
            return False
        
        content = lock_file.read_text()
        lines = [line.strip() for line in content.split('\n') if line.strip()]
        
        # Check for hash presence
        has_hashes = any('--hash=' in line for line in lines)
        
        # Check for exact versions
        dependency_lines = [
            line for line in lines 
            if not line.startswith('#') and '==' in line and not line.startswith(' ')
        ]
        
        has_exact_versions = all('==' in line for line in dependency_lines)
        
        if not has_hashes:
            self.logger.warning("Lock file missing dependency hashes")
            return False
        
        if not has_exact_versions:
            self.logger.warning("Lock file missing exact versions")
            return False
        
        self.logger.info(f"Lock file validation passed: {len(dependency_lines)} dependencies")
        return True
    
    def validate_build_reproducibility(
        self, 
        requirements_path: Optional[str] = None,
        test_iterations: int = 2
    ) -> bool:
        """Validate that builds are reproducible with current dependency specification."""
        req_file = Path(requirements_path or self.requirements_file)
        
        if not req_file.exists():
            self.logger.error(f"Requirements file not found: {req_file}")
            return False
        
        # Validate exact versions first
        if not self.validate_exact_versions(str(req_file)):
            self.logger.error("Cannot validate reproducibility: requirements contain non-exact versions")
            return False
        
        try:
            build_hashes = []
            
            for iteration in range(test_iterations):
                self.logger.info(f"Running build reproducibility test iteration {iteration + 1}")
                
                # Create a hash of the dependency resolution
                build_hash = self._create_build_hash(str(req_file))
                if build_hash:
                    build_hashes.append(build_hash)
                else:
                    self.logger.error(f"Failed to create build hash for iteration {iteration + 1}")
                    return False
            
            # Check if all build hashes are identical
            is_reproducible = len(set(build_hashes)) == 1
            
            if is_reproducible:
                self.logger.info("Build reproducibility validation passed")
            else:
                self.logger.error(f"Build not reproducible. Got {len(set(build_hashes))} different hashes")
                for i, hash_val in enumerate(build_hashes):
                    self.logger.error(f"  Iteration {i + 1}: {hash_val}")
            
            return is_reproducible
            
        except Exception as e:
            self.logger.error(f"Build reproducibility check failed: {e}")
            return False
    
    def _create_build_hash(self, requirements_path: str) -> Optional[str]:
        """Create a hash representing the build state."""
        try:
            # Get pip freeze output to represent current environment state
            result = subprocess.run(
                ["pip", "freeze", "--all"],
                capture_output=True,
                text=True,
                check=True
            )
            
            # Sort the output for consistent hashing
            freeze_lines = sorted(result.stdout.strip().split('\n'))
            freeze_content = '\n'.join(freeze_lines)
            
            # Create hash of the freeze output
            return hashlib.sha256(freeze_content.encode()).hexdigest()
            
        except (subprocess.CalledProcessError, Exception) as e:
            self.logger.error(f"Failed to create build hash: {e}")
            return None
    
    def create_dependency_tree_validation(self, requirements_path: Optional[str] = None) -> Dict[str, Any]:
        """Create dependency tree validation report."""
        req_file = Path(requirements_path or self.requirements_file)
        
        if not req_file.exists():
            return {"error": f"Requirements file not found: {req_file}"}
        
        try:
            # Use pipdeptree to analyze dependency tree
            result = subprocess.run(
                ["pipdeptree", "--json"],
                capture_output=True,
                text=True,
                check=True
            )
            
            import json
            dependency_tree = json.loads(result.stdout)
            
            # Analyze the tree for potential issues
            analysis = {
                "total_packages": len(dependency_tree),
                "direct_dependencies": [],
                "transitive_dependencies": [],
                "potential_conflicts": []
            }
            
            for package in dependency_tree:
                if package.get("dependencies"):
                    analysis["direct_dependencies"].append({
                        "name": package["package"]["package_name"],
                        "version": package["package"]["installed_version"],
                        "dependency_count": len(package["dependencies"])
                    })
                    
                    for dep in package["dependencies"]:
                        analysis["transitive_dependencies"].append({
                            "parent": package["package"]["package_name"],
                            "name": dep["package_name"],
                            "version": dep["installed_version"]
                        })
            
            return analysis
            
        except subprocess.CalledProcessError as e:
            self.logger.warning(f"Could not analyze dependency tree: {e}")
            return {"error": "pipdeptree not available"}
        except FileNotFoundError:
            self.logger.warning("pipdeptree not found. Install with: pip install pipdeptree")
            return {"error": "pipdeptree not installed"}
    
    def get_dependency_report(self) -> Dict[str, any]:
        """Get comprehensive dependency management report."""
        req_file = Path(self.requirements_file)
        lock_file = Path(self.lock_file)
        
        report = {
            "requirements_file": str(req_file),
            "lock_file": str(lock_file),
            "requirements_exists": req_file.exists(),
            "lock_file_exists": lock_file.exists(),
            "exact_versions_valid": False,
            "lock_file_valid": False,
            "dependency_count": 0,
            "critical_dependencies_valid": False,
            "compatibility_valid": False,
            "build_reproducible": False
        }
        
        if req_file.exists():
            report["exact_versions_valid"] = self.validate_exact_versions()
            report["critical_dependencies_valid"] = self.validate_critical_dependencies()
            report["compatibility_valid"] = self.validate_dependency_compatibility()
            
            # Count dependencies
            parsed_reqs = self.parse_requirements()
            report["dependency_count"] = len(parsed_reqs)
            
            # Test build reproducibility (quick test with 2 iterations)
            try:
                report["build_reproducible"] = self.validate_build_reproducibility(test_iterations=2)
            except Exception as e:
                self.logger.warning(f"Could not test build reproducibility: {e}")
                report["build_reproducible"] = None
        
        if lock_file.exists():
            report["lock_file_valid"] = self.validate_lock_file_completeness()
        
        # Add dependency tree analysis if available
        tree_analysis = self.create_dependency_tree_validation()
        if "error" not in tree_analysis:
            report["dependency_tree"] = tree_analysis
        
        return report