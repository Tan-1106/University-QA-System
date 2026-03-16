import os
import asyncio
import logging
import time
from fastapi.encoders import jsonable_encoder
from sentence_transformers import CrossEncoder
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

from app.daos.qa_dao import QADao
from app.utils.api_response import UserError
from app.services import embedding_service, document_chunk_service, llm_service


logger = logging.getLogger(__name__)



# --- CONFIGURATION ---
TRANSLATE_MODEL = os.getenv("TRANSLATE_MODEL", "VietAI/envit5-translation")
CROSS_ENCODER_MODEL = os.getenv("CROSS_ENCODER_MODEL", "cross-encoder/mmarco-mMiniLMv2-L12-H384-v1")

translate_tokenizer = AutoTokenizer.from_pretrained(TRANSLATE_MODEL)
translate_model = AutoModelForSeq2SeqLM.from_pretrained(TRANSLATE_MODEL)
cross_encoder_model = CrossEncoder(CROSS_ENCODER_MODEL)


# --- SERVICE FUNCTIONS ---
# Create question record in the database
async def create_question_record(
    question: str,
    user_id: str,
    user_sub: str,
    user_faculty: str
) -> dict:
    question_data = {
        "user_id": user_id,
        "user_sub": user_sub,
        "user_faculty": user_faculty,
        "question": question,
        "answer": None,
        "feedback": None,
        "manager_answer": None
    }
    question_record = await QADao().create_qa_record(question_data)
    return question_record


# Translate question to Vietnamese
async def translate_to_vietnamese(text: str) -> str:
    loop = asyncio.get_event_loop()
    
    def _translate():
        input_text = ["en: " + text]
        inputs = translate_tokenizer(input_text, return_tensors="pt", padding=True)
        output = translate_model.generate(
            inputs.input_ids,
            max_length=512,
            num_beams=5,
            early_stopping=True
        )
        translated = translate_tokenizer.batch_decode(output, skip_special_tokens=True)
        
        return translated[0]
    
    result = await loop.run_in_executor(None, _translate)
    return result


# Get answer for the question (Task 4.5 - Updated to integrate conversation history)
async def get_answer(
    question: str, 
    question_in_vietnamese: str, 
    user_faculty: str, 
    question_language: str,
    session_id: str = None,
    user_id: str = None
) -> tuple[str, str]:
    """
    Get answer for the question with conversation history integration.
    
    Args:
        question: Original user question
        question_in_vietnamese: Question translated to Vietnamese
        user_faculty: User's faculty for filtering
        question_language: Language of the question ('vi' or 'en')
        session_id: Optional conversation session ID (creates new if not provided)
        user_id: User ID for creating new sessions
        
    Returns:
        Tuple of (answer, session_id)
    """
    start_time = time.time()
    
    try:
        api_key = await llm_service.get_current_api_key()
        if not api_key:
            raise UserError("No active API key found. Please activate an API key to proceed.")
        
        # Create new session if not provided
        if not session_id:
            # Import here to avoid circular imports
            from app.services import conversation_service
            session_id = await conversation_service.create_conversation_session(user_id or "system")
        
        # Get conversation history
        from app.services import conversation_service
        conversation_history = await conversation_service.get_conversation_history(session_id, max_turns=10)
        
        # Embed the question
        embed_start = time.time()
        embedded_question = await embedding_service.embed_text(question_in_vietnamese)
        embed_time = time.time() - embed_start
        
        # Find relevant chunks (top 100)
        search_start = time.time()
        relevant_chunk_embeddings = await embedding_service.find_relevant_chunks(
            top_k=100,
            embedding_vector=embedded_question,
            user_faculty=user_faculty
        )
        search_time = time.time() - search_start
        
        # Get chunk content
        chunks = []
        for item in relevant_chunk_embeddings:
            doc_id = item["doc_id"]
            chunk_index = item["chunk_index"]
            chunk = await document_chunk_service.get_document_chunk_by_index(doc_id, chunk_index)
            chunk_content = f"""Tài liệu: {chunk['file_name']}. Nội dung: {chunk['text']}. URL: {chunk['file_url']}"""
            chunks.append(chunk_content)
        
        # Remove duplicates and rerank to top 20
        unique_chunks = list(set(chunks))
        rerank_start = time.time()
        reranked_chunks = rerank_chunks(question_in_vietnamese, unique_chunks, top_k=20)
        rerank_time = time.time() - rerank_start
        
        # Generate answer with conversation history
        llm_start = time.time()
        answer = await llm_service.generate_answer(
            api_key, 
            reranked_chunks, 
            question, 
            question_language,
            conversation_history=conversation_history
        )
        llm_time = time.time() - llm_start
        
        # Append Q&A pair to conversation history
        await conversation_service.append_to_conversation(session_id, question, answer)
        
        total_time = time.time() - start_time
        logger.info(f"QA processing completed - session_id: {session_id}, user_faculty: '{user_faculty}', chunks_found: {len(relevant_chunk_embeddings)}, unique_chunks: {len(unique_chunks)}, embed_time: {embed_time:.3f}s, search_time: {search_time:.3f}s, rerank_time: {rerank_time:.3f}s, llm_time: {llm_time:.3f}s, total_time: {total_time:.3f}s")
        
        return answer, session_id
        
    except Exception as e:
        total_time = time.time() - start_time
        logger.error(f"QA processing failed - session_id: {session_id}, user_faculty: '{user_faculty}', total_time: {total_time:.3f}s, error: {str(e)}")
        raise


# Rerank chunks using Cross-Encoder
def rerank_chunks(question: str, chunks: list[str], top_k: int) -> list[str]:
    start_time = time.time()
    
    try:
        scored_chunks = {}
        for chunk in chunks:
            score = cross_encoder_model.predict([[question, chunk]])[0]
            scored_chunks[chunk] = float(score)
        
        sorted_scored_chunks = sorted(scored_chunks, key=scored_chunks.get, reverse=True)
        top_chunks = sorted_scored_chunks[:top_k]
        
        processing_time = time.time() - start_time
        
        # Structured logging
        logger.info(f"Reranking completed - input_chunks: {len(chunks)}, output_chunks: {len(top_chunks)}, processing_time: {processing_time:.3f}s")
        
        # Debug logging for top chunks with scores
        for i, chunk in enumerate(top_chunks[:5]):  # Log top 5 chunks
            score = scored_chunks[chunk]
            chunk_preview = chunk[:100] + "..." if len(chunk) > 100 else chunk
            logger.debug(f"Rerank #{i+1} (score: {score:.4f}): {chunk_preview}")
        
        return top_chunks
        
    except Exception as e:
        processing_time = time.time() - start_time
        logger.error(f"Reranking failed - input_chunks: {len(chunks)}, processing_time: {processing_time:.3f}s, error: {str(e)}")
        raise


# Update question record with answer
async def update_question_record_with_answer(
    question_id: str,
    answer: str
) -> dict:
    updated_record = await QADao().update_qa_answer(question_id, answer)
    return jsonable_encoder(updated_record)


# Get all question records
async def get_all_question_records(
    page: int,
    limit: int,
    feedback: str,
    faculty: str,
    keyword: str,
    has_manager_answer: bool,
    current_user: dict = None
) -> list[dict]:
    skip = (page - 1) * limit
    total = await QADao().count_all_qa_records(
        feedback,
        faculty,
        keyword,
        has_manager_answer
    )
    total_pages = (total + limit - 1) // limit
    records = await QADao().get_all_question_records(skip, limit, feedback, faculty, keyword, has_manager_answer)
    return {
        "questions": jsonable_encoder(records),
        "total": total,
        "total_pages": total_pages,
        "current_page": page
    }


# Get question records by user ID
async def get_question_records_by_user_id(
    page: int,
    limit: int,
    feedback: str,
    has_manager_answer: bool,
    user_id: str
) -> list[dict]:
    skip = (page - 1) * limit
    total = await QADao().count_qa_records_by_user_id(
        user_id,
        feedback,
        has_manager_answer
    )
    total_pages = (total + limit - 1) // limit    
    records = await QADao().get_question_records_by_user_id(user_id, skip, limit, feedback, has_manager_answer)
    return {
        "questions": jsonable_encoder(records),
        "total": total,
        "total_pages": total_pages,
        "current_page": page
    }
    
    
# Get QA record by ID
async def get_qa_record_by_id(qa_id: str) -> dict:
    qa_record = await QADao().get_qa_record_by_id(qa_id)
    return qa_record


# Leave feedback for a question
async def leave_feedback_for_question(
    qa_record_id: str,
    feedback: str,
    user_id: str
) -> bool:
    success = await QADao().leave_feedback_for_question(qa_record_id, feedback, user_id)
    return success


# Reply to a question
async def reply_to_question(
    qa_record_id: str,
    manager_answer: str
) -> dict:
    updated_record = await QADao().reply_to_question(qa_record_id, manager_answer)
    return jsonable_encoder(updated_record)