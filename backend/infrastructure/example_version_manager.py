#!/usr/bin/env python3
"""
Example usage of the Version Consistency Manager.

This script demonstrates the key functionality of the VersionConsistencyManager
including Python version validation, Docker checking, and warning generation.
"""

import sys
import json
from pathlib import Path

# Add the backend directory to the Python path
sys.path.insert(0, str(Path(__file__).parent.parent))

from infrastructure.managers.version_manager import VersionConsistencyManager


def main():
    """Demonstrate Version Consistency Manager functionality."""
    print("🔍 Version Consistency Manager Demo")
    print("=" * 50)
    
    # Initialize the manager
    manager = VersionConsistencyManager({
        "python_version": "3.12",
        "project_root": "."
    })
    manager.initialize()
    
    print("\n1. 📊 Version Report:")
    print("-" * 30)
    report = manager.get_version_report()
    
    print(f"Required Version: {report['required_version']}")
    print(f"Current Version:  {report['current_version']}")
    print(f"Is Consistent:    {report['is_consistent']}")
    print(f"Python Executable: {report['python_executable']}")
    
    print("\n2. 🔍 Environment Checks:")
    print("-" * 30)
    env_checks = report['environment_checks']
    for check_name, result in env_checks.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{check_name.replace('_', ' ').title()}: {status}")
    
    print("\n3. 🐳 Docker File Validation:")
    print("-" * 30)
    docker_files = ["backend/Dockerfile.dev", "backend/Dockerfile.prod", "Dockerfile"]
    for dockerfile in docker_files:
        if Path(dockerfile).exists():
            result = manager.check_docker_python_version(dockerfile)
            status = "✅ PASS" if result else "❌ FAIL"
            print(f"{dockerfile}: {status}")
        else:
            print(f"{dockerfile}: 📄 Not found")
    
    print("\n4. 📋 Configuration Files:")
    print("-" * 30)
    version_files = [".python-version", "runtime.txt", "backend/.python-version", "backend/runtime.txt"]
    for file_path in version_files:
        if Path(file_path).exists():
            content = Path(file_path).read_text().strip()
            print(f"{file_path}: {content}")
        else:
            print(f"{file_path}: 📄 Not found")
    
    print("\n5. ⚠️  Version Mismatch Warnings:")
    print("-" * 30)
    if 'warning' in report:
        print(report['warning'])
    else:
        print("✅ No version mismatches detected!")
    
    print("\n6. 🔧 Comprehensive Validation:")
    print("-" * 30)
    validation_result = manager.validate()
    if validation_result:
        print("✅ All version consistency checks passed!")
    else:
        print("❌ Version consistency issues detected.")
        print("   Run manager.enforce_version_consistency() to see detailed remediation steps.")
    
    print("\n7. 📈 Manager Status:")
    print("-" * 30)
    status = manager.get_status()
    print(f"Manager: {status['manager']}")
    print(f"Initialized: {status['initialized']}")
    print(f"All Checks Passed: {status['all_checks_passed']}")
    
    print("\n" + "=" * 50)
    print("Demo completed! 🎉")


if __name__ == "__main__":
    main()