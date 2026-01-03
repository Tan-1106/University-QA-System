import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/generate_popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_admin_popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_existing_faculties.dart';

part 'admin_pq_event.dart';

part 'admin_pq_state.dart';

class AdminPQBloc extends Bloc<AdminPQEvent, AdminPQState> {
  final GeneratePopularQuestionsUseCase _generatePopularQuestionsUseCase;
  final LoadAdminPopularQuestionsUseCase _loadAdminPopularQuestionsUseCase;
  final LoadExistingFacultiesUseCase _loadExistingFacultiesUseCase;

  List<String> _faculties = [];

  AdminPQBloc(
    GeneratePopularQuestionsUseCase generatePopularQuestionsUseCase,
    LoadAdminPopularQuestionsUseCase loadAdminPopularQuestionsUseCase,
    LoadExistingFacultiesUseCase loadExistingFacultiesUseCase,
  ) : _generatePopularQuestionsUseCase = generatePopularQuestionsUseCase,
      _loadAdminPopularQuestionsUseCase = loadAdminPopularQuestionsUseCase,
      _loadExistingFacultiesUseCase = loadExistingFacultiesUseCase,
      super(const AdminPQInitial()) {
    on<GeneratePotentialQuestionsEvent>(_onGeneratePotentialQuestions);
    on<GetAdminPopularQuestionsEvent>(_onGetAdminPopularQuestions);
    on<LoadExistingFacultiesEvent>(_onLoadExistingFaculties);
  }

  void _onGeneratePotentialQuestions(
    GeneratePotentialQuestionsEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    emit(const AdminPQLoading());

    final result = await _generatePopularQuestionsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(AdminPQError(failure.message));
      },
      (success) {
        emit(
          AdminPQDataState(
            questions: const [],
            faculties: _faculties,
          )
        );
      },
    );
  }

  void _onGetAdminPopularQuestions(
    GetAdminPopularQuestionsEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    emit(const AdminPQLoading());

    final result = await _loadAdminPopularQuestionsUseCase(
      LoadAdminPopularQuestionsParams(
        isDisplay: event.isDisplay,
        faculty: event.faculty,
      ),
    );

    result.fold(
      (failure) {
        emit(AdminPQError(failure.message));
      },
      (data) {
        emit(
          AdminPQDataState(
            questions: data.popularQuestions,
            faculties: _faculties,
          ),
        );
      },
    );
  }

  void _onLoadExistingFaculties(
    LoadExistingFacultiesEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    final result = await _loadExistingFacultiesUseCase(NoParams());

    result.fold(
      (failure) {
        emit(AdminPQError(failure.message));
      },
      (data) {
        _faculties = data.faculties;
        emit(
          AdminPQDataState(
            questions: const [],
            faculties: _faculties,
          ),
        );
      },
    );
  }
}
