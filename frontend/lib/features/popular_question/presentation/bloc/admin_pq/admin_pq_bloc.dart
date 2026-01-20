import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/get_faculties.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_question.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/update_question.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/generate_popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/get_popular_questions_for_admin.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/toggle_question_display_status.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/assign_faculty_scope_to_question.dart';

part 'admin_pq_event.dart';

part 'admin_pq_state.dart';

class AdminPQBloc extends Bloc<AdminPQEvent, AdminPQState> {
  final GeneratePopularQuestionsUseCase _generatePopularQuestions;
  final GetPopularQuestionsForAdminUseCase _getPopularQuestionsForAdmin;
  final GetFacultiesUseCase _getFaculties;
  final AssignFacultyScopeToQuestionUseCase _assignFacultyScopeToQuestion;
  final UpdateQuestionUseCase _updateQuestion;
  final ToggleQuestionDisplayStatusUseCase _toggleQuestionDisplayStatus;

  List<String> _faculties = [];

  AdminPQBloc(
    GeneratePopularQuestionsUseCase generatePopularQuestions,
    GetPopularQuestionsForAdminUseCase getPopularQuestionsForAdmin,
    GetFacultiesUseCase getFaculties,
    AssignFacultyScopeToQuestionUseCase assignFacultyScopeToQuestion,
    UpdateQuestionUseCase updateQuestion,
    ToggleQuestionDisplayStatusUseCase toggleQuestionDisplayStatus,
  ) : _generatePopularQuestions = generatePopularQuestions,
      _getPopularQuestionsForAdmin = getPopularQuestionsForAdmin,
      _getFaculties = getFaculties,
      _assignFacultyScopeToQuestion = assignFacultyScopeToQuestion,
      _updateQuestion = updateQuestion,
      _toggleQuestionDisplayStatus = toggleQuestionDisplayStatus,
      super(const AdminPQInitial()) {
    on<GeneratePopularQuestionsEvent>(_onGeneratePopularQuestions);
    on<GetAdminPopularQuestionsEvent>(_onGetAdminPopularQuestions);
    on<GetFacultiesEvent>(_onGetFaculties);
    on<AssignFacultyScopeEvent>(_onAssignFacultyScope);
    on<UpdateQuestionEvent>(_onUpdateQuestion);
    on<ToggleQuestionDisplayEvent>(_onToggleQuestionDisplay);
  }

  // Generate popular questions
  void _onGeneratePopularQuestions(
    GeneratePopularQuestionsEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    final result = await _generatePopularQuestions(NoParams());

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

  // Get popular questions for admin
  void _onGetAdminPopularQuestions(
    GetAdminPopularQuestionsEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    emit(const AdminPQLoading());

    final result = await _getPopularQuestionsForAdmin(
      GetPopularQuestionsForAdminParams(
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

  // Get list of faculties
  void _onGetFaculties(
    GetFacultiesEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    final result = await _getFaculties(NoParams());

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

  // Assign faculty scope to question
  void _onAssignFacultyScope(
    AssignFacultyScopeEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    final result = await _assignFacultyScopeToQuestion(
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

  // Update question
  void _onUpdateQuestion(
    UpdateQuestionEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    final result = await _updateQuestion(
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

  // Toggle question display status
  void _onToggleQuestionDisplay(
    ToggleQuestionDisplayEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    final result = await _toggleQuestionDisplayStatus(
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
