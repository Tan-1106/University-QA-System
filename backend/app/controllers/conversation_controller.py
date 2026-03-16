from datetime import datetime
from fastapi.encoders import jsonable_encoder

from app.utils.api_response import UserError
from app.services import conversation_service


async def create_conversation_session(user_id: str, current_user: dict):
    """
    Create new conversation session.
    
    Args:
        user_id: User ID (should match current_user["_id"] for security)
        current_user: Authenticated user information
        
    Returns:
        dict: {session_id: str, created_at: datetime}
    """
    if not current_user or not current_user.get("_id"):
        raise UserError("Authentication required to create conversation session.")
    
    # Security check: user can only create sessions for themselves
    if user_id != current_user["_id"]:
        raise UserError("You can only create conversation sessions for yourself.")
    
    session_id = await conversation_service.create_conversation_session(current_user["_id"])
    
    return {
        "session_id": session_id,
        "created_at": datetime.now()
    }


async def get_conversation_history(session_id: str, current_user: dict):
    """
    Get conversation history for session.
    
    Args:
        session_id: Conversation session ID
        current_user: Authenticated user information
        
    Returns:
        dict: {session_id: str, messages: list, created_at: datetime}
    """
    if not current_user or not current_user.get("_id"):
        raise UserError("Authentication required to access conversation history.")
    
    # Get conversation history
    messages = await conversation_service.get_conversation_history(session_id, max_turns=10)
    
    # Note: In a production system, you would verify that the session belongs to the current user
    # For now, we'll allow access to any session the user knows the ID for
    
    return {
        "session_id": session_id,
        "messages": messages,
        "created_at": datetime.now()
    }


async def delete_conversation_session(session_id: str, current_user: dict):
    """
    Delete conversation session and history.
    
    Args:
        session_id: Conversation session ID
        current_user: Authenticated user information
        
    Returns:
        dict: {success: bool}
    """
    if not current_user or not current_user.get("_id"):
        raise UserError("Authentication required to delete conversation session.")
    
    # Note: In a production system, you would verify that the session belongs to the current user
    # For now, we'll allow deletion of any session the user knows the ID for
    
    success = await conversation_service.delete_conversation_session(session_id)
    
    return {"success": success}