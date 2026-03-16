"""Cache management for dependencies and build artifacts."""

import hashlib
import json
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Any, Set
import time
import os

from .base import BaseInfrastructureManager
from ..config.base import CacheConfig


class CacheManager(BaseInfrastructureManager):
    """Manages caching for pip dependencies, Docker layers, and models."""
    
    def __init__(self, config: Optional[Dict] = None):
        """Initialize cache manager."""
        super().__init__(config)
        self.cache_config = CacheConfig(**self.config.get("cache", {}))
        self.cache_dir = Path(self.cache_config.cache_dir)
        self.pip_cache_dir = self.cache_dir / "pip"
        self.docker_cache_dir = self.cache_dir / "docker"
        self.model_cache_dir = self.cache_dir / "models"
    
    def validate(self) -> bool:
        """Validate cache configuration and directories."""
        try:
            # Ensure cache directories exist
            self.cache_dir.mkdir(parents=True, exist_ok=True)
            self.pip_cache_dir.mkdir(parents=True, exist_ok=True)
            self.docker_cache_dir.mkdir(parents=True, exist_ok=True)
            self.model_cache_dir.mkdir(parents=True, exist_ok=True)
            
            # Check write permissions
            test_file = self.cache_dir / "test_write"
            test_file.write_text("test")
            test_file.unlink()
            
            return True
        except Exception as e:
            self.logger.error(f"Cache validation failed: {e}")
            return False
    
    def initialize(self) -> None:
        """Initialize cache management."""
        self.logger.info("Initializing cache manager")
        self.validate()  # Ensure directories exist
        self._initialized = True
    
    def _generate_cache_key(self, content: str) -> str:
        """Generate cache key from content hash."""
        return hashlib.sha256(content.encode()).hexdigest()[:16]
    
    def cache_pip_dependencies(self, requirements_content: str) -> str:
        """Cache pip dependencies based on requirements content."""
        if not self.cache_config.pip_cache_enabled:
            return ""
        
        cache_key = self._generate_cache_key(requirements_content)
        cache_path = self.pip_cache_dir / cache_key
        
        if cache_path.exists():
            # Update access time
            cache_path.touch()
            self.logger.info(f"Using cached pip dependencies: {cache_key}")
            return str(cache_path)
        
        # Create new cache entry
        cache_path.mkdir(exist_ok=True)
        
        # Store requirements content
        (cache_path / "requirements.txt").write_text(requirements_content)
        
        # Store metadata
        metadata = {
            "created": time.time(),
            "cache_key": cache_key,
            "requirements_hash": self._generate_cache_key(requirements_content)
        }
        (cache_path / "metadata.json").write_text(json.dumps(metadata, indent=2))
        
        self.logger.info(f"Created pip cache entry: {cache_key}")
        return str(cache_path)
    
    def get_cached_pip_dependencies(self, requirements_content: str) -> Optional[str]:
        """Get cached pip dependencies if available."""
        if not self.cache_config.pip_cache_enabled:
            return None
        
        cache_key = self._generate_cache_key(requirements_content)
        cache_path = self.pip_cache_dir / cache_key
        
        if cache_path.exists():
            # Check if cache is still valid (not expired)
            metadata_file = cache_path / "metadata.json"
            if metadata_file.exists():
                metadata = json.loads(metadata_file.read_text())
                created_time = metadata.get("created", 0)
                
                if time.time() - created_time < self.cache_config.cache_ttl:
                    cache_path.touch()  # Update access time
                    return str(cache_path)
                else:
                    # Cache expired, remove it
                    shutil.rmtree(cache_path)
        
        return None
    
    def cache_docker_layer(self, layer_id: str, layer_data: bytes) -> bool:
        """Cache Docker layer data."""
        if not self.cache_config.docker_cache_enabled:
            return False
        
        cache_path = self.docker_cache_dir / f"{layer_id}.tar"
        
        try:
            cache_path.write_bytes(layer_data)
            
            # Store metadata
            metadata = {
                "layer_id": layer_id,
                "cached": time.time(),
                "size": len(layer_data)
            }
            metadata_path = self.docker_cache_dir / f"{layer_id}.json"
            metadata_path.write_text(json.dumps(metadata, indent=2))
            
            self.logger.info(f"Cached Docker layer: {layer_id}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to cache Docker layer {layer_id}: {e}")
            return False
    
    def get_cached_docker_layer(self, layer_id: str) -> Optional[bytes]:
        """Get cached Docker layer if available."""
        if not self.cache_config.docker_cache_enabled:
            return None
        
        cache_path = self.docker_cache_dir / f"{layer_id}.tar"
        metadata_path = self.docker_cache_dir / f"{layer_id}.json"
        
        if cache_path.exists() and metadata_path.exists():
            try:
                metadata = json.loads(metadata_path.read_text())
                cached_time = metadata.get("cached", 0)
                
                if time.time() - cached_time < self.cache_config.cache_ttl:
                    return cache_path.read_bytes()
                else:
                    # Cache expired
                    cache_path.unlink(missing_ok=True)
                    metadata_path.unlink(missing_ok=True)
            except Exception as e:
                self.logger.error(f"Error reading cached Docker layer {layer_id}: {e}")
        
        return None
    
    def cache_huggingface_model(self, model_name: str, model_path: str) -> bool:
        """Cache Hugging Face model."""
        if not self.cache_config.model_cache_enabled:
            return False
        
        try:
            safe_model_name = model_name.replace("/", "_").replace(":", "_")
            cache_path = self.model_cache_dir / safe_model_name
            
            if Path(model_path).is_dir():
                # Copy directory
                if cache_path.exists():
                    shutil.rmtree(cache_path)
                shutil.copytree(model_path, cache_path)
            else:
                # Copy file
                cache_path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(model_path, cache_path)
            
            # Store metadata
            metadata = {
                "model_name": model_name,
                "cached": time.time(),
                "original_path": model_path
            }
            metadata_path = cache_path.parent / f"{safe_model_name}.json"
            metadata_path.write_text(json.dumps(metadata, indent=2))
            
            self.logger.info(f"Cached Hugging Face model: {model_name}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to cache model {model_name}: {e}")
            return False
    
    def get_cached_model_path(self, model_name: str) -> Optional[str]:
        """Get cached model path if available."""
        if not self.cache_config.model_cache_enabled:
            return None
        
        safe_model_name = model_name.replace("/", "_").replace(":", "_")
        cache_path = self.model_cache_dir / safe_model_name
        metadata_path = cache_path.parent / f"{safe_model_name}.json"
        
        if cache_path.exists() and metadata_path.exists():
            try:
                metadata = json.loads(metadata_path.read_text())
                cached_time = metadata.get("cached", 0)
                
                if time.time() - cached_time < self.cache_config.cache_ttl:
                    return str(cache_path)
                else:
                    # Cache expired
                    if cache_path.is_dir():
                        shutil.rmtree(cache_path)
                    else:
                        cache_path.unlink(missing_ok=True)
                    metadata_path.unlink(missing_ok=True)
            except Exception as e:
                self.logger.error(f"Error reading cached model {model_name}: {e}")
        
        return None
    
    def cleanup_expired_cache(self) -> Dict[str, int]:
        """Clean up expired cache entries."""
        cleanup_stats = {
            "pip_cleaned": 0,
            "docker_cleaned": 0,
            "models_cleaned": 0
        }
        
        current_time = time.time()
        
        # Clean pip cache
        for cache_dir in self.pip_cache_dir.iterdir():
            if cache_dir.is_dir():
                metadata_file = cache_dir / "metadata.json"
                if metadata_file.exists():
                    try:
                        metadata = json.loads(metadata_file.read_text())
                        created_time = metadata.get("created", 0)
                        
                        if current_time - created_time > self.cache_config.cache_ttl:
                            shutil.rmtree(cache_dir)
                            cleanup_stats["pip_cleaned"] += 1
                    except Exception:
                        # Remove corrupted cache entries
                        shutil.rmtree(cache_dir)
                        cleanup_stats["pip_cleaned"] += 1
        
        # Clean Docker cache
        for cache_file in self.docker_cache_dir.glob("*.json"):
            try:
                metadata = json.loads(cache_file.read_text())
                cached_time = metadata.get("cached", 0)
                
                if current_time - cached_time > self.cache_config.cache_ttl:
                    layer_id = metadata.get("layer_id", "")
                    cache_file.unlink(missing_ok=True)
                    (self.docker_cache_dir / f"{layer_id}.tar").unlink(missing_ok=True)
                    cleanup_stats["docker_cleaned"] += 1
            except Exception:
                cache_file.unlink(missing_ok=True)
                cleanup_stats["docker_cleaned"] += 1
        
        # Clean model cache
        for metadata_file in self.model_cache_dir.glob("*.json"):
            try:
                metadata = json.loads(metadata_file.read_text())
                cached_time = metadata.get("cached", 0)
                
                if current_time - cached_time > self.cache_config.cache_ttl:
                    model_name = metadata.get("model_name", "")
                    safe_name = model_name.replace("/", "_").replace(":", "_")
                    model_path = self.model_cache_dir / safe_name
                    
                    if model_path.exists():
                        if model_path.is_dir():
                            shutil.rmtree(model_path)
                        else:
                            model_path.unlink()
                    
                    metadata_file.unlink(missing_ok=True)
                    cleanup_stats["models_cleaned"] += 1
            except Exception:
                metadata_file.unlink(missing_ok=True)
                cleanup_stats["models_cleaned"] += 1
        
        self.logger.info(f"Cache cleanup completed: {cleanup_stats}")
        return cleanup_stats
    
    def get_cache_report(self) -> Dict[str, Any]:
        """Get comprehensive cache management report."""
        def get_dir_size(path: Path) -> int:
            """Get directory size in bytes."""
            if not path.exists():
                return 0
            
            total_size = 0
            for item in path.rglob("*"):
                if item.is_file():
                    total_size += item.stat().st_size
            return total_size
        
        def count_cache_entries(path: Path, pattern: str = "*") -> int:
            """Count cache entries in directory."""
            if not path.exists():
                return 0
            return len(list(path.glob(pattern)))
        
        report = {
            "cache_config": {
                "pip_cache_enabled": self.cache_config.pip_cache_enabled,
                "docker_cache_enabled": self.cache_config.docker_cache_enabled,
                "model_cache_enabled": self.cache_config.model_cache_enabled,
                "cache_ttl": self.cache_config.cache_ttl,
                "cache_dir": str(self.cache_dir)
            },
            "cache_stats": {
                "pip_cache": {
                    "entries": count_cache_entries(self.pip_cache_dir),
                    "size_bytes": get_dir_size(self.pip_cache_dir)
                },
                "docker_cache": {
                    "entries": count_cache_entries(self.docker_cache_dir, "*.tar"),
                    "size_bytes": get_dir_size(self.docker_cache_dir)
                },
                "model_cache": {
                    "entries": count_cache_entries(self.model_cache_dir) - count_cache_entries(self.model_cache_dir, "*.json"),
                    "size_bytes": get_dir_size(self.model_cache_dir)
                }
            },
            "total_cache_size": get_dir_size(self.cache_dir)
        }
        
        return report