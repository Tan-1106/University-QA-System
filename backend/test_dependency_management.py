#!/usr/bin/env python3
"""Test script for dependency management system."""

import sys
import os
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from infrastructure.managers.dependency_manager import DependencyManager


def test_dependency_management():
    """Test the dependency management system."""
    print("Testing Dependency Management System")
    print("=" * 50)
    
    # Initialize dependency manager
    config = {
        "requirements_file": "requirements.txt",
        "lock_file": "requirements-lock.txt"
    }
    
    dep_manager = DependencyManager(config)
    dep_manager.initialize()
    
    # Test 1: Parse requirements
    print("\n1. Testing requirements parsing...")
    parsed_reqs = dep_manager.parse_requirements()
    print(f"   Found {len(parsed_reqs)} dependencies")
    
    # Show first few dependencies
    for i, req in enumerate(parsed_reqs[:5]):
        print(f"   - {req['name']}{req['extras']} {req['operator']} {req['version']}")
    
    # Test 2: Validate exact versions
    print("\n2. Testing exact version validation...")
    exact_valid = dep_manager.validate_exact_versions()
    print(f"   Exact versions valid: {exact_valid}")
    
    # Test 3: Validate critical dependencies
    print("\n3. Testing critical dependencies validation...")
    critical_valid = dep_manager.validate_critical_dependencies()
    print(f"   Critical dependencies valid: {critical_valid}")
    
    # Test 4: Check dependency compatibility
    print("\n4. Testing dependency compatibility...")
    try:
        compat_valid = dep_manager.validate_dependency_compatibility()
        print(f"   Dependency compatibility valid: {compat_valid}")
    except Exception as e:
        print(f"   Dependency compatibility check failed: {e}")
    
    # Test 5: Generate comprehensive report
    print("\n5. Generating dependency report...")
    report = dep_manager.get_dependency_report()
    
    print(f"   Requirements file: {report['requirements_file']}")
    print(f"   Requirements exists: {report['requirements_exists']}")
    print(f"   Lock file exists: {report['lock_file_exists']}")
    print(f"   Dependency count: {report['dependency_count']}")
    print(f"   Exact versions valid: {report['exact_versions_valid']}")
    print(f"   Critical dependencies valid: {report['critical_dependencies_valid']}")
    print(f"   Compatibility valid: {report['compatibility_valid']}")
    
    # Test 6: Try to generate lock file (if pip-tools is available)
    print("\n6. Testing lock file generation...")
    try:
        lock_generated = dep_manager.generate_lock_file()
        print(f"   Lock file generated: {lock_generated}")
        
        if lock_generated:
            lock_valid = dep_manager.validate_lock_file_completeness()
            print(f"   Lock file valid: {lock_valid}")
    except Exception as e:
        print(f"   Lock file generation failed: {e}")
    
    print("\n" + "=" * 50)
    print("Dependency management system test completed!")
    
    return report


if __name__ == "__main__":
    test_dependency_management()