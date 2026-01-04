import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/assign_faculty_scope_to_question.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/generate_popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_admin_popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_existing_faculties.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/toggle_question_display_status.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/update_question.dart';

part 'admin_pq_event.dart';

part 'admin_pq_state.dart';

class AdminPQBloc extends Bloc<AdminPQEvent, AdminPQState> {
  final GeneratePopularQuestionsUseCase _generatePopularQuestionsUseCase;
  final LoadAdminPopularQuestionsUseCase _loadAdminPopularQuestionsUseCase;
  final LoadExistingFacultiesUseCase _loadExistingFacultiesUseCase;
  final AssignFacultyScopeToQuestionUseCase _assignFacultyScopeToQuestionUseCase;
  final UpdateQuestionUseCase _updateQuestionUseCase;
  final ToggleQuestionDisplayStatusUseCase _toggleQuestionDisplayStatusUseCase;

  List<String> _faculties = [];

  AdminPQBloc(
    GeneratePopularQuestionsUseCase generatePopularQuestionsUseCase,
    LoadAdminPopularQuestionsUseCase loadAdminPopularQuestionsUseCase,
    LoadExistingFacultiesUseCase loadExistingFacultiesUseCase,
    AssignFacultyScopeToQuestionUseCase assignFacultyScopeToQuestionUseCase,
    UpdateQuestionUseCase updateQuestionUseCase,
    ToggleQuestionDisplayStatusUseCase toggleQuestionDisplayStatusUseCase,
  ) : _generatePopularQuestionsUseCase = generatePopularQuestionsUseCase,
      _loadAdminPopularQuestionsUseCase = loadAdminPopularQuestionsUseCase,
      _loadExistingFacultiesUseCase = loadExistingFacultiesUseCase,
      _assignFacultyScopeToQuestionUseCase = assignFacultyScopeToQuestionUseCase,
      _updateQuestionUseCase = updateQuestionUseCase,
      _toggleQuestionDisplayStatusUseCase = toggleQuestionDisplayStatusUseCase,
      super(const AdminPQInitial()) {
    on<GeneratePotentialQuestionsEvent>(_onGeneratePotentialQuestions);
    on<GetAdminPopularQuestionsEvent>(_onGetAdminPopularQuestions);
    on<LoadExistingFacultiesEvent>(_onLoadExistingFaculties);
    on<AssignFacultyScopeEvent>(_onAssignFacultyScope);
    on<UpdateQuestionEvent>(_onUpdateQuestion);
    on<ToggleQuestionDisplayEvent>(_onToggleQuestionDisplay);
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
          ),
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

  void _onAssignFacultyScope(
    AssignFacultyScopeEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    final result = await _assignFacultyScopeToQuestionUseCase(
      AssignFacultyScopeToQuestionParams(
        event.questionId,
        event.faculty,
      ),
    );

    result.fold(
      (failure) {
        emit(AdminPQError(failure.message));
      },
      (success) {},
    );
  }

  void _onUpdateQuestion(
    UpdateQuestionEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    final result = await _updateQuestionUseCase(
      UpdateQuestionParams(
        event.questionId,
        event.question,
        event.answer,
      ),
    );

    result.fold(
      (failure) {
        emit(AdminPQError(failure.message));
      },
      (success) {},
    );
  }

  void _onToggleQuestionDisplay(
    ToggleQuestionDisplayEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    final result = await _toggleQuestionDisplayStatusUseCase(
      ToggleQuestionDisplayStatusParams(event.questionId),
    );

    result.fold(
      (failure) {
        emit(AdminPQError(failure.message));
      },
      (success) {},
    );
  }
}
