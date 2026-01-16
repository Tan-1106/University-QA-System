import 'package:flutter/material.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/use_cases/get_existing_filters.dart';

class DocumentProvider extends ChangeNotifier {
  final GetExistingFiltersUseCase _getExistingFiltersUseCase;

  DocumentProvider(
    GetExistingFiltersUseCase getExistingFiltersUseCase,
  ) : _getExistingFiltersUseCase = getExistingFiltersUseCase;

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

    final result = await _getExistingFiltersUseCase(NoParams());
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
}
