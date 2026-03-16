#!/usr/bin/env python3
"""
API Integration Test for QA Flow

This test verifies the API endpoints work correctly by making actual HTTP requests.
Tests the complete QA flow including conversation management.
"""

import asyncio
import httpx
import json
import uuid
from datetime import datetime

# Test configuration
BASE_URL = "http://localhost:8000"
TEST_USER = {
    "email": "test@example.com",
    "password": "testpassword123"
}
TEST_QUESTION = "Quy định về học phí như thế nào?"

class APIIntegrationTest:
    def __init__(self):
        self.client = httpx.AsyncClient(base_url=BASE_URL, timeout=30.0)
        self.auth_token = None
        self.session_id = None
    
    async def setup(self):
        """Setup test environment - authenticate user."""
        try:
            # Try to login with test user
            login_response = await self.client.post("/api/auth/login", json=TEST_USER)
            if login_response.status_code == 200:
                data = login_response.json()
                self.auth_token = data.get("access_token")
                print(f"✓ Authenticated successfully")
                return True
            else:
                print(f"✗ Authentication failed: {login_response.status_code}")
                print(f"Response: {login_response.text}")
                return False
        except Exception as e:
            print(f"✗ Setup failed: {str(e)}")
            return False
    
    def get_headers(self):
        """Get authorization headers."""
        if self.auth_token:
            return {"Authorization": f"Bearer {self.auth_token}"}
        return {}
    
    async def test_conversation_creation(self):
        """Test conversation session creation."""
        try:
            response = await self.client.post(
                "/api/qa/conversations",
                json={"user_id": "test_user"},
                headers=self.get_headers()
            )
            
            if response.status_code == 200:
                data = response.json()
                self.session_id = data.get("session_id")
                print(f"✓ Conversation created: {self.session_id}")
                return True
            else:
                print(f"✗ Conversation creation failed: {response.status_code}")
                print(f"Response: {response.text}")
                return False
        except Exception as e:
            print(f"✗ Conversation creation error: {str(e)}")
            return False
    
    async def test_qa_flow(self):
        """Test the complete QA flow."""
        try:
            qa_request = {
                "question": TEST_QUESTION
            }
            
            if self.session_id:
                qa_request["session_id"] = self.session_id
            
            response = await self.client.post(
                "/api/qa/ask",
                json=qa_request,
                headers=self.get_headers()
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"✓ QA flow successful")
                print(f"  Question: {data.get('question', 'N/A')}")
                print(f"  Answer: {data.get('answer', 'N/A')[:100]}...")
                print(f"  Session ID: {data.get('session_id', 'N/A')}")
                self.session_id = data.get('session_id')  # Update session ID
                return True
            else:
                print(f"✗ QA flow failed: {response.status_code}")
                print(f"Response: {response.text}")
                return False
        except Exception as e:
            print(f"✗ QA flow error: {str(e)}")
            return False
    
    async def test_conversation_history(self):
        """Test conversation history retrieval."""
        if not self.session_id:
            print("✗ No session ID available for history test")
            return False
        
        try:
            response = await self.client.get(
                f"/api/qa/conversations/{self.session_id}",
                headers=self.get_headers()
            )
            
            if response.status_code == 200:
                data = response.json()
                messages = data.get("messages", [])
                print(f"✓ Conversation history retrieved: {len(messages)} messages")
                for i, msg in enumerate(messages):
                    role = msg.get("role", "unknown")
                    content = msg.get("content", "")[:50]
                    print(f"  {i+1}. {role}: {content}...")
                return True
            else:
                print(f"✗ Conversation history failed: {response.status_code}")
                print(f"Response: {response.text}")
                return False
        except Exception as e:
            print(f"✗ Conversation history error: {str(e)}")
            return False
    
    async def test_multiple_questions(self):
        """Test multiple questions in the same conversation."""
        questions = [
            "Quy định về điểm danh như thế nào?",
            "Thời gian học tập được quy định ra sao?"
        ]
        
        for i, question in enumerate(questions):
            try:
                qa_request = {
                    "question": question,
                    "session_id": self.session_id
                }
                
                response = await self.client.post(
                    "/api/qa/ask",
                    json=qa_request,
                    headers=self.get_headers()
                )
                
                if response.status_code == 200:
                    data = response.json()
                    print(f"✓ Question {i+1} answered successfully")
                    print(f"  Q: {question}")
                    print(f"  A: {data.get('answer', 'N/A')[:100]}...")
                else:
                    print(f"✗ Question {i+1} failed: {response.status_code}")
                    return False
            except Exception as e:
                print(f"✗ Question {i+1} error: {str(e)}")
                return False
        
        return True
    
    async def test_faculty_filtering(self):
        """Test faculty filtering in search (if user has faculty)."""
        try:
            # Ask a question that might be faculty-specific
            qa_request = {
                "question": "Quy định về thực tập tốt nghiệp?",
                "session_id": self.session_id
            }
            
            response = await self.client.post(
                "/api/qa/ask",
                json=qa_request,
                headers=self.get_headers()
            )
            
            if response.status_code == 200:
                data = response.json()
                print(f"✓ Faculty filtering test completed")
                print(f"  Answer: {data.get('answer', 'N/A')[:100]}...")
                return True
            else:
                print(f"✗ Faculty filtering test failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"✗ Faculty filtering error: {str(e)}")
            return False
    
    async def cleanup(self):
        """Cleanup test resources."""
        if self.session_id:
            try:
                response = await self.client.delete(
                    f"/api/qa/conversations/{self.session_id}",
                    headers=self.get_headers()
                )
                if response.status_code == 200:
                    print(f"✓ Conversation session cleaned up")
                else:
                    print(f"✗ Cleanup failed: {response.status_code}")
            except Exception as e:
                print(f"✗ Cleanup error: {str(e)}")
        
        await self.client.aclose()
    
    async def run_all_tests(self):
        """Run all integration tests."""
        print("Starting API Integration Tests...")
        print("=" * 50)
        
        # Setup
        if not await self.setup():
            print("✗ Setup failed - skipping tests")
            return False
        
        # Test conversation creation
        if not await self.test_conversation_creation():
            print("✗ Conversation creation failed - skipping remaining tests")
            return False
        
        # Test QA flow
        if not await self.test_qa_flow():
            print("✗ QA flow failed")
            return False
        
        # Test conversation history
        if not await self.test_conversation_history():
            print("✗ Conversation history failed")
            return False
        
        # Test multiple questions
        if not await self.test_multiple_questions():
            print("✗ Multiple questions test failed")
            return False
        
        # Test faculty filtering
        if not await self.test_faculty_filtering():
            print("✗ Faculty filtering test failed")
            return False
        
        # Cleanup
        await self.cleanup()
        
        print("\n" + "=" * 50)
        print("✓ All API integration tests completed successfully!")
        return True


async def main():
    """Main test runner."""
    test = APIIntegrationTest()
    success = await test.run_all_tests()
    
    if success:
        print("\n🎉 QA Flow Checkpoint: PASSED")
        print("The RAG pipeline QA flow is working correctly!")
    else:
        print("\n❌ QA Flow Checkpoint: FAILED")
        print("Some issues were found in the QA flow.")
    
    return success


if __name__ == "__main__":
    asyncio.run(main())