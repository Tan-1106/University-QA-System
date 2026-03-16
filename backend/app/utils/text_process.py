import re
import ast
import json
import fitz
import camelot
import pdfplumber
from tiktoken import get_encoding
from langchain_text_splitters import RecursiveCharacterTextSplitter


# --- CONFIGURATION ---
enc = get_encoding("cl100k_base")


# --- SUPPORTING FUNCTIONS ---
# Normalize table cell content
def normalize_cell(x):
    x = str(x)
    x = re.sub(r'[\n\r\t]+', '', x)
    x = re.sub(r'\s{2,}', ' ', x)
    return x.strip()


# Normalize text input
def normalize_text(text: str):
    if isinstance(text, str):
        cleaned = text.strip()
        if cleaned.startswith("```"):
            cleaned = re.sub(r"^```(?:python)?|```$", "", cleaned, flags=re.IGNORECASE).strip()
        try:
            data = json.loads(cleaned)
        except Exception:
            try:
                data = ast.literal_eval(cleaned)
            except Exception:
                data = cleaned
    else:
        data = text

    if isinstance(data, list):
        out = []
        for item in data:
            if isinstance(item, str):
                s = re.sub(r"[ \t]+", " ", item).strip()
                out.append(s)
        return out

    if isinstance(data, str):
        return re.sub(r"[ \t]+", " ", data).strip()

    return data


# Extract appendix description from PDF
def extract_appendix_description(path: str) -> str:
    tables = camelot.read_pdf(path, pages='all', flavor='lattice')
    
    if not tables:
        with pdfplumber.open(path) as pdf:
            return '\n\n'.join(page.extract_text() or '' for page in pdf.pages).strip()
    
    tables_sorted = sorted(tables, key=lambda t: (t.page, -t._bbox[3]))
    first_table = tables_sorted[0]
    first_page_num = first_table.page
    
    with pdfplumber.open(path) as pdf:
        description_parts = []
        
        for page_idx in range(first_page_num - 1):
            page = pdf.pages[page_idx]
            text = page.extract_text() or ''
            description_parts.append(text)
        
        page = pdf.pages[first_page_num - 1]
        page_height = page.height
        
        cam_x0, cam_y0_bottom, cam_x1, cam_y1_top = first_table._bbox
        plumb_y0_top = page_height - cam_y1_top
        
        cropped_page = page.crop((0, 0, page.width, plumb_y0_top))
        above_text = cropped_page.extract_text() or ''
        description_parts.append(above_text)
        
        full_description = '\n\n'.join(description_parts).strip()
        
    return full_description


# Merge small chunks into larger ones
async def merge_chunks(chunks: list[str], target_max_length: int) -> list[str]:
    # First pass: merge small chunks
    merged_chunks = []
    current_chunk = ""
    for chunk in chunks:
        if len(enc.encode(current_chunk + " " + chunk)) <= target_max_length:
            if current_chunk:
                current_chunk += " " + chunk
            else:
                current_chunk = chunk
        else:
            if current_chunk:
                merged_chunks.append(current_chunk.strip())
            current_chunk = chunk
    if current_chunk:
        merged_chunks.append(current_chunk.strip())

    # Second pass: ensure no chunks are too small
    final_chunks = []
    buffer = ""
    for chunk in merged_chunks:
        if len(enc.encode(chunk)) < target_max_length * 0.5:
            if buffer:
                buffer += " " + chunk
            else:
                buffer = chunk
        else:
            if buffer:
                final_chunks.append(buffer.strip())
                buffer = ""
            final_chunks.append(chunk.strip())
    if buffer:
        final_chunks.append(buffer.strip())
    return final_chunks


# check if PDF is text-based
def is_text_based_pdf(file_path: str) -> bool:
    try:
        doc = fitz.open(file_path)
        for page in doc:
            page_text = page.get_text().strip()
            if page_text:
                doc.close()
                return True
        doc.close()
        return False
    except Exception as e:
        raise RuntimeError("Failed to process PDF file.") from e
    
    
# Split text into chunks for embedding
async def split_text_into_chunks(text: str, words_per_chunk: int, overlap: int) -> list[str]:
    text = text.strip()
    chunks = []
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=words_per_chunk,
        chunk_overlap=overlap,
        separators=[
            "CHƯƠNG", "Chương",
            "ĐIỀU", "Điều",
            "MỤC", "Mục",
            "I.", "II.", "III.", "IV.", "V.", "VI.", "VII.", "VIII.", "IX.", "X.", "XI.", "XII.", "XIII.", "XIV.", "XV.", "XVI.", "XVII.", "XVIII.", "XIX.", "XX.",
            "1.", "2.", "3.", "4.", "5.", "6.", "7.", "8.", "9.", "10.", "11.", "12.", "13.", "14.", "15.", "16.", "17.", "18.", "19.", "20.",
            "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", "(8)", "(9)", "(10)", "(11)", "(12)", "(13)", "(14)", "(15)", "(16)", "(17)", "(18)", "(19)", "(20)",
            ";", ".", "\n\n", "\n", " ", ""
            
        ],
        length_function=lambda x: len(enc.encode(x))
    )
    chunks = splitter.split_text(text)
    chunks = await merge_chunks(chunks, target_max_length=words_per_chunk)
    return chunks


# New chunking strategy with semantic boundaries (Task 2.1)
async def chunk_document(
    content: str,
    chunk_size_tokens: int = 1400,  # Target: 1200-1500
    overlap_tokens: int = 350,       # Target: 300-400
    preserve_semantic_boundaries: bool = True
) -> list[dict]:
    """
    Chunk document content into overlapping segments with semantic boundaries.
    
    Args:
        content: Full document text
        chunk_size_tokens: Target chunk size in tokens (1200-1500)
        overlap_tokens: Overlap between consecutive chunks (300-400)
        preserve_semantic_boundaries: Try to split at paragraph/section boundaries
        
    Returns:
        List of chunk dictionaries with 'text', 'token_count', and 'chunk_index'
    """
    content = content.strip()
    if not content:
        return []
    
    # Use RecursiveCharacterTextSplitter with semantic separators
    separators = [
        "CHƯƠNG", "Chương",
        "ĐIỀU", "Điều", 
        "MỤC", "Mục",
        "I.", "II.", "III.", "IV.", "V.", "VI.", "VII.", "VIII.", "IX.", "X.", 
        "XI.", "XII.", "XIII.", "XIV.", "XV.", "XVI.", "XVII.", "XVIII.", "XIX.", "XX.",
        "1.", "2.", "3.", "4.", "5.", "6.", "7.", "8.", "9.", "10.", 
        "11.", "12.", "13.", "14.", "15.", "16.", "17.", "18.", "19.", "20.",
        "(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)", "(8)", "(9)", "(10)",
        "\n\n", "\n", ".", ";", " ", ""
    ]
    
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size_tokens,
        chunk_overlap=overlap_tokens,
        separators=separators,
        length_function=lambda x: len(enc.encode(x))
    )
    
    text_chunks = splitter.split_text(content)
    
    # Convert to chunk dictionaries with metadata
    chunks = []
    for i, chunk_text in enumerate(text_chunks):
        token_count = len(enc.encode(chunk_text))
        chunks.append({
            "text": chunk_text.strip(),
            "token_count": token_count,
            "chunk_index": i
        })
    
    return chunks


# Split appendix description and tables into chunks
async def split_appendix_into_chunks(description: str, tables: list[list[str]], table_header_rows: int) -> list[str]:
    chunks = []
    chunk_format = f"Description: {description}. Table header: "
    for i in range(0, table_header_rows):
        chunk_format += ' | '.join(tables[i])
        
    for i in range(table_header_rows, len(tables)):
        chunk = chunk_format + '. Content: ' + ' | '.join(tables[i])
        chunks.append(chunk)
        
    return chunks


# New appendix chunking with table preservation (Task 2.2)
async def chunk_appendix_document(
    description: str,
    tables: list[list[str]],
    table_header_rows: int = 2
) -> list[dict]:
    """
    Chunk appendix documents preserving table structure.
    
    Args:
        description: Appendix description text
        tables: List of table data (rows)
        table_header_rows: Number of header rows in tables
        
    Returns:
        List of chunk dictionaries with table data preserved
    """
    chunks = []
    
    if not tables:
        # If no tables, just chunk the description normally
        return await chunk_document(description)
    
    # Prepare table header
    table_header = ""
    for i in range(min(table_header_rows, len(tables))):
        table_header += ' | '.join(str(cell) for cell in tables[i]) + '\n'
    
    # Create chunks with complete table rows
    chunk_base = f"Description: {description}\n\nTable header:\n{table_header}\nTable content:\n"
    
    current_chunk_rows = []
    current_token_count = len(enc.encode(chunk_base))
    
    # Process data rows (skip header rows)
    for i in range(table_header_rows, len(tables)):
        row = tables[i]
        row_text = ' | '.join(str(cell) for cell in row) + '\n'
        row_tokens = len(enc.encode(row_text))
        
        # Check if adding this row would exceed token limit
        if current_token_count + row_tokens > 1500 and current_chunk_rows:
            # Create chunk with current rows
            chunk_content = chunk_base + ''.join(current_chunk_rows)
            chunks.append({
                "text": chunk_content.strip(),
                "token_count": current_token_count,
                "chunk_index": len(chunks)
            })
            
            # Start new chunk
            current_chunk_rows = [row_text]
            current_token_count = len(enc.encode(chunk_base + row_text))
        else:
            # Add row to current chunk
            current_chunk_rows.append(row_text)
            current_token_count += row_tokens
    
    # Add final chunk if there are remaining rows
    if current_chunk_rows:
        chunk_content = chunk_base + ''.join(current_chunk_rows)
        chunks.append({
            "text": chunk_content.strip(),
            "token_count": current_token_count,
            "chunk_index": len(chunks)
        })
    
    return chunks