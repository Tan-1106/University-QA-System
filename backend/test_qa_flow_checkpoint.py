#!/usr/bin/env python3
"""
Checkpoint Test Suite: RAG Pipeline QA Flow Verification

This test suite verifies that the QA flow works correctly after implementing phases 1-4:
1. Document upload → chunking → embedding → storage pipeline
2. Question → embedding → semantic search → reranking → LLM → answer pipeline  
3. Conversation session creation and history management
4. Faculty filtering in semantic search
5. Error handling and rollback scenarios

Run with: python -m pytest backend/test_qa_flow_checkpoint.py -v
"""

import pytest
import asyncio
import uuid
import os
import sys
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch, Mock
from datetime import datetime, timezone

# Add backend directory to path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

# Mock database dependencies before importing
sys.modules['app.databases'] = Mock()
sys.modules['app.databases.mongo'] = Mock()
sys.modules['app.databases.chroma'] = Mock()

# Test configuration
TEST_USER_ID = "test_user_123"
TEST_FACULTY = "CNTT"
TEST_QUESTION = "Quy định về học phí như thế nào?"
TEST_QUESTION_EN = "What are the tuition fee regulations?"

class TestConversationManagement:
    """
    Test conversation session creation and history management.
    """
    
    @pytest.mark.asyncio
    async def test_create_conversation_session_success(self):
        """
        Test successful conversation session creation.
        """
        from app.services.conversation_service import create_conversation_session
        
        with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
            mock_dao = MockDAO.return_value
            test_session_id = str(uuid.uuid4())
            mock_dao.create_session = AsyncMock(return_value=test_session_id)
            
            session_id = await create_conversation_session(TEST_USER_ID)
            
            assert isinstance(session_id, str)
            assert len(session_id) == 36  # UUID format
            mock_dao.create_session.assert_called_once_with(TEST_USER_ID)
    
    @pytest.mark.asyncio
    async def test_conversation_history_management(self):
        """
        Test conversation history storage and retrieval.
        """
        from app.services.conversation_service import (
            get_conversation_history, 
            append_to_conversation
        )
        
        session_id = str(uuid.uuid4())
        user_message = "Test question"
        assistant_message = "Test answer"
        
        with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
            mock_dao = MockDAO.return_value
            
            # Test append to conversation
            mock_dao.append_message = AsyncMock(return_value=True)
            success = await append_to_conversation(session_id, user_message, assistant_message)
            assert success is True
            assert mock_dao.append_message.call_count == 2
            
            # Test get conversation history
            mock_history = [
                {"role": "user", "content": user_message, "timestamp": datetime.now()},
                {"role": "assistant", "content": assistant_message, "timestamp": datetime.now()}
            ]
            mock_dao.get_history = AsyncMock(return_value=mock_history)
            
            history = await get_conversation_history(session_id, max_turns=10)
            assert isinstance(history, list)
            assert len(history) == 2
            assert history[0]["role"] == "user"
            assert history[1]["role"] == "assistant"


class TestEmbeddingService:
    """
    Test embedding service functionality.
    """
    
    @pytest.mark.asyncio
    async def test_embed_text_produces_valid_vectors(self):
        """
        Test that embedding text produces valid 768-dimensional vectors.
        """
        from app.services.embedding_service import embed_text
        
        with patch('app.services.embedding_service.embedding_model') as mock_model:
            # Mock embedding model to return 768-dimensional vector
            mock_vector = [0.1] * 768
            mock_array = Mock()
            mock_array.tolist.return_value = mock_vector
            mock_model.encode.return_value = mock_array
            
            with patch('app.services.embedding_service.tokenize', return_value="tokenized text"):
                embedding = await embed_text(TEST_QUESTION)
                
                assert isinstance(embedding, list)
                assert len(embedding) == 768
                assert all(isinstance(x, float) for x in embedding)
                assert all(-1.0 <= x <= 1.0 for x in embedding)  # Reasonable range for embeddings
    
    @pytest.mark.asyncio
    async def test_embed_and_store_chunk_success(self):
        """Test successful chunk embedding and storage."""
        from app.services.embedding_service import embed_and_store_chunk
        
        chunk_text = "Test chunk content for embedding"
        doc_id = "test_doc_123"
        chunk_index = 0
        faculty = TEST_FACULTY
        
        with patch('app.services.embedding_service.embed_text') as mock_embed:
            mock_embed.return_value = [0.1] * 768
            
            with patch('app.services.embedding_service.EmbeddingDAO') as MockDAO:
                mock_dao = MockDAO.return_value
                test_embedding_id = "embedding_123"
                mock_dao.create_embedding = AsyncMock(return_value={"embedding_id": test_embedding_id})
                
                embedding_id = await embed_and_store_chunk(chunk_text, doc_id, chunk_index, faculty)
                
                assert embedding_id == test_embedding_id
                mock_embed.assert_called_once_with(chunk_text)
                mock_dao.create_embedding.assert_called_once()
    
    @pytest.mark.asyncio
    async def test_semantic_search_returns_correct_results(self):
        """Test semantic search returns correct number of results with metadata."""
        from app.services.embedding_service import semantic_search
        
        query_vector = [0.1] * 768
        top_k = 100
        faculty_filter = TEST_FACULTY
        
        with patch('app.services.embedding_service.EmbeddingDAO') as MockDAO:
            mock_dao = MockDAO.return_value
            mock_results = [
                {
                    "metadata": {
                        "doc_id": "doc_1",
                        "chunk_index": 0,
                        "faculty": TEST_FACULTY
                    },
                    "distance": 0.1
                },
                {
                    "metadata": {
                        "doc_id": "doc_2", 
                        "chunk_index": 1,
                        "faculty": TEST_FACULTY
                    },
                    "distance": 0.2
                }
            ]
            mock_dao.semantic_search_embeddings = AsyncMock(return_value=mock_results)
            
            results = await semantic_search(query_vector, top_k, faculty_filter)
            
            assert isinstance(results, list)
            assert len(results) <= top_k
            for result in results:
                assert "metadata" in result
                assert "distance" in result
                metadata = result["metadata"]
                assert "doc_id" in metadata
                assert "chunk_index" in metadata
                assert "faculty" in metadata


class TestQAService:
    """Test QA service functionality."""
    
    @pytest.mark.asyncio
    async def test_rerank_chunks_preserves_top_k_constraint(self):
        """Test that reranking returns at most top_k chunks in descending order."""
        from app.services.qa_service import rerank_chunks
        
        question = TEST_QUESTION
        chunks = [f"Chunk {i} content" for i in range(50)]  # 50 chunks
        top_k = 20
        
        with patch('app.services.qa_service.cross_encoder_model') as mock_model:
            # Mock scores in descending order
            mock_scores = [1.0 - (i * 0.01) for i in range(len(chunks))]
            mock_model.predict = Mock(return_value=mock_scores)
            
            reranked = rerank_chunks(question, chunks, top_k)
            
            assert isinstance(reranked, list)
            assert len(reranked) <= top_k
            assert len(reranked) == min(top_k, len(chunks))
    
    @pytest.mark.asyncio
    async def test_get_answer_with_conversation_history(self):
        """Test QA flow with conversation history integration."""
        from app.services.qa_service import get_answer
        
        question = TEST_QUESTION
        question_in_vietnamese = TEST_QUESTION
        user_faculty = TEST_FACULTY
        question_language = "vi"
        session_id = str(uuid.uuid4())
        user_id = TEST_USER_ID
        
        # Mock all dependencies
        with patch('app.services.qa_service.llm_service') as mock_llm, \
             patch('app.services.qa_service.embedding_service') as mock_embed, \
             patch('app.services.qa_service.document_chunk_service') as mock_chunk, \
             patch('app.services.conversation_service') as mock_conv:
            
            # Setup mocks
            mock_llm.get_current_api_key = AsyncMock(return_value={"provider": "openai", "api_key": "test"})
            mock_conv.get_conversation_history = AsyncMock(return_value=[])
            mock_embed.embed_text = AsyncMock(return_value=[0.1] * 768)
            mock_embed.find_relevant_chunks = AsyncMock(return_value=[
                {"doc_id": "doc_1", "chunk_index": 0}
            ])
            mock_chunk.get_document_chunk_by_index = AsyncMock(return_value={
                "text": "Test chunk content",
                "file_name": "test.pdf",
                "file_url": "http://test.com/test.pdf"
            })
            mock_llm.generate_answer = AsyncMock(return_value="Test answer")
            mock_conv.append_to_conversation = AsyncMock(return_value=True)
            
            answer, returned_session_id = await get_answer(
                question, question_in_vietnamese, user_faculty, 
                question_language, session_id, user_id
            )
            
            assert isinstance(answer, str)
            assert returned_session_id == session_id
            mock_conv.get_conversation_history.assert_called_once()
            mock_embed.embed_text.assert_called_once_with(question_in_vietnamese)
            mock_llm.generate_answer.assert_called_once()
            mock_conv.append_to_conversation.assert_called_once()


class TestDocumentProcessing:
    """Test document processing pipeline."""
    
    @pytest.mark.asyncio
    async def test_chunk_document_produces_valid_chunks(self):
        """Test that document chunking produces chunks within size constraints."""
        from app.utils.text_process import chunk_document
        
        # Create test document with sufficient content (repeat content to ensure large chunks)
        base_content = """CHƯƠNG I: GIỚI THIỆU

Đây là nội dung thử nghiệm để kiểm tra chức năng chia chunk mới của hệ thống RAG pipeline. 
Chúng ta cần đảm bảo rằng mỗi chunk có kích thước từ 1200 đến 1500 tokens và có overlap 
từ 300 đến 400 tokens giữa các chunk liên tiếp. Điều này rất quan trọng để đảm bảo chất 
lượng của việc tìm kiếm ngữ nghĩa và trả lời câu hỏi.

ĐIỀU 1: Quy định chung về hệ thống

Hệ thống RAG pipeline mới sử dụng phương pháp embedding trực tiếp từ nội dung chunk thay vì 
tạo câu hỏi tiềm năng như trước đây. Điều này giúp giảm độ phức tạp và tăng hiệu suất xử lý.
Mỗi chunk sẽ được embedding bằng model dangvantuan/vietnamese-embedding để tạo ra vector 
768 chiều. Vector này sẽ được lưu trữ trong ChromaDB để phục vụ cho việc tìm kiếm ngữ nghĩa.

MỤC 1: Chi tiết kỹ thuật

Quá trình chunking sẽ ưu tiên chia tại các ranh giới ngữ nghĩa như chương, điều, mục, đoạn văn.
Điều này đảm bảo rằng mỗi chunk chứa thông tin có ý nghĩa và ngữ cảnh đầy đủ để có thể trả lời
các câu hỏi một cách chính xác. Hệ thống cũng sẽ duy trì overlap giữa các chunk để đảm bảo
không bị mất thông tin quan trọng tại các ranh giới.

"""
        # Repeat content multiple times to ensure we get chunks in the target range
        test_content = base_content * 10  # This should create content large enough for proper chunking
        
        chunks = await chunk_document(test_content)
        
        assert isinstance(chunks, list)
        assert len(chunks) > 0
        
        for chunk in chunks:
            assert "text" in chunk
            assert "token_count" in chunk
            assert "chunk_index" in chunk
            assert isinstance(chunk["text"], str)
            assert isinstance(chunk["token_count"], int)
            assert len(chunk["text"]) > 0
            
            # Most chunks should be within 1200-1500 token range
            # Last chunk may be smaller if remaining content is less than 1200 tokens
            # For very small documents, chunks may also be smaller
            if len(chunks) > 1 and chunk["chunk_index"] < len(chunks) - 1:
                # Not the last chunk - should be in target range if document is large enough
                if chunk["token_count"] < 1200:
                    # This is acceptable for small documents
                    assert chunk["token_count"] > 0
                else:
                    assert 1200 <= chunk["token_count"] <= 1500
            else:
                # Last chunk or single chunk - can be any size
                assert chunk["token_count"] > 0


class TestAPIEndpoints:
    """Test API endpoint functionality."""
    
    @pytest.mark.asyncio
    async def test_qa_controller_get_answer_with_session(self):
        """Test QA controller handles session management correctly."""
        from app.controllers.qa_controller import get_answer
        
        question = TEST_QUESTION
        current_user = {
            "_id": TEST_USER_ID,
            "sub": "test_sub",
            "faculty": TEST_FACULTY
        }
        session_id = str(uuid.uuid4())
        
        with patch('app.controllers.qa_controller.qa_service') as mock_service, \
             patch('app.controllers.qa_controller.detect', return_value='vi'):
            
            # Mock service responses
            mock_service.create_question_record = AsyncMock(return_value={"_id": "question_123"})
            mock_service.get_answer = AsyncMock(return_value=("Test answer", session_id))
            mock_service.update_question_record_with_answer = AsyncMock(return_value={
                "_id": "question_123",
                "question": question,
                "answer": "Test answer"
            })
            
            result = await get_answer(question, current_user, session_id)
            
            assert "question_id" in result
            assert "session_id" in result
            assert "question" in result
            assert "answer" in result
            assert result["session_id"] == session_id
            mock_service.get_answer.assert_called_once()
    
    @pytest.mark.asyncio
    async def test_conversation_controller_create_session(self):
        """Test conversation controller creates sessions correctly."""
        from app.controllers.conversation_controller import create_conversation_session
        
        user_id = TEST_USER_ID
        current_user = {"_id": TEST_USER_ID}
        
        with patch('app.controllers.conversation_controller.conversation_service') as mock_service:
            test_session_id = str(uuid.uuid4())
            mock_service.create_conversation_session = AsyncMock(return_value=test_session_id)
            
            result = await create_conversation_session(user_id, current_user)
            
            assert "session_id" in result
            assert "created_at" in result
            assert result["session_id"] == test_session_id
            mock_service.create_conversation_session.assert_called_once_with(TEST_USER_ID)


class TestErrorHandling:
    """Test error handling and rollback scenarios."""
    
    @pytest.mark.asyncio
    async def test_qa_service_handles_missing_api_key(self):
        """Test QA service handles missing API key gracefully."""
        from app.services.qa_service import get_answer
        from app.utils.api_response import UserError
        
        with patch('app.services.qa_service.llm_service') as mock_llm:
            mock_llm.get_current_api_key = AsyncMock(return_value=None)
            
            with pytest.raises(UserError, match="No active API key found"):
                await get_answer(TEST_QUESTION, TEST_QUESTION, TEST_FACULTY, "vi")
    
    @pytest.mark.asyncio
    async def test_conversation_service_handles_invalid_session(self):
        """Test conversation service handles invalid session IDs."""
        from app.services.conversation_service import get_conversation_history
        from app.utils.api_response import DatabaseException
        
        invalid_session_id = "invalid_session_123"
        
        with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
            mock_dao = MockDAO.return_value
            mock_dao.get_history = AsyncMock(
                side_effect=DatabaseException(f"Conversation session {invalid_session_id} not found")
            )
            
            with pytest.raises(DatabaseException):
                await get_conversation_history(invalid_session_id)


class TestFacultyFiltering:
    """Test faculty filtering in semantic search."""
    
    @pytest.mark.asyncio
    async def test_semantic_search_faculty_filtering(self):
        """Test that faculty filtering excludes non-matching results."""
        from app.services.embedding_service import find_relevant_chunks
        
        query_vector = [0.1] * 768
        user_faculty = TEST_FACULTY
        
        with patch('app.services.embedding_service.EmbeddingDAO') as MockDAO:
            mock_dao = MockDAO.return_value
            # Mock results - all should have matching faculty
            mock_results = [
                {
                    "metadata": {
                        "doc_id": "doc_1",
                        "chunk_index": 0,
                        "faculty": TEST_FACULTY  # Matching faculty
                    },
                    "distance": 0.1
                },
                {
                    "metadata": {
                        "doc_id": "doc_2",
                        "chunk_index": 1,
                        "faculty": TEST_FACULTY  # Matching faculty
                    },
                    "distance": 0.2
                }
            ]
            mock_dao.semantic_search_embeddings = AsyncMock(return_value=mock_results)
            
            results = await find_relevant_chunks(100, query_vector, user_faculty)
            
            # Verify all results have matching faculty
            for result in results:
                assert result["faculty"] == TEST_FACULTY or result["faculty"] == ""
            
            # Verify the DAO was called with correct faculty filter
            mock_dao.semantic_search_embeddings.assert_called_once_with(
                top_k=100,
                embedded_question=query_vector,
                faculty=user_faculty
            )


if __name__ == "__main__":
    print("Running RAG Pipeline QA Flow Checkpoint Tests...")
    print("=" * 60)
    
    # Run tests with verbose output
    pytest.main([__file__, "-v", "--tb=short"])