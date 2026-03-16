import pytest
import uuid
from datetime import datetime
from unittest.mock import AsyncMock, MagicMock, patch, Mock
import sys
from pathlib import Path

# Add backend directory to path
backend_dir = Path(__file__).parent.parent.parent
sys.path.insert(0, str(backend_dir))

# Mock the database dependencies before importing
sys.modules['app.databases'] = Mock()
sys.modules['app.databases.mongo'] = Mock()

from app.services.conversation_service import (
    create_conversation_session,
    get_conversation_history,
    append_to_conversation,
    delete_conversation_session
)

# Create a simple DatabaseException class for testing
class DatabaseException(Exception):
    pass


@pytest.mark.asyncio
async def test_create_conversation_session_returns_uuid():
    """Unit test: create_conversation_session should return a valid UUID string."""
    user_id = "test_user_123"
    
    with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
        mock_dao_instance = MockDAO.return_value
        mock_session_id = str(uuid.uuid4())
        mock_dao_instance.create_session = AsyncMock(return_value=mock_session_id)
        
        session_id = await create_conversation_session(user_id)
        
        assert isinstance(session_id, str)
        assert len(session_id) == 36  # UUID format
        mock_dao_instance.create_session.assert_called_once_with(user_id)


@pytest.mark.asyncio
async def test_get_conversation_history_returns_list():
    """Unit test: get_conversation_history should return a list of messages."""
    session_id = str(uuid.uuid4())
    mock_history = [
        {"role": "user", "content": "Hello", "timestamp": datetime.now()},
        {"role": "assistant", "content": "Hi there!", "timestamp": datetime.now()}
    ]
    
    with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
        mock_dao_instance = MockDAO.return_value
        mock_dao_instance.get_history = AsyncMock(return_value=mock_history)
        
        history = await get_conversation_history(session_id, max_turns=10)
        
        assert isinstance(history, list)
        assert len(history) == 2
        mock_dao_instance.get_history.assert_called_once_with(session_id, 10)


@pytest.mark.asyncio
async def test_get_conversation_history_with_custom_max_turns():
    """Unit test: get_conversation_history should respect max_turns parameter."""
    session_id = str(uuid.uuid4())
    mock_history = [
        {"role": "user", "content": "Question 1", "timestamp": datetime.now()},
        {"role": "assistant", "content": "Answer 1", "timestamp": datetime.now()}
    ]
    
    with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
        mock_dao_instance = MockDAO.return_value
        mock_dao_instance.get_history = AsyncMock(return_value=mock_history)
        
        history = await get_conversation_history(session_id, max_turns=5)
        
        mock_dao_instance.get_history.assert_called_once_with(session_id, 5)


@pytest.mark.asyncio
async def test_append_to_conversation_success():
    """Unit test: append_to_conversation should append both user and assistant messages."""
    session_id = str(uuid.uuid4())
    user_message = "What is the weather?"
    assistant_message = "It's sunny today."
    
    with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
        mock_dao_instance = MockDAO.return_value
        mock_dao_instance.append_message = AsyncMock(return_value=True)
        
        success = await append_to_conversation(session_id, user_message, assistant_message)
        
        assert success is True
        assert mock_dao_instance.append_message.call_count == 2
        mock_dao_instance.append_message.assert_any_call(session_id, "user", user_message)
        mock_dao_instance.append_message.assert_any_call(session_id, "assistant", assistant_message)


@pytest.mark.asyncio
async def test_append_to_conversation_returns_false_on_failure():
    """Unit test: append_to_conversation should return False if assistant message append fails."""
    session_id = str(uuid.uuid4())
    user_message = "Test question"
    assistant_message = "Test answer"
    
    with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
        mock_dao_instance = MockDAO.return_value
        # First call (user message) succeeds, second call (assistant message) fails
        mock_dao_instance.append_message = AsyncMock(side_effect=[True, False])
        
        success = await append_to_conversation(session_id, user_message, assistant_message)
        
        assert success is False


@pytest.mark.asyncio
async def test_delete_conversation_session_success():
    """Unit test: delete_conversation_session should return True on successful deletion."""
    session_id = str(uuid.uuid4())
    
    with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
        mock_dao_instance = MockDAO.return_value
        mock_dao_instance.delete_session = AsyncMock(return_value=True)
        
        success = await delete_conversation_session(session_id)
        
        assert success is True
        mock_dao_instance.delete_session.assert_called_once_with(session_id)


@pytest.mark.asyncio
async def test_delete_conversation_session_not_found():
    """Unit test: delete_conversation_session should return False if session not found."""
    session_id = str(uuid.uuid4())
    
    with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
        mock_dao_instance = MockDAO.return_value
        mock_dao_instance.delete_session = AsyncMock(return_value=False)
        
        success = await delete_conversation_session(session_id)
        
        assert success is False


@pytest.mark.asyncio
async def test_get_conversation_history_session_not_found():
    """Unit test: get_conversation_history should raise DatabaseException if session not found."""
    session_id = str(uuid.uuid4())
    
    with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
        mock_dao_instance = MockDAO.return_value
        mock_dao_instance.get_history = AsyncMock(
            side_effect=DatabaseException(f"Conversation session {session_id} not found")
        )
        
        with pytest.raises(DatabaseException):
            await get_conversation_history(session_id)


@pytest.mark.asyncio
async def test_append_to_conversation_session_not_found():
    """Unit test: append_to_conversation should raise DatabaseException if session not found."""
    session_id = str(uuid.uuid4())
    user_message = "Test question"
    assistant_message = "Test answer"
    
    with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
        mock_dao_instance = MockDAO.return_value
        mock_dao_instance.append_message = AsyncMock(
            side_effect=DatabaseException(f"Conversation session {session_id} not found")
        )
        
        with pytest.raises(DatabaseException):
            await append_to_conversation(session_id, user_message, assistant_message)
