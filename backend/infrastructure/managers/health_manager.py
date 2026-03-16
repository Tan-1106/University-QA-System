"""Health check management with tiered intervals."""

import asyncio
import time
from typing import Dict, List, Optional, Any, Callable, Awaitable
from enum import Enum
from dataclasses import dataclass
from datetime import datetime

from .base import BaseInfrastructureManager
from ..config.base import HealthCheckConfig


class ServiceState(Enum):
    """Service health states."""
    STARTING = "starting"
    RUNNING = "running"
    FAILING = "failing"
    STOPPED = "stopped"


@dataclass
class HealthCheckResult:
    """Health check result data."""
    service_name: str
    is_healthy: bool
    response_time: float
    timestamp: datetime
    error_message: Optional[str] = None
    details: Optional[Dict[str, Any]] = None


class HealthManager(BaseInfrastructureManager):
    """Manages health checks with tiered intervals."""
    
    def __init__(self, config: Optional[Dict] = None):
        """Initialize health manager."""
        super().__init__(config)
        self.health_config = HealthCheckConfig(**self.config.get("health_check", {}))
        self.service_states: Dict[str, ServiceState] = {}
        self.health_checks: Dict[str, Callable[[], Awaitable[bool]]] = {}
        self.check_history: List[HealthCheckResult] = []
        self.startup_time = time.time()
    
    def validate(self) -> bool:
        """Validate health check configuration."""
        try:
            # Validate interval values
            assert self.health_config.startup_interval > 0
            assert self.health_config.running_interval > 0
            assert self.health_config.failure_interval > 0
            assert self.health_config.timeout > 0
            assert self.health_config.retries > 0
            return True
        except Exception as e:
            self.logger.error(f"Health check validation failed: {e}")
            return False
    
    def initialize(self) -> None:
        """Initialize health check system."""
        self.logger.info("Initializing health manager")
        self._initialized = True
    
    def register_health_check(
        self, 
        service_name: str, 
        check_func: Callable[[], Awaitable[bool]]
    ) -> None:
        """Register a health check function for a service."""
        self.health_checks[service_name] = check_func
        self.service_states[service_name] = ServiceState.STARTING
        self.logger.info(f"Registered health check for service: {service_name}")
    
    def get_check_interval(self, service_name: str) -> int:
        """Get appropriate check interval based on service state."""
        state = self.service_states.get(service_name, ServiceState.STARTING)
        
        if state == ServiceState.STARTING:
            return self.health_config.startup_interval
        elif state == ServiceState.RUNNING:
            return self.health_config.running_interval
        elif state == ServiceState.FAILING:
            return self.health_config.failure_interval
        else:
            return self.health_config.running_interval
    
    async def perform_health_check(self, service_name: str) -> HealthCheckResult:
        """Perform health check for a specific service."""
        if service_name not in self.health_checks:
            return HealthCheckResult(
                service_name=service_name,
                is_healthy=False,
                response_time=0.0,
                timestamp=datetime.now(),
                error_message="No health check registered"
            )
        
        start_time = time.time()
        
        try:
            # Perform the health check with timeout
            is_healthy = await asyncio.wait_for(
                self.health_checks[service_name](),
                timeout=self.health_config.timeout
            )
            
            response_time = time.time() - start_time
            
            # Update service state based on result
            if is_healthy:
                if self.service_states[service_name] == ServiceState.STARTING:
                    # Check if startup period has passed
                    if time.time() - self.startup_time > self.health_config.start_period:
                        self.service_states[service_name] = ServiceState.RUNNING
                elif self.service_states[service_name] == ServiceState.FAILING:
                    self.service_states[service_name] = ServiceState.RUNNING
            else:
                self.service_states[service_name] = ServiceState.FAILING
            
            result = HealthCheckResult(
                service_name=service_name,
                is_healthy=is_healthy,
                response_time=response_time,
                timestamp=datetime.now()
            )
            
        except asyncio.TimeoutError:
            response_time = time.time() - start_time
            self.service_states[service_name] = ServiceState.FAILING
            
            result = HealthCheckResult(
                service_name=service_name,
                is_healthy=False,
                response_time=response_time,
                timestamp=datetime.now(),
                error_message=f"Health check timeout after {self.health_config.timeout}s"
            )
            
        except Exception as e:
            response_time = time.time() - start_time
            self.service_states[service_name] = ServiceState.FAILING
            
            result = HealthCheckResult(
                service_name=service_name,
                is_healthy=False,
                response_time=response_time,
                timestamp=datetime.now(),
                error_message=str(e)
            )
        
        # Store result in history
        self.check_history.append(result)
        
        # Limit history size
        if len(self.check_history) > 1000:
            self.check_history = self.check_history[-500:]
        
        return result
    
    async def perform_all_health_checks(self) -> Dict[str, HealthCheckResult]:
        """Perform health checks for all registered services."""
        results = {}
        
        # Run all health checks concurrently
        tasks = [
            self.perform_health_check(service_name)
            for service_name in self.health_checks.keys()
        ]
        
        if tasks:
            check_results = await asyncio.gather(*tasks, return_exceptions=True)
            
            for result in check_results:
                if isinstance(result, HealthCheckResult):
                    results[result.service_name] = result
                elif isinstance(result, Exception):
                    self.logger.error(f"Health check failed with exception: {result}")
        
        return results
    
    def get_service_health_summary(self) -> Dict[str, Any]:
        """Get health summary for all services."""
        summary = {
            "timestamp": datetime.now().isoformat(),
            "uptime": time.time() - self.startup_time,
            "services": {},
            "overall_healthy": True
        }
        
        for service_name, state in self.service_states.items():
            # Get latest health check result
            latest_result = None
            for result in reversed(self.check_history):
                if result.service_name == service_name:
                    latest_result = result
                    break
            
            service_info = {
                "state": state.value,
                "healthy": state in [ServiceState.RUNNING, ServiceState.STARTING],
                "check_interval": self.get_check_interval(service_name)
            }
            
            if latest_result:
                service_info.update({
                    "last_check": latest_result.timestamp.isoformat(),
                    "response_time": latest_result.response_time,
                    "error_message": latest_result.error_message
                })
            
            summary["services"][service_name] = service_info
            
            # Update overall health
            if not service_info["healthy"]:
                summary["overall_healthy"] = False
        
        return summary
    
    async def database_health_check(self) -> bool:
        """Example database health check."""
        try:
            # This would be replaced with actual database ping
            await asyncio.sleep(0.1)  # Simulate database check
            return True
        except Exception:
            return False
    
    async def chromadb_health_check(self) -> bool:
        """Example ChromaDB health check."""
        try:
            # This would be replaced with actual ChromaDB heartbeat
            await asyncio.sleep(0.1)  # Simulate ChromaDB check
            return True
        except Exception:
            return False
    
    async def models_health_check(self) -> bool:
        """Example ML models health check."""
        try:
            # This would be replaced with actual model loading check
            await asyncio.sleep(0.1)  # Simulate model check
            return True
        except Exception:
            return False
    
    def setup_default_health_checks(self) -> None:
        """Set up default health checks for common services."""
        self.register_health_check("database", self.database_health_check)
        self.register_health_check("chromadb", self.chromadb_health_check)
        self.register_health_check("models", self.models_health_check)
    
    def get_health_report(self) -> Dict[str, Any]:
        """Get comprehensive health management report."""
        recent_checks = [
            {
                "service": result.service_name,
                "healthy": result.is_healthy,
                "response_time": result.response_time,
                "timestamp": result.timestamp.isoformat(),
                "error": result.error_message
            }
            for result in self.check_history[-10:]  # Last 10 checks
        ]
        
        report = {
            "health_config": {
                "startup_interval": self.health_config.startup_interval,
                "running_interval": self.health_config.running_interval,
                "failure_interval": self.health_config.failure_interval,
                "timeout": self.health_config.timeout,
                "retries": self.health_config.retries,
                "start_period": self.health_config.start_period
            },
            "registered_services": list(self.health_checks.keys()),
            "service_states": {name: state.value for name, state in self.service_states.items()},
            "recent_checks": recent_checks,
            "total_checks_performed": len(self.check_history),
            "uptime": time.time() - self.startup_time
        }
        
        return report