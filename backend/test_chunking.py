import asyncio
import pytest
from app.utils.text_process import chunk_document

@pytest.mark.asyncio
async def test_chunking():
    """
    Test function để kiểm tra chức năng chia chunk mới.
    Kiểm tra xem hệ thống có thể chia tài liệu thành các chunk
    với kích thước từ 1200-1500 tokens và overlap 300-400 tokens không.
    """
    test_text = """CHƯƠNG I: GIỚI THIỆU
    
    Đây là một tài liệu thử nghiệm để kiểm tra chức năng chia chunk mới.
    Chúng ta sẽ kiểm tra xem hệ thống có thể chia tài liệu thành các chunk
    với kích thước từ 1200-1500 tokens và overlap 300-400 tokens không.
    
    ĐIỀU 1: Quy định chung
    
    Các quy định này áp dụng cho toàn bộ hệ thống RAG pipeline.
    Mỗi chunk phải chứa đủ thông tin ngữ cảnh để có thể trả lời câu hỏi.
    
    MỤC 1: Chi tiết kỹ thuật
    
    Hệ thống sử dụng model embedding dangvantuan/vietnamese-embedding
    để tạo vector 768 chiều cho mỗi chunk. Quá trình này không cần
    tạo câu hỏi tiềm năng như trước đây."""
    
    # Gọi hàm chunk_document để chia tài liệu
    chunks = await chunk_document(test_text)
    print(f'Generated {len(chunks)} chunks')
    
    # In thông tin chi tiết của từng chunk
    for i, chunk in enumerate(chunks):
        print(f'Chunk {i}: {chunk["token_count"]} tokens')
        print(f'Text preview: {chunk["text"][:100]}...')
        print('---')

if __name__ == "__main__":
    asyncio.run(test_chunking())