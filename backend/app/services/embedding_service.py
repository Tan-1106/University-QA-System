import os
import re
import asyncio
import logging
import time
from pyvi.ViTokenizer import tokenize
from fastapi.encoders import jsonable_encoder
from sentence_transformers import SentenceTransformer

from app.daos.document_dao import DocumentDAO
from app.daos.embedding_dao import EmbeddingDAO
from app.daos.document_chunk_dao import DocumentChunkDAO


logging.getLogger("sentence_transformers").setLevel(logging.WARNING)
logger = logging.getLogger(__name__)


# --- CONFIGURATION ---
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "dangvantuan/vietnamese-embedding")
embedding_model = SentenceTransformer(EMBEDDING_MODEL)


# --- MAIN SERVICE FUNCTIONS ---
# Get embedding vectors with pagination
async def get_embedding_vectors(page: int, limit: int):
    skip = (page - 1) * limit
    total = await EmbeddingDAO().count_embeddings()
    total_pages = (total + limit - 1) // limit
    vectors = await EmbeddingDAO().get_embedding_vectors(skip, limit)
    return {
        "vectors": vectors,
        "total": total,
        "total_pages": total_pages,
        "current_page": page
    }


# Embed text directly (Task 2.4)
async def embed_text(text: str) -> list[float]:
    """
    Create embedding vector for text (chunk or query).
    
    Args:
        text: Text to embed (chunk or query)
        
    Returns:
        768-dimensional embedding vector
    """
    start_time = time.time()
    text_length = len(text)
    
    try:
        text = text.strip()
        text = re.sub(r'\s+', ' ', text)
        
        text_tokenized = await asyncio.to_thread(tokenize, text)
        embedding_vector = await asyncio.to_thread(embedding_model.encode, text_tokenized)
        embedding = embedding_vector.tolist()
        
        processing_time = time.time() - start_time
        logger.info(f"Text embedding successful - length: {text_length}, processing_time: {processing_time:.3f}s")
        
        return embedding
        
    except Exception as e:
        processing_time = time.time() - start_time
        logger.error(f"Text embedding failed - length: {text_length}, processing_time: {processing_time:.3f}s, error: {str(e)}")
        raise


# Embed chunk and store in ChromaDB (Task 2.4)
async def embed_and_store_chunk(
    chunk_text: str,
    doc_id: str,
    chunk_index: int,
    faculty: str
) -> str:
    """
    Embed chunk and store in ChromaDB.
    
    Args:
        chunk_text: Chunk content to embed
        doc_id: Document ID
        chunk_index: Index of chunk in document
        faculty: Faculty filter (empty string for general docs)
        
    Returns:
        embedding_id from ChromaDB
    """
    start_time = time.time()
    
    try:
        embedding = await embed_text(chunk_text)
        embedding_data = {
            "vector": embedding,
            "metadatas": {
                "doc_id": doc_id,
                "chunk_index": chunk_index,
                "faculty": faculty if faculty else ""
            }
        }
        result = await EmbeddingDAO().create_embedding(embedding_data)
        
        processing_time = time.time() - start_time
        logger.info(f"Chunk embedding stored successfully - doc_id: {doc_id}, chunk_index: {chunk_index}, faculty: {faculty}, embedding_id: {result['embedding_id']}, processing_time: {processing_time:.3f}s")
        
        return result["embedding_id"]
        
    except Exception as e:
        processing_time = time.time() - start_time
        logger.error(f"Chunk embedding storage failed - doc_id: {doc_id}, chunk_index: {chunk_index}, faculty: {faculty}, processing_time: {processing_time:.3f}s, error: {str(e)}")
        raise


# Search by chunk embeddings (Task 2.4)
async def semantic_search(
    query_vector: list[float],
    top_k: int = 100,
    faculty_filter: str = ""
) -> list[dict]:
    """
    Search for similar chunks in vector database.
    
    Args:
        query_vector: Query embedding vector
        top_k: Number of results to return
        faculty_filter: Optional faculty filter
        
    Returns:
        List of {embedding_id, doc_id, chunk_index, faculty, distance}
    """
    start_time = time.time()
    
    try:
        results = await EmbeddingDAO().semantic_search_embeddings(
            top_k=top_k,
            embedded_question=query_vector,
            faculty=faculty_filter
        )
        
        processing_time = time.time() - start_time
        logger.info(f"Semantic search completed - top_k: {top_k}, faculty_filter: '{faculty_filter}', results_count: {len(results)}, processing_time: {processing_time:.3f}s")
        
        return results
        
    except Exception as e:
        processing_time = time.time() - start_time
        logger.error(f"Semantic search failed - top_k: {top_k}, faculty_filter: '{faculty_filter}', processing_time: {processing_time:.3f}s, error: {str(e)}")
        raise
    
    
# Store embedding in the ChromaDB
async def store_embedding(text: str, metadatas: dict):
    embedding = await embed_text(text)
    embedding_data = {
        "vector": embedding,
        "metadatas": metadatas
    }
    embedding =  await EmbeddingDAO().create_embedding(embedding_data)
    return embedding


# Reset embeddings collection
async def reset_embeddings():
    success = await EmbeddingDAO().reset_embeddings()
    return success
    
    
# Find relevant chunks using semantic search (Task 4.1)
async def find_relevant_chunks(
    top_k: int,
    embedding_vector: list[float],
    user_faculty: str
) -> list[dict]:
    """
    Find relevant chunks using semantic search.
    Search directly by chunk embeddings (not question embeddings).
    
    Args:
        top_k: Number of results to return (typically 100)
        embedding_vector: Query embedding vector
        user_faculty: Faculty filter (empty string for general docs)
        
    Returns:
        List of {doc_id, chunk_index, faculty, distance} with metadata
    """
    chunk_embeddings = await EmbeddingDAO().semantic_search_embeddings(
        top_k=top_k,
        embedded_question=embedding_vector,
        faculty=user_faculty
    )
    
    # Transform results to include required metadata format
    results = []
    for item in chunk_embeddings:
        metadata = item.get("metadata", {})
        result = {
            "doc_id": metadata.get("doc_id"),
            "chunk_index": metadata.get("chunk_index"),
            "faculty": metadata.get("faculty", ""),
            "distance": item.get("distance", 0.0),
            "metadata": metadata  # Keep original metadata for backward compatibility
        }
        results.append(result)
    
    return results

# --- SUPPORTING FUNCTIONS ---
# Delete embeddings by ID
async def delete_embedding_by_id(embedding_id: str):
    await EmbeddingDAO().delete_embedding_by_id(embedding_id)

# Delete embeddings by document ID
async def delete_embeddings_by_doc_id(doc_id: str):
    await EmbeddingDAO().delete_embeddings_by_doc_id(doc_id)