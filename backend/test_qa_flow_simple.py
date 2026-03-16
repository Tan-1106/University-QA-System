#!/usr/bin/env python3
"""
Simplified QA Flow Checkpoint Test

This test focuses on core functionality without heavy ML dependencies.
Tests the conversation management, API endpoints, and basic service logic.
"""

import pytest
import asyncio
import uuid
import sys
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch, Mock
from datetime import datetime, timezone

# Add backend directory to path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

# Mock all heavy dependencies before importing
sys.modules['sentence_transformers'] = Mock()
sys.modules['transformers'] = Mock()
sys.modules['openai'] = Mock()
sys.modules['google.generativeai'] = Mock()
sys.modules['pyvi'] = Mock()
sys.modules['pyvi.ViTokenizer'] = Mock()
sys.modules['langdetect'] = Mock()

# Mock database modules
sys.modules['app.databases'] = Mock()
sys.modules['app.databases.mongo'] = Mock()
sys.modules['app.databases.chroma'] = Mock()

# Test configuration
TEST_USER_ID = "test_user_123"
TEST_FACULTY = "CNTT"
TEST_QUESTION = "Quy định về học phí như thế nào?"


class TestConversationManagement:
    """Test conversation session creation and history management."""
    
    @pytest.mark.asyncio
    async def test_create_conversation_session_success(self):
        """Test successful conversation session creation."""
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
        """Test conversation history storage and retrieval."""
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


class TestAPIEndpoints:
    """Test API endpoint functionality."""
    
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
    
    @pytest.mark.asyncio
    async def test_conversation_controller_get_history(self):
        """Test conversation controller retrieves history correctly."""
        from app.controllers.conversation_controller import get_conversation_history
        
        session_id = str(uuid.uuid4())
        current_user = {"_id": TEST_USER_ID}
        
        with patch('app.controllers.conversation_controller.conversation_service') as mock_service:
            mock_history = [
                {"role": "user", "content": "Test question", "timestamp": datetime.now()},
                {"role": "assistant", "content": "Test answer", "timestamp": datetime.now()}
            ]
            mock_service.get_conversation_history = AsyncMock(return_value=mock_history)
            
            result = await get_conversation_history(session_id, current_user)
            
            assert "session_id" in result
            assert "messages" in result
            assert "created_at" in result
            assert result["session_id"] == session_id
            assert len(result["messages"]) == 2
            mock_service.get_conversation_history.assert_called_once_with(session_id, max_turns=10)
    
    @pytest.mark.asyncio
    async def test_conversation_controller_delete_session(self):
        """Test conversation controller deletes sessions correctly."""
        from app.controllers.conversation_controller import delete_conversation_session
        
        session_id = str(uuid.uuid4())
        current_user = {"_id": TEST_USER_ID}
        
        with patch('app.controllers.conversation_controller.conversation_service') as mock_service:
            mock_service.delete_conversation_session = AsyncMock(return_value=True)
            
            result = await delete_conversation_session(session_id, current_user)
            
            assert "success" in result
            assert result["success"] is True
            mock_service.delete_conversation_session.assert_called_once_with(session_id)


class TestDocumentProcessing:
    """Test document processing pipeline."""
    
    @pytest.mark.asyncio
    async def test_chunk_document_produces_valid_chunks(self):
        """Test that document chunking produces chunks with proper structure."""
        from app.utils.text_process import chunk_document
        
        # Create test document with sufficient content for multiple chunks
        test_content = "CHƯƠNG I: GIỚI THIỆU\n\n" + ("Đây là nội dung thử nghiệm để tạo chunk. " * 300)
        
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
            assert chunk["token_count"] > 0


class TestErrorHandling:
    """Test error handling scenarios."""
    
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
    
    @pytest.mark.asyncio
    async def test_conversation_controller_authentication_required(self):
        """Test conversation controller requires authentication."""
        from app.controllers.conversation_controller import create_conversation_session
        from app.utils.api_response import UserError
        
        user_id = TEST_USER_ID
        current_user = None  # No authentication
        
        with pytest.raises(UserError, match="Authentication required"):
            await create_conversation_session(user_id, current_user)
    
    @pytest.mark.asyncio
    async def test_conversation_controller_user_authorization(self):
        """Test conversation controller enforces user authorization."""
        from app.controllers.conversation_controller import create_conversation_session
        from app.utils.api_response import UserError
        
        user_id = "other_user_456"
        current_user = {"_id": TEST_USER_ID}  # Different user
        
        with pytest.raises(UserError, match="You can only create conversation sessions for yourself"):
            await create_conversation_session(user_id, current_user)


class TestServiceIntegration:
    """Test service layer integration."""
    
    @pytest.mark.asyncio
    async def test_document_chunk_service_get_chunk_by_index(self):
        """Test document chunk service retrieves chunks correctly."""
        from app.services.document_chunk_service import get_document_chunk_by_index
        
        doc_id = "test_doc_123"
        chunk_index = 0
        
        with patch('app.services.document_chunk_service.DocumentDAO') as MockDocDAO, \
             patch('app.services.document_chunk_service.DocumentChunkDAO') as MockChunkDAO:
            
            mock_doc_dao = MockDocDAO.return_value
            mock_chunk_dao = MockChunkDAO.return_value
            
            # Mock document info
            mock_doc_dao.get_document_file_info = AsyncMock(return_value=("test.pdf", "http://test.com/test.pdf"))
            
            # Mock chunk data
            mock_chunk_data = {
                "text": "Test chunk content",
                "token_count": 1350,
                "embedding_id": "embedding_123"
            }
            mock_chunk_dao.get_document_chunk_by_index = AsyncMock(return_value=mock_chunk_data)
            
            result = await get_document_chunk_by_index(doc_id, chunk_index)
            
            assert "text" in result
            assert "file_name" in result
            assert "file_url" in result
            assert result["file_name"] == "test.pdf"
            assert result["file_url"] == "http://test.com/test.pdf"
            assert result["text"] == "Test chunk content"


if __name__ == "__main__":
    print("Running Simplified QA Flow Checkpoint Tests...")
    print("=" * 60)
    
    # Run tests with verbose output
    pytest.main([__file__, "-v", "--tb=short"])