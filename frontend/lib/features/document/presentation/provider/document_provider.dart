import 'package:flutter/material.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/use_cases/get_existing_filters.dart';
import 'package:university_qa_system/features/document/domain/use_cases/update_document_basic_info.dart';

class DocumentProvider extends ChangeNotifier {
  final GetExistingFiltersUseCase _getExistingFilters;
  final UpdateDocumentBasicInfoUseCase _updateDocumentBasicInfo;

  DocumentProvider(
    GetExistingFiltersUseCase getExistingFilters,
    UpdateDocumentBasicInfoUseCase updateDocumentBasicInfo,
  ) : _getExistingFilters = getExistingFilters,
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
}
