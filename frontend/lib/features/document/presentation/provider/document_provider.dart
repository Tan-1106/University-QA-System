import 'dart:io';

import 'package:flutter/material.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/use_cases/get_existing_filters.dart';
import 'package:university_qa_system/features/document/domain/use_cases/update_document_basic_info.dart';
import 'package:university_qa_system/features/document/domain/use_cases/upload_pdf_document.dart';

class DocumentProvider extends ChangeNotifier {
  final GetExistingFiltersUseCase _getExistingFilters;
  final UploadPDFDocumentUseCase _uploadPDFDocument;
  final UpdateDocumentBasicInfoUseCase _updateDocumentBasicInfo;

  DocumentProvider(
    GetExistingFiltersUseCase getExistingFilters,
    UploadPDFDocumentUseCase uploadPDFDocument,
    UpdateDocumentBasicInfoUseCase updateDocumentBasicInfo,
  ) : _getExistingFilters = getExistingFilters,
      _uploadPDFDocument = uploadPDFDocument,
      _updateDocumentBasicInfo = updateDocumentBasicInfo;

  // States
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<String> _departments = [];

  List<String> get departments => _departments;

  List<String> _documentTypes = [];

  List<String> get documentTypes => _documentTypes;

  List<String> _faculties = [];

  List<String> get faculties => _faculties;

  Future<void> loadAllFilters() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getExistingFilters(NoParams());
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _departments = [];
        _documentTypes = [];
        _faculties = [];
      },
      (filters) {
        _departments = filters.existingDepartments;
        _documentTypes = filters.existingDocumentTypes;
        _faculties = filters.existingFaculties;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDocumentBasicInfo({
    required String documentId,
    String? title,
    String? documentType,
    String? department,
    String? faculty,
    String? fileUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _updateDocumentBasicInfo(
      UpdateDocumentBasicInfoParams(
        documentId: documentId,
        title: title,
        documentType: documentType,
        department: department,
        faculty: faculty,
        fileUrl: fileUrl,
      ),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (success) {
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // Upload document state & event
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  String? _uploadErrorMessage;

  String? get uploadErrorMessage => _uploadErrorMessage;

  Future<void> upload({
    required File file,
    required String docType,
    String? department,
    String? faculty,
    required String fileUrl,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _uploadPDFDocument(
        UploadPDFDocumentParams(
          file: file,
          documentType: docType,
          department: department,
          faculty: faculty,
          fileUrl: fileUrl,
        ),
      );
    } catch (e) {
      _uploadErrorMessage = e.toString();
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
