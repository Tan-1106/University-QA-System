import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_student_popular_questions.dart';

part 'student_pq_event.dart';

part 'student_pq_state.dart';

class StudentPQBloc extends Bloc<StudentPQEvent, StudentPQState> {
  final LoadStudentPopularQuestionsUseCase _loadStudentPopularQuestionsUseCase;

  List<PopularQuestion> _allQuestions = [];
  int _currentPage = 0;
  int _totalPages = 1;

  StudentPQBloc(
    LoadStudentPopularQuestionsUseCase loadStudentPopularQuestionsUseCase,
  ) : _loadStudentPopularQuestionsUseCase = loadStudentPopularQuestionsUseCase,
      super(StudentPQInitial()) {
    on<GetStudentPopularQuestionsEvent>(_onGetStudentPopularQuestions);
  }

  void _onGetStudentPopularQuestions(
    GetStudentPopularQuestionsEvent event,
    Emitter<StudentPQState> emit,
  ) async {
    emit(StudentPQLoading());

    if (event.isLoadMore) {
      if (state is StudentPQLoaded) {
        final currentState = state as StudentPQLoaded;
        if (currentState.isLoadingMore || !currentState.hasMore) return;
        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      _allQuestions = [];
      _currentPage = 0;
    }

    final result = await _loadStudentPopularQuestionsUseCase(
      LoadStudentPopularQuestionsParams(
        page: event.page,
        facultyOnly: event.facultyOnly,
      ),
    );

    result.fold((failure) => emit(StudentPQError(failure.message)), (data) {
      if (event.isLoadMore) {
        _allQuestions.addAll(data.popularQuestions);
      } else {
        _allQuestions = data.popularQuestions;
      }
      _currentPage = data.currentPage;
      _totalPages = data.totalPages;

      emit(
        StudentPQLoaded(
          questions: List.from(_allQuestions),
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          hasMore: _currentPage < _totalPages,
          isLoadingMore: false,
        ),
      );
    });
  }
}
