"""Environment-specific settings for infrastructure management."""

from pydantic_settings import BaseSettings
from pydantic import ConfigDict
from typing import Optional
import os


class Settings(BaseSettings):
    """Base settings class with common configuration."""
    model_config = ConfigDict(env_file=".env", case_sensitive=False, extra="ignore")
    
    # Environment
    environment: str = "development"
    debug: bool = True
    
    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    workers: int = 1
    
    # Database
    mongo_url: str = "mongodb://localhost:27017"
    mongo_db: str = "university_qa"
    
    # Security
    secret_key: str = "dev-secret-key"
    api_key_secret: str = "dev-api-secret"
    
    # Infrastructure
    python_version: str = "3.12"
    log_level: str = "INFO"


class DevelopmentSettings(Settings):
    """Development-specific settings with debugging enabled."""
    debug: bool = True
    workers: int = 1
    log_level: str = "DEBUG"
    environment: str = "development"
    
    # Development-specific overrides
    reload: bool = True
    access_log: bool = True


class ProductionSettings(Settings):
    """Production-specific settings with optimizations."""
    debug: bool = False
    workers: int = 4
    log_level: str = "INFO"
    environment: str = "production"
    
    # Production-specific overrides
    reload: bool = False
    access_log: bool = False
    
    # Security hardening
    secret_key: str  # Must be provided via environment
    api_key_secret: str  # Must be provided via environment


def get_settings() -> Settings:
    """Get settings based on environment variable."""
    env = os.getenv("ENVIRONMENT", "development").lower()
    if env == "production":
        return ProductionSettings()
    return DevelopmentSettings()