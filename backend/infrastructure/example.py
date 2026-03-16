#!/usr/bin/env python3
"""
Example usage of the infrastructure optimization system.

This script demonstrates how to use the infrastructure components
for the University QA System optimization.
"""

import asyncio
import logging
from pathlib import Path

from . import (
    InfrastructureConfig,
    InfrastructureOrchestrator,
    initialize_infrastructure
)

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


async def main():
    """Main example function."""
    logger.info("Starting infrastructure optimization example")
    
    # 1. Create custom infrastructure configuration
    config = InfrastructureConfig(
        python_version="3.12",
        resource_limits={
            "cpu_limit": "2.0",
            "memory_limit": "4G",
            "cpu_reservation": "1.0", 
            "memory_reservation": "2G"
        },
        health_check={
            "interval": 30,
            "timeout": 10,
            "retries": 3,
            "start_period": 60
        },
        cache={
            "pip_cache_enabled": True,
            "docker_cache_enabled": True,
            "model_cache_enabled": True,
            "cache_ttl": 3600
        },
        security={
            "run_as_non_root": True,
            "vulnerability_scanning": True,
            "secrets_management": True
        }
    )
    
    # 2. Initialize infrastructure orchestrator
    logger.info("Initializing infrastructure orchestrator")
    orchestrator = initialize_infrastructure(config, ".")
    
    # 3. Validate all components
    logger.info("Validating infrastructure components")
    validation_results = orchestrator.validate_all()
    
    for component, is_valid in validation_results.items():
        status = "✓ VALID" if is_valid else "✗ INVALID"
        logger.info(f"  {component}: {status}")
    
    # 4. Get comprehensive report
    logger.info("Generating comprehensive infrastructure report")
    report = orchestrator.get_comprehensive_report()
    
    logger.info("Infrastructure Report Summary:")
    logger.info(f"  Python Version: {report['infrastructure_config']['python_version']}")
    logger.info(f"  Environment: {report['infrastructure_config']['environment']}")
    logger.info(f"  All Components Valid: {report['system_status']['all_components_valid']}")
    
    # 5. Set up development environment
    logger.info("Setting up development environment")
    dev_config = orchestrator.setup_development_environment(".")
    logger.info("Development configuration generated")
    
    # 6. Perform health checks
    logger.info("Performing health checks")
    health_results = await orchestrator.perform_health_checks()
    
    logger.info("Health Check Results:")
    for service, result in health_results["individual_results"].items():
        status = "✓ HEALTHY" if result["healthy"] else "✗ UNHEALTHY"
        response_time = result["response_time"]
        logger.info(f"  {service}: {status} ({response_time:.3f}s)")
    
    overall_healthy = health_results["summary"]["overall_healthy"]
    logger.info(f"Overall System Health: {'✓ HEALTHY' if overall_healthy else '✗ UNHEALTHY'}")
    
    # 7. Demonstrate individual manager usage
    logger.info("Demonstrating individual manager capabilities")
    
    # Version management
    version_report = orchestrator.version_manager.get_version_report()
    logger.info(f"Version consistency: {version_report['is_consistent']}")
    
    # Cache management
    cache_report = orchestrator.cache_manager.get_cache_report()
    total_cache_size = cache_report["total_cache_size"]
    logger.info(f"Total cache size: {total_cache_size} bytes")
    
    # Resource monitoring
    resource_report = orchestrator.resource_manager.get_resource_report()
    cpu_usage = resource_report["current_usage"]["cpu_percent"]
    memory_usage = resource_report["current_usage"]["memory_percent"]
    logger.info(f"Current resource usage: CPU {cpu_usage:.1f}%, Memory {memory_usage:.1f}%")
    
    # 8. Clean up resources
    logger.info("Cleaning up infrastructure resources")
    orchestrator.cleanup_resources()
    
    logger.info("Infrastructure optimization example completed successfully!")


if __name__ == "__main__":
    asyncio.run(main())