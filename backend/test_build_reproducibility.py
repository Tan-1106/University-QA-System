#!/usr/bin/env python3
"""Test script for build reproducibility validation."""

import sys
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from infrastructure.managers.dependency_manager import DependencyManager


def test_build_reproducibility():
    """Test the build reproducibility validation."""
    print("Testing Build Reproducibility Validation")
    print("=" * 50)
    
    dep_manager = DependencyManager()
    dep_manager.initialize()
    
    # Test dependency tree validation
    print("\n1. Testing dependency tree validation...")
    tree_analysis = dep_manager.create_dependency_tree_validation()
    
    if "error" in tree_analysis:
        print(f"   Dependency tree analysis failed: {tree_analysis['error']}")
    else:
        print(f"   Total packages: {tree_analysis['total_packages']}")
        print(f"   Direct dependencies: {len(tree_analysis['direct_dependencies'])}")
        print(f"   Transitive dependencies: {len(tree_analysis['transitive_dependencies'])}")
    
    # Test build hash creation
    print("\n2. Testing build hash creation...")
    build_hash = dep_manager._create_build_hash("requirements.txt")
    if build_hash:
        print(f"   Build hash created: {build_hash[:16]}...")
    else:
        print("   Build hash creation failed")
    
    # Test build reproducibility (simplified version)
    print("\n3. Testing build reproducibility validation...")
    try:
        is_reproducible = dep_manager.validate_build_reproducibility(test_iterations=2)
        print(f"   Build reproducible: {is_reproducible}")
    except Exception as e:
        print(f"   Build reproducibility test failed: {e}")
    
    print("\n" + "=" * 50)
    print("Build reproducibility test completed!")


if __name__ == "__main__":
    test_build_reproducibility()