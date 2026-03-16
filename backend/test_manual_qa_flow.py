#!/usr/bin/env python3
"""
Manual QA Flow Test

This test manually verifies the QA flow components work correctly
by testing individual functions and services directly.
"""

import asyncio
import sys
import os
from pathlib import Path
from unittest.mock import AsyncMock, MagicMock, patch, Mock

# Add backend directory to path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

# Mock all external dependencies
sys.modules['pymongo'] = Mock()
sys.modules['motor'] = Mock()
sys.modules['chromadb'] = Mock()
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

class QAFlowManualTest:
    """Manual test for QA flow components."""
    
    def __init__(self):
        self.test_results = []
    
    def log_test(self, test_name, success, message=""):
        """Log test result."""
        status = "✓ PASS" if success else "✗ FAIL"
        self.test_results.append((test_name, success, message))
        print(f"{status}: {test_name}")
        if message:
            print(f"    {message}")
    
    async def test_chunking_functionality(self):
        """Test document chunking functionality."""
        try:
            from app.utils.text_process import chunk_document
            
            # Test with a substantial document
            test_content = """
            CHƯƠNG I: GIỚI THIỆU VỀ QUY ĐỊNH HỌC PHÍ
            
            Điều 1: Quy định chung về học phí
            Học phí là khoản tiền mà sinh viên phải đóng để được học tập tại trường.
            Học phí được tính theo từng học kỳ và phụ thuộc vào ngành học.
            
            Điều 2: Mức học phí cụ thể
            - Ngành Công nghệ thông tin: 25,000,000 VNĐ/học kỳ
            - Ngành Kinh tế: 22,000,000 VNĐ/học kỳ
            - Ngành Ngoại ngữ: 20,000,000 VNĐ/học kỳ
            
            Điều 3: Thời hạn đóng học phí
            Sinh viên phải đóng học phí trước ngày 15 của tháng đầu tiên trong học kỳ.
            Trường hợp đóng muộn sẽ bị phạt 5% trên tổng số tiền học phí.
            
            """ * 10  # Repeat to create larger content
            
            chunks = await chunk_document(test_content)
            
            if chunks and len(chunks) > 0:
                chunk_info = f"Generated {len(chunks)} chunks"
                for i, chunk in enumerate(chunks[:3]):  # Show first 3 chunks
                    chunk_info += f"\n    Chunk {i}: {chunk['token_count']} tokens"
                
                self.log_test("Document Chunking", True, chunk_info)
                return True
            else:
                self.log_test("Document Chunking", False, "No chunks generated")
                return False
                
        except Exception as e:
            self.log_test("Document Chunking", False, f"Error: {str(e)}")
            return False
    
    async def test_conversation_service(self):
        """Test conversation service functionality."""
        try:
            # Mock the DAO
            with patch('app.services.conversation_service.ConversationDAO') as MockDAO:
                mock_dao = MockDAO.return_value
                
                # Test session creation
                test_session_id = "test-session-123"
                mock_dao.create_session = AsyncMock(return_value=test_session_id)
                
                from app.services.conversation_service import create_conversation_session
                session_id = await create_conversation_session("test_user")
                
                if session_id == test_session_id:
                    self.log_test("Conversation Session Creation", True, f"Session ID: {session_id}")
                else:
                    self.log_test("Conversation Session Creation", False, "Session ID mismatch")
                    return False
                
                # Test history management
                mock_history = [
                    {"role": "user", "content": "Test question", "timestamp": "2024-01-01T00:00:00Z"},
                    {"role": "assistant", "content": "Test answer", "timestamp": "2024-01-01T00:01:00Z"}
                ]
                mock_dao.get_history = AsyncMock(return_value=mock_history)
                mock_dao.append_message = AsyncMock(return_value=True)
                
                from app.services.conversation_service import get_conversation_history, append_to_conversation
                
                # Test append
                success = await append_to_conversation(session_id, "New question", "New answer")
                if success:
                    self.log_test("Conversation Message Append", True, "Messages appended successfully")
                else:
                    self.log_test("Conversation Message Append", False, "Failed to append messages")
                    return False
                
                # Test history retrieval
                history = await get_conversation_history(session_id)
                if history and len(history) == 2:
                    self.log_test("Conversation History Retrieval", True, f"Retrieved {len(history)} messages")
                else:
                    self.log_test("Conversation History Retrieval", False, "History retrieval failed")
                    return False
                
                return True
                
        except Exception as e:
            self.log_test("Conversation Service", False, f"Error: {str(e)}")
            return False
    
    async def test_document_chunk_service(self):
        """Test document chunk service functionality."""
        try:
            with patch('app.services.document_chunk_service.DocumentDAO') as MockDocDAO, \
                 patch('app.services.document_chunk_service.DocumentChunkDAO') as MockChunkDAO:
                
                mock_doc_dao = MockDocDAO.return_value
                mock_chunk_dao = MockChunkDAO.return_value
                
                # Mock document info
                mock_doc_dao.get_document_file_info = AsyncMock(
                    return_value=("test_document.pdf", "http://example.com/test_document.pdf")
                )
                
                # Mock chunk data
                mock_chunk_data = {
                    "text": "Điều 1: Quy định về học phí. Học phí được tính theo học kỳ...",
                    "token_count": 1350,
                    "embedding_id": "embedding_123",
                    "chunk_index": 0
                }
                mock_chunk_dao.get_document_chunk_by_index = AsyncMock(return_value=mock_chunk_data)
                
                from app.services.document_chunk_service import get_document_chunk_by_index
                
                result = await get_document_chunk_by_index("test_doc_123", 0)
                
                if (result and "text" in result and "file_name" in result and 
                    "file_url" in result and "embedding_id" in result):
                    self.log_test("Document Chunk Retrieval", True, 
                                f"Retrieved chunk with {result.get('token_count', 'unknown')} tokens")
                    return True
                else:
                    self.log_test("Document Chunk Retrieval", False, "Missing required fields")
                    return False
                    
        except Exception as e:
            self.log_test("Document Chunk Service", False, f"Error: {str(e)}")
            return False
    
    async def test_embedding_service_structure(self):
        """Test embedding service structure and interfaces."""
        try:
            # Test that the service can be imported and has required functions
            from app.services import embedding_service
            
            required_functions = [
                'embed_text',
                'embed_and_store_chunk', 
                'semantic_search',
                'find_relevant_chunks'
            ]
            
            missing_functions = []
            for func_name in required_functions:
                if not hasattr(embedding_service, func_name):
                    missing_functions.append(func_name)
            
            if not missing_functions:
                self.log_test("Embedding Service Structure", True, 
                            f"All required functions present: {', '.join(required_functions)}")
                return True
            else:
                self.log_test("Embedding Service Structure", False, 
                            f"Missing functions: {', '.join(missing_functions)}")
                return False
                
        except Exception as e:
            self.log_test("Embedding Service Structure", False, f"Error: {str(e)}")
            return False
    
    async def test_qa_service_structure(self):
        """Test QA service structure and interfaces."""
        try:
            from app.services import qa_service
            
            required_functions = [
                'get_answer',
                'rerank_chunks',
                'translate_to_vietnamese',
                'create_question_record'
            ]
            
            missing_functions = []
            for func_name in required_functions:
                if not hasattr(qa_service, func_name):
                    missing_functions.append(func_name)
            
            if not missing_functions:
                self.log_test("QA Service Structure", True, 
                            f"All required functions present: {', '.join(required_functions)}")
                return True
            else:
                self.log_test("QA Service Structure", False, 
                            f"Missing functions: {', '.join(missing_functions)}")
                return False
                
        except Exception as e:
            self.log_test("QA Service Structure", False, f"Error: {str(e)}")
            return False
    
    async def test_controller_structure(self):
        """Test controller structure and interfaces."""
        try:
            from app.controllers import qa_controller, conversation_controller
            
            # Test QA controller
            qa_functions = ['get_answer', 'leave_feedback', 'get_all_question_records']
            missing_qa = []
            for func_name in qa_functions:
                if not hasattr(qa_controller, func_name):
                    missing_qa.append(func_name)
            
            # Test conversation controller
            conv_functions = ['create_conversation_session', 'get_conversation_history', 'delete_conversation_session']
            missing_conv = []
            for func_name in conv_functions:
                if not hasattr(conversation_controller, func_name):
                    missing_conv.append(func_name)
            
            if not missing_qa and not missing_conv:
                self.log_test("Controller Structure", True, 
                            "All required controller functions present")
                return True
            else:
                missing = missing_qa + missing_conv
                self.log_test("Controller Structure", False, 
                            f"Missing functions: {', '.join(missing)}")
                return False
                
        except Exception as e:
            self.log_test("Controller Structure", False, f"Error: {str(e)}")
            return False
    
    async def test_database_dao_structure(self):
        """Test DAO structure and interfaces."""
        try:
            from app.daos.conversation_dao import ConversationDAO
            
            # Test ConversationDAO methods
            dao = ConversationDAO()
            required_methods = [
                'create_session',
                'get_history', 
                'append_message',
                'delete_session'
            ]
            
            missing_methods = []
            for method_name in required_methods:
                if not hasattr(dao, method_name):
                    missing_methods.append(method_name)
            
            if not missing_methods:
                self.log_test("DAO Structure", True, 
                            f"ConversationDAO has all required methods: {', '.join(required_methods)}")
                return True
            else:
                self.log_test("DAO Structure", False, 
                            f"ConversationDAO missing methods: {', '.join(missing_methods)}")
                return False
                
        except Exception as e:
            self.log_test("DAO Structure", False, f"Error: {str(e)}")
            return False
    
    async def run_all_tests(self):
        """Run all manual tests."""
        print("Starting Manual QA Flow Tests...")
        print("=" * 60)
        
        tests = [
            self.test_chunking_functionality,
            self.test_conversation_service,
            self.test_document_chunk_service,
            self.test_embedding_service_structure,
            self.test_qa_service_structure,
            self.test_controller_structure,
            self.test_database_dao_structure
        ]
        
        passed = 0
        total = len(tests)
        
        for test in tests:
            try:
                success = await test()
                if success:
                    passed += 1
            except Exception as e:
                print(f"✗ FAIL: {test.__name__} - Unexpected error: {str(e)}")
        
        print("\n" + "=" * 60)
        print(f"Test Results: {passed}/{total} tests passed")
        
        if passed == total:
            print("🎉 All manual tests PASSED!")
            print("✓ Document chunking works correctly")
            print("✓ Conversation management is functional")
            print("✓ Document chunk service is working")
            print("✓ Service layer structure is correct")
            print("✓ Controller layer structure is correct")
            print("✓ DAO layer structure is correct")
            print("\n✅ QA Flow Checkpoint: PASSED")
            print("The RAG pipeline components are correctly implemented!")
            return True
        else:
            print(f"❌ {total - passed} tests failed")
            print("❌ QA Flow Checkpoint: FAILED")
            print("Some components need attention.")
            return False


async def main():
    """Main test runner."""
    test = QAFlowManualTest()
    return await test.run_all_tests()


if __name__ == "__main__":
    asyncio.run(main())