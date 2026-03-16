from enum import Enum
from bson import ObjectId
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, Field


# Question Schema (Task 4.8 - Updated to support session_id)
class QuestionSchema(BaseModel):
    question: str
    session_id: Optional[str] = None  # Optional session ID for conversation continuity
    class Config:
        from_attributes = True
        extra = "forbid"


# QA Response Schema (Task 4.8 - Updated to include session_id)
class QAResponseSchema(BaseModel):
    question_id: str
    session_id: str  # Always returned for conversation continuity
    question: str
    answer: str
    
    class Config:
        from_attributes = True
        
        
# Question Record Schema
class QARecordSchema(BaseModel):
    id: str = Field(..., alias="_id")
    user_id: str
    user_sub: str
    user_faculty: Optional[str] = None
    question: str
    answer: Optional[str] = None
    feedback: Optional[str] = None
    manager_answer: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
        populate_by_name = True
        json_encoders = { ObjectId: str }
        
        
# Feedback Enum
class Feedback(str, Enum):
    Like = "Like"
    Dislike = "Dislike"
    
    
# Feedback Schema
class FeedbackSchema(BaseModel):
    feedback: str
    class Config:
        from_attributes = True
        extra = "forbid"
        
        
# Manager Answer Schema
class ManagerAnswerSchema(BaseModel):
    manager_answer: str
    class Config:
        from_attributes = True
        extra = "forbid"


# Conversation Schemas
class CreateConversationSchema(BaseModel):
    user_id: str
    
    class Config:
        from_attributes = True
        extra = "forbid"


class ConversationMessageSchema(BaseModel):
    role: str  # 'user' or 'assistant'
    content: str
    timestamp: datetime
    
    class Config:
        from_attributes = True


class ConversationSessionResponseSchema(BaseModel):
    session_id: str
    created_at: datetime
    
    class Config:
        from_attributes = True


class ConversationHistoryResponseSchema(BaseModel):
    session_id: str
    messages: list[ConversationMessageSchema]
    created_at: datetime
    
    class Config:
        from_attributes = True


class ConversationDeleteResponseSchema(BaseModel):
    success: bool
    
    class Config:
        from_attributes = True
