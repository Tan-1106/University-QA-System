from fastapi.encoders import jsonable_encoder

from app.daos.conversation_dao import ConversationDAO


async def create_conversation_session(user_id: str) -> str:
    """
    Create new conversation session.
    
    Args:
        user_id: User ID
        
    Returns:
        session_id (UUID)
    """
    session_id = await ConversationDAO().create_session(user_id)
    return session_id


async def get_conversation_history(session_id: str, max_turns: int = 10) -> list[dict]:
    """
    Get conversation history for session.
    
    Args:
        session_id: Conversation session ID
        max_turns: Maximum number of turns to return (most recent)
        
    Returns:
        List of {role: 'user'|'assistant', content: str, timestamp: datetime}
    """
    history = await ConversationDAO().get_history(session_id, max_turns)
    return jsonable_encoder(history)


async def append_to_conversation(session_id: str, user_message: str, assistant_message: str) -> bool:
    """
    Append Q&A pair to conversation history.
    
    Args:
        session_id: Conversation session ID
        user_message: User question
        assistant_message: Assistant answer
        
    Returns:
        Success boolean
    """
    # Append user message
    await ConversationDAO().append_message(session_id, "user", user_message)
    
    # Append assistant message
    success = await ConversationDAO().append_message(session_id, "assistant", assistant_message)
    
    return success


async def delete_conversation_session(session_id: str) -> bool:
    """
    Delete conversation session and history.
    
    Args:
        session_id: Conversation session ID
        
    Returns:
        Success boolean
    """
    success = await ConversationDAO().delete_session(session_id)
    return success
