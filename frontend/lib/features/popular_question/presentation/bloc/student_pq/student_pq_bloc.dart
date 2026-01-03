import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_student_popular_questions.dart';

part 'student_pq_event.dart';

part 'student_pq_state.dart';

class StudentPQBloc extends Bloc<StudentPQEvent, StudentPQState> {
  final LoadStudentPopularQuestionsUseCase _loadStudentPopularQuestionsUseCase;

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

    final result = await _loadStudentPopularQuestionsUseCase(
      LoadStudentPopularQuestionsParams(
        facultyOnly: event.facultyOnly,
      ),
    );

    result.fold((failure) => emit(StudentPQError(failure.message)), (data) {
      emit(
        StudentPQLoaded(
          questions: data.popularQuestions,
        ),
      );
    });
  }
}
