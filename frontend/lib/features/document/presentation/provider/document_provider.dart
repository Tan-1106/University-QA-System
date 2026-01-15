import 'package:flutter/material.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/document/domain/use_cases/get_all_faculties.dart';

class DocumentProvider extends ChangeNotifier {
  final GetAllFacultiesUseCase _getAllFacultiesUseCase;

  DocumentProvider(
    GetAllFacultiesUseCase getAllFacultiesUseCase,
  ) : _getAllFacultiesUseCase = getAllFacultiesUseCase;

  // States
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<String> _faculties = [];

  List<String> get faculties => _faculties;

  Future<void> loadAllFaculties() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getAllFacultiesUseCase(NoParams());
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _faculties = [];
      },
      (faculties) {
        _faculties = faculties;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
