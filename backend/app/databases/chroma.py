import os
import chromadb
from chromadb.config import Settings


# --- CONFIGURATION ---
chroma_host = os.getenv("CHROMA_HOST", "university_qa_chromadb")
chroma_port = os.getenv("CHROMA_PORT", "8000")
use_local = os.getenv("CHROMA_USE_LOCAL", "true").lower() == "true"


# --- CLIENT ---
if use_local:
    # Use persistent local client for development
    client = chromadb.PersistentClient(
        path="./chroma_data",
        settings=Settings(allow_reset=True)
    )
else:
    # Use HTTP client for production/Docker
    client = chromadb.HttpClient(
        host=chroma_host,
        port=chroma_port,
        settings=Settings(allow_reset=True)
    )


# --- COLLECTIONS ---
# Question embeddings collection
embeddings_collection = client.get_or_create_collection(
    name="embeddings",
    metadata={"hnsw:space": "cosine"}
)