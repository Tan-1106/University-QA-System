"""Base manager class for infrastructure components."""

from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
import logging


class BaseInfrastructureManager(ABC):
    """Base class for all infrastructure managers."""
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """Initialize the manager with optional configuration."""
        self.config = config or {}
        self.logger = logging.getLogger(self.__class__.__name__)
    
    @abstractmethod
    def validate(self) -> bool:
        """Validate the manager's configuration and state."""
        pass
    
    @abstractmethod
    def initialize(self) -> None:
        """Initialize the manager's resources."""
        pass
    
    def get_status(self) -> Dict[str, Any]:
        """Get the current status of the manager."""
        return {
            "manager": self.__class__.__name__,
            "initialized": hasattr(self, "_initialized"),
            "config": self.config
        }