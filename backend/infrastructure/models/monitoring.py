"""Monitoring and logging data models."""

from pydantic import BaseModel
from typing import Dict, List, Optional, Any
from datetime import datetime


class MetricData(BaseModel):
    """Metric data point for monitoring."""
    timestamp: datetime
    service: str
    metric_name: str
    value: float
    labels: Dict[str, str] = {}
    
    class Config:
        """Pydantic configuration."""
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class LogEntry(BaseModel):
    """Structured log entry."""
    timestamp: datetime
    level: str
    service: str
    message: str
    context: Dict[str, Any] = {}
    request_id: Optional[str] = None
    user_id: Optional[str] = None
    
    class Config:
        """Pydantic configuration."""
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class AlertRule(BaseModel):
    """Alert rule configuration."""
    name: str
    condition: str
    threshold: float
    duration: int  # seconds
    severity: str  # critical, high, medium, low
    enabled: bool = True
    notification_channels: List[str] = []
    
    def evaluate(self, metric_value: float) -> bool:
        """Evaluate if alert should be triggered."""
        if not self.enabled:
            return False
        
        # Simple threshold evaluation
        if self.condition == "greater_than":
            return metric_value > self.threshold
        elif self.condition == "less_than":
            return metric_value < self.threshold
        elif self.condition == "equals":
            return metric_value == self.threshold
        
        return False