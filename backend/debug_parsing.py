#!/usr/bin/env python3
"""Debug script for dependency parsing."""

import sys
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from infrastructure.managers.dependency_manager import DependencyManager


def debug_parsing():
    """Debug the dependency parsing."""
    dep_manager = DependencyManager()
    dep_manager.initialize()
    
    print("Debugging dependency parsing...")
    print("=" * 50)
    
    parsed_reqs = dep_manager.parse_requirements()
    
    print(f"Total parsed requirements: {len(parsed_reqs)}")
    print()
    
    for i, req in enumerate(parsed_reqs[:10]):  # Show first 10
        print(f"{i+1}. Original: '{req['original_line']}'")
        print(f"   Name: '{req['name']}'")
        print(f"   Extras: '{req['extras']}'")
        print(f"   Operator: '{req['operator']}'")
        print(f"   Version: '{req['version']}'")
        print()


if __name__ == "__main__":
    debug_parsing()