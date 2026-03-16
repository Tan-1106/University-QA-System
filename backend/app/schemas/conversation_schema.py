from bson import ObjectId
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, Field


# Create Conversation Session Schema
class CreateConversationSchema(BaseModel):
    user_id: str
    
    class Config:
        from_attributes = True
        extra = "forbid"


# Conversation Message Schema
class ConversationMessageSchema(BaseModel):
    role: str
    content: str
    timestamp: datetime
    
    class Config:
        from_attributes = True


# Conversation Session Schema
class ConversationSessionSchema(BaseModel):
    id: str = Field(..., alias="_id")
    session_id: str
    user_id: str
    messages: list[ConversationMessageSchema]
    created_at: datetime
    updated_at: datetime
    expires_at: datetime
    
    class Config:
        from_attributes = True
        populate_by_name = True
        json_encoders = { ObjectId: str }
