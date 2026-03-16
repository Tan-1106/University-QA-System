import uuid
from datetime import datetime, timezone, timedelta
from bson import ObjectId

from app.databases import mongo
from app.utils.api_response import DatabaseException


class ConversationDAO:
    def __init__(self):
        self.conversations_collection = mongo.get_conversations_collection()


    async def ensure_indexes(self):
        """
        Ensure required indexes exist on conversations collection.
        Creates TTL index on expires_at for auto-cleanup (24 hours).
        """
        # Create unique index on session_id
        await self.conversations_collection.create_index("session_id", unique=True)
        
        # Create index on user_id for user queries
        await self.conversations_collection.create_index("user_id")
        
        # Create TTL index on expires_at for auto-cleanup after 24 hours
        await self.conversations_collection.create_index(
            "expires_at",
            expireAfterSeconds=0
        )


    async def create_session(self, user_id: str) -> str:
        """
        Create a new conversation session.
        
        Args:
            user_id: User ID
            
        Returns:
            session_id (UUID string)
        """
        session_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc)
        expires_at = now + timedelta(hours=24)
        
        session_record = {
            "session_id": session_id,
            "user_id": user_id,
            "messages": [],
            "created_at": now,
            "updated_at": now,
            "expires_at": expires_at
        }
        
        result = await self.conversations_collection.insert_one(session_record)
        if not result.inserted_id:
            raise DatabaseException("Failed to create conversation session")
        
        return session_id


    async def get_history(self, session_id: str, max_turns: int = 10) -> list[dict]:
        """
        Get conversation history for a session.
        
        Args:
            session_id: Conversation session ID
            max_turns: Maximum number of turns to return (most recent)
            
        Returns:
            List of {role: 'user'|'assistant', content: str, timestamp: datetime}
        """
        session = await self.conversations_collection.find_one({"session_id": session_id})
        if not session:
            raise DatabaseException(f"Conversation session {session_id} not found")
        
        messages = session.get("messages", [])
        
        # Return only the most recent max_turns * 2 messages (each turn = user + assistant)
        max_messages = max_turns * 2
        if len(messages) > max_messages:
            messages = messages[-max_messages:]
        
        return messages


    async def append_message(self, session_id: str, role: str, content: str) -> bool:
        """
        Append a message to conversation history.
        
        Args:
            session_id: Conversation session ID
            role: 'user' or 'assistant'
            content: Message content
            
        Returns:
            Success boolean
        """
        if role not in ["user", "assistant"]:
            raise ValueError(f"Invalid role: {role}. Must be 'user' or 'assistant'")
        
        now = datetime.now(timezone.utc)
        message = {
            "role": role,
            "content": content,
            "timestamp": now
        }
        
        result = await self.conversations_collection.update_one(
            {"session_id": session_id},
            {
                "$push": {"messages": message},
                "$set": {
                    "updated_at": now,
                    "expires_at": now + timedelta(hours=24)  # Extend expiration
                }
            }
        )
        
        if result.matched_count == 0:
            raise DatabaseException(f"Conversation session {session_id} not found")
        
        return result.modified_count > 0


    async def delete_session(self, session_id: str) -> bool:
        """
        Delete a conversation session and its history.
        
        Args:
            session_id: Conversation session ID
            
        Returns:
            Success boolean
        """
        result = await self.conversations_collection.delete_one({"session_id": session_id})
        return result.deleted_count > 0


    async def get_session_by_id(self, session_id: str) -> dict:
        """
        Get full session record by session_id.
        
        Args:
            session_id: Conversation session ID
            
        Returns:
            Session record dictionary
        """
        session = await self.conversations_collection.find_one({"session_id": session_id})
        if not session:
            raise DatabaseException(f"Conversation session {session_id} not found")
        
        # Convert ObjectId to string for JSON serialization
        if "_id" in session:
            session["_id"] = str(session["_id"])
        
        return session


    async def get_user_sessions(self, user_id: str, skip: int = 0, limit: int = 10) -> list[dict]:
        """
        Get all conversation sessions for a user with pagination.
        
        Args:
            user_id: User ID
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List of session records
        """
        cursor = self.conversations_collection.find(
            {"user_id": user_id}
        ).sort("updated_at", -1).skip(skip).limit(limit)
        
        sessions = []
        async for session in cursor:
            if "_id" in session:
                session["_id"] = str(session["_id"])
            sessions.append(session)
        
        return sessions
