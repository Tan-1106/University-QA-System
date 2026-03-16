#!/usr/bin/env python3
"""
Embedding Recreation Utility Script

This script recreates all embeddings in the system using the new RAG pipeline.
It reads all document chunks from MongoDB, resets ChromaDB embeddings collection,
and creates new embeddings from chunk text (not questions).

This is a one-time migration script that will be deleted after use.
"""

import asyncio
import logging
import sys
import os
from datetime import datetime
from typing import Dict, List, Any

# Add the parent directory to the path so we can import from app
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.databases.mongo import get_database, get_document_chunks_collection
from app.databases.chroma import get_chroma_client
from app.services.embedding_service import embed_text
from app.daos.document_chunk_dao import DocumentChunkDAO

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('embedding_recreation.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class EmbeddingRecreationUtility:
    """Utility class to recreate all embeddings with new pipeline."""
    
    def __init__(self):
        self.stats = {
            'total_documents': 0,
            'total_chunks': 0,
            'successful_embeddings': 0,
            'failed_embeddings': 0,
            'start_time': None,
            'end_time': None
        }
        self.chunk_dao = DocumentChunkDAO()
        
    async def initialize(self):
        """Initialize database connections."""
        logger.info("Initializing database connections...")
        
        # Initialize MongoDB connection
        self.db = await get_database()
        self.chunks_collection = get_document_chunks_collection()
        
        # Initialize ChromaDB connection
        self.chroma_client = get_chroma_client()
        
        logger.info("Database connections initialized successfully")
    
    async def reset_chromadb_collection(self):
        """Reset ChromaDB embeddings collection."""
        logger.info("Resetting ChromaDB embeddings collection...")
        
        try:
            # Delete existing collection if it exists
            try:
                self.chroma_client.delete_collection("embeddings")
                logger.info("Deleted existing embeddings collection")
            except Exception as e:
                logger.info(f"No existing collection to delete: {e}")
            
            # Create new collection
            self.collection = self.chroma_client.create_collection(
                name="embeddings",
                metadata={"hnsw:space": "cosine"}
            )
            logger.info("Created new embeddings collection")
            
        except Exception as e:
            logger.error(f"Failed to reset ChromaDB collection: {e}")
            raise
    
    async def get_all_document_chunks(self) -> List[Dict[str, Any]]:
        """Get all document chunks from MongoDB."""
        logger.info("Retrieving all document chunks from MongoDB...")
        
        try:
            cursor = self.chunks_collection.find({})
            documents = await cursor.to_list(length=None)
            
            self.stats['total_documents'] = len(documents)
            logger.info(f"Found {self.stats['total_documents']} documents")
            
            return documents
            
        except Exception as e:
            logger.error(f"Failed to retrieve document chunks: {e}")
            raise
    
    async def create_embedding_for_chunk(
        self, 
        doc_id: str, 
        chunk_index: str, 
        chunk_data: Dict[str, Any],
        faculty: str = ""
    ) -> str:
        """Create new embedding for a chunk and store in ChromaDB."""
        try:
            chunk_text = chunk_data.get('text', '')
            if not chunk_text.strip():
                logger.warning(f"Empty chunk text for doc {doc_id}, chunk {chunk_index}")
                return None
            
            # Create embedding from chunk text
            embedding_vector = await embed_text(chunk_text)
            
            # Generate unique embedding ID
            embedding_id = f"emb_{doc_id}_{chunk_index}"
            
            # Store in ChromaDB with metadata
            self.collection.add(
                embeddings=[embedding_vector],
                documents=[chunk_text],
                metadatas=[{
                    "doc_id": doc_id,
                    "chunk_index": int(chunk_index),
                    "faculty": faculty
                }],
                ids=[embedding_id]
            )
            
            logger.debug(f"Created embedding {embedding_id} for doc {doc_id}, chunk {chunk_index}")
            return embedding_id
            
        except Exception as e:
            logger.error(f"Failed to create embedding for doc {doc_id}, chunk {chunk_index}: {e}")
            return None
    
    async def update_mongodb_with_new_embedding_id(
        self, 
        doc_id: str, 
        chunk_index: str, 
        embedding_id: str
    ):
        """Update MongoDB chunk with new embedding_id (singular)."""
        try:
            # Update the chunk with new schema
            update_result = await self.chunks_collection.update_one(
                {"doc_id": doc_id},
                {
                    "$set": {
                        f"chunks.{chunk_index}.embedding_id": embedding_id
                    },
                    "$unset": {
                        f"chunks.{chunk_index}.potential_questions": "",
                        f"chunks.{chunk_index}.embedding_ids": ""
                    }
                }
            )
            
            if update_result.modified_count > 0:
                logger.debug(f"Updated MongoDB for doc {doc_id}, chunk {chunk_index}")
            else:
                logger.warning(f"No MongoDB update for doc {doc_id}, chunk {chunk_index}")
                
        except Exception as e:
            logger.error(f"Failed to update MongoDB for doc {doc_id}, chunk {chunk_index}: {e}")
            raise
    
    async def process_document(self, document: Dict[str, Any]):
        """Process a single document and recreate embeddings for all its chunks."""
        doc_id = document.get('doc_id')
        chunks = document.get('chunks', {})
        
        logger.info(f"Processing document {doc_id} with {len(chunks)} chunks")
        
        # Get faculty from document metadata if available
        faculty = document.get('faculty', '')
        
        for chunk_index, chunk_data in chunks.items():
            try:
                self.stats['total_chunks'] += 1
                
                # Create new embedding
                embedding_id = await self.create_embedding_for_chunk(
                    doc_id, chunk_index, chunk_data, faculty
                )
                
                if embedding_id:
                    # Update MongoDB with new embedding_id
                    await self.update_mongodb_with_new_embedding_id(
                        doc_id, chunk_index, embedding_id
                    )
                    self.stats['successful_embeddings'] += 1
                else:
                    self.stats['failed_embeddings'] += 1
                    
            except Exception as e:
                logger.error(f"Failed to process chunk {chunk_index} in doc {doc_id}: {e}")
                self.stats['failed_embeddings'] += 1
    
    async def run_migration(self):
        """Run the complete embedding recreation process."""
        self.stats['start_time'] = datetime.now()
        logger.info("Starting embedding recreation migration...")
        
        try:
            # Initialize connections
            await self.initialize()
            
            # Reset ChromaDB collection
            await self.reset_chromadb_collection()
            
            # Get all document chunks
            documents = await self.get_all_document_chunks()
            
            # Process each document
            for i, document in enumerate(documents, 1):
                logger.info(f"Processing document {i}/{len(documents)}: {document.get('doc_id')}")
                await self.process_document(document)
                
                # Log progress every 10 documents
                if i % 10 == 0:
                    logger.info(f"Progress: {i}/{len(documents)} documents processed")
            
            self.stats['end_time'] = datetime.now()
            self.log_final_statistics()
            
        except Exception as e:
            logger.error(f"Migration failed: {e}")
            raise
    
    def log_final_statistics(self):
        """Log final migration statistics."""
        duration = self.stats['end_time'] - self.stats['start_time']
        
        logger.info("=" * 60)
        logger.info("EMBEDDING RECREATION COMPLETED")
        logger.info("=" * 60)
        logger.info(f"Total documents processed: {self.stats['total_documents']}")
        logger.info(f"Total chunks processed: {self.stats['total_chunks']}")
        logger.info(f"Successful embeddings: {self.stats['successful_embeddings']}")
        logger.info(f"Failed embeddings: {self.stats['failed_embeddings']}")
        logger.info(f"Success rate: {(self.stats['successful_embeddings'] / self.stats['total_chunks'] * 100):.2f}%")
        logger.info(f"Total duration: {duration}")
        logger.info(f"Average time per chunk: {duration / self.stats['total_chunks'] if self.stats['total_chunks'] > 0 else 0}")
        logger.info("=" * 60)


async def main():
    """Main function to run the embedding recreation utility."""
    logger.info("Embedding Recreation Utility - Starting")
    
    try:
        utility = EmbeddingRecreationUtility()
        await utility.run_migration()
        
        logger.info("Embedding recreation completed successfully!")
        return 0
        
    except Exception as e:
        logger.error(f"Embedding recreation failed: {e}")
        return 1


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)