"""Resource management and monitoring for containers."""

import psutil
import time
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from datetime import datetime

from .base import BaseInfrastructureManager
from ..config.base import ResourceLimits


@dataclass
class ResourceUsage:
    """Resource usage data point."""
    timestamp: datetime
    cpu_percent: float
    memory_percent: float
    memory_bytes: int
    disk_usage: Dict[str, float]
    network_io: Dict[str, int]


class ResourceManager(BaseInfrastructureManager):
    """Manages container resource limits and monitoring."""
    
    def __init__(self, config: Optional[Dict] = None):
        """Initialize resource manager."""
        super().__init__(config)
        self.resource_limits = ResourceLimits(**self.config.get("resource_limits", {}))
        self.alert_threshold = self.config.get("alert_threshold", 0.8)  # 80%
        self.monitoring_enabled = False
        self.usage_history: List[ResourceUsage] = []
    
    def validate(self) -> bool:
        """Validate resource management configuration."""
        try:
            # Validate resource limits format
            self._parse_memory_limit(self.resource_limits.memory_limit)
            self._parse_cpu_limit(self.resource_limits.cpu_limit)
            return True
        except Exception as e:
            self.logger.error(f"Resource validation failed: {e}")
            return False
    
    def initialize(self) -> None:
        """Initialize resource monitoring."""
        self.logger.info("Initializing resource manager")
        self.monitoring_enabled = True
        self._initialized = True
    
    def _parse_memory_limit(self, memory_str: str) -> int:
        """Parse memory limit string to bytes."""
        memory_str = memory_str.upper()
        
        if memory_str.endswith('G'):
            return int(memory_str[:-1]) * 1024 * 1024 * 1024
        elif memory_str.endswith('M'):
            return int(memory_str[:-1]) * 1024 * 1024
        elif memory_str.endswith('K'):
            return int(memory_str[:-1]) * 1024
        else:
            return int(memory_str)
    
    def _parse_cpu_limit(self, cpu_str: str) -> float:
        """Parse CPU limit string to float."""
        return float(cpu_str)
    
    def get_current_usage(self) -> ResourceUsage:
        """Get current system resource usage."""
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # Memory usage
        memory = psutil.virtual_memory()
        memory_percent = memory.percent
        memory_bytes = memory.used
        
        # Disk usage
        disk_usage = {}
        for partition in psutil.disk_partitions():
            try:
                usage = psutil.disk_usage(partition.mountpoint)
                disk_usage[partition.mountpoint] = {
                    "total": usage.total,
                    "used": usage.used,
                    "free": usage.free,
                    "percent": (usage.used / usage.total) * 100
                }
            except PermissionError:
                continue
        
        # Network I/O
        network = psutil.net_io_counters()
        network_io = {
            "bytes_sent": network.bytes_sent,
            "bytes_recv": network.bytes_recv,
            "packets_sent": network.packets_sent,
            "packets_recv": network.packets_recv
        }
        
        return ResourceUsage(
            timestamp=datetime.now(),
            cpu_percent=cpu_percent,
            memory_percent=memory_percent,
            memory_bytes=memory_bytes,
            disk_usage=disk_usage,
            network_io=network_io
        )
    
    def check_resource_thresholds(self, usage: ResourceUsage) -> List[str]:
        """Check if resource usage exceeds thresholds."""
        alerts = []
        
        # Check CPU threshold
        if usage.cpu_percent > (self.alert_threshold * 100):
            alerts.append(
                f"CPU usage ({usage.cpu_percent:.1f}%) exceeds threshold "
                f"({self.alert_threshold * 100:.1f}%)"
            )
        
        # Check memory threshold
        if usage.memory_percent > (self.alert_threshold * 100):
            alerts.append(
                f"Memory usage ({usage.memory_percent:.1f}%) exceeds threshold "
                f"({self.alert_threshold * 100:.1f}%)"
            )
        
        # Check disk thresholds
        for mountpoint, disk_info in usage.disk_usage.items():
            if disk_info["percent"] > (self.alert_threshold * 100):
                alerts.append(
                    f"Disk usage on {mountpoint} ({disk_info['percent']:.1f}%) "
                    f"exceeds threshold ({self.alert_threshold * 100:.1f}%)"
                )
        
        return alerts
    
    def generate_docker_compose_config(self) -> Dict[str, Any]:
        """Generate Docker Compose resource configuration."""
        return {
            "deploy": {
                "resources": {
                    "limits": {
                        "cpus": self.resource_limits.cpu_limit,
                        "memory": self.resource_limits.memory_limit
                    },
                    "reservations": {
                        "cpus": self.resource_limits.cpu_reservation,
                        "memory": self.resource_limits.memory_reservation
                    }
                },
                "restart_policy": {
                    "condition": "on-failure",
                    "delay": "5s",
                    "max_attempts": 3
                }
            }
        }
    
    def monitor_resources(self, duration_seconds: int = 60) -> List[ResourceUsage]:
        """Monitor resources for specified duration."""
        if not self.monitoring_enabled:
            self.logger.warning("Resource monitoring not enabled")
            return []
        
        start_time = time.time()
        usage_data = []
        
        while time.time() - start_time < duration_seconds:
            usage = self.get_current_usage()
            usage_data.append(usage)
            self.usage_history.append(usage)
            
            # Check for alerts
            alerts = self.check_resource_thresholds(usage)
            for alert in alerts:
                self.logger.warning(f"Resource alert: {alert}")
            
            time.sleep(5)  # Monitor every 5 seconds
        
        return usage_data
    
    def get_resource_report(self) -> Dict[str, Any]:
        """Get comprehensive resource management report."""
        current_usage = self.get_current_usage()
        alerts = self.check_resource_thresholds(current_usage)
        
        report = {
            "resource_limits": {
                "cpu_limit": self.resource_limits.cpu_limit,
                "memory_limit": self.resource_limits.memory_limit,
                "cpu_reservation": self.resource_limits.cpu_reservation,
                "memory_reservation": self.resource_limits.memory_reservation
            },
            "current_usage": {
                "cpu_percent": current_usage.cpu_percent,
                "memory_percent": current_usage.memory_percent,
                "memory_bytes": current_usage.memory_bytes,
                "timestamp": current_usage.timestamp.isoformat()
            },
            "alerts": alerts,
            "monitoring_enabled": self.monitoring_enabled,
            "alert_threshold": self.alert_threshold,
            "history_count": len(self.usage_history)
        }
        
        return report