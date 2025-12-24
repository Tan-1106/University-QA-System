import 'dart:typed_data';
import 'package:university_qa_system/features/document/domain/entities/pdf_bytes.dart';

class PDFBytesData {
  final Uint8List bytes;

  PDFBytesData(this.bytes);

  PDFBytes toEntity() {
    return PDFBytes(bytes);
  }
}