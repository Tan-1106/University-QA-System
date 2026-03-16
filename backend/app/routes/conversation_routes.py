from fastapi import APIRouter, Depends
from fastapi.encoders import jsonable_encoder

from app.schemas import qa_schema
from app.services import auth_service
from app.controllers import conversation_controller
from app.utils.api_response import api_response


# --- ROUTER ---
router = APIRouter(
    prefix="/qa/conversations",
    tags=["Conversations"],
    dependencies=[Depends(auth_service.get_current_user)]
)


# --- ROUTES ---
# Create new conversation session
@router.post("")
async def create_conversation_session(
    data: qa_schema.CreateConversationSchema,
    current_user = Depends(auth_service.get_current_user)
):
    data = jsonable_encoder(data)
    current_user = jsonable_encoder(current_user)
    result = await conversation_controller.create_conversation_session(data["user_id"], current_user)
    return api_response(
        status_code=201,
        message="Conversation session created successfully.",
        details=result
    )


# Get conversation history
@router.get("/{session_id}")
async def get_conversation_history(
    session_id: str,
    current_user = Depends(auth_service.get_current_user)
):
    current_user = jsonable_encoder(current_user)
    result = await conversation_controller.get_conversation_history(session_id, current_user)
    return api_response(
        status_code=200,
        message="Conversation history retrieved successfully.",
        details=result
    )


# Delete conversation session
@router.delete("/{session_id}")
async def delete_conversation_session(
    session_id: str,
    current_user = Depends(auth_service.get_current_user)
):
    current_user = jsonable_encoder(current_user)
    result = await conversation_controller.delete_conversation_session(session_id, current_user)
    return api_response(
        status_code=200,
        message="Conversation session deleted successfully.",
        details=result
    )
