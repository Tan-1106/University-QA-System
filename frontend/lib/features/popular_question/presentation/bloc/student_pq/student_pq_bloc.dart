import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_question.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/get_popular_questions_for_student.dart';

part 'student_pq_event.dart';

part 'student_pq_state.dart';

class StudentPQBloc extends Bloc<StudentPQEvent, StudentPQState> {
  final GetPopularQuestionsForStudentUseCase _getPopularQuestionsForStudent;

  StudentPQBloc(
    GetPopularQuestionsForStudentUseCase getPopularQuestionsForStudent,
  ) : _getPopularQuestionsForStudent = getPopularQuestionsForStudent,
      super(StudentPQInitial()) {
    on<GetStudentPopularQuestionsEvent>(_onGetPopularQuestionsForStudent);
  }

  // Get popular questions for students
  void _onGetPopularQuestionsForStudent(
    GetStudentPopularQuestionsEvent event,
    Emitter<StudentPQState> emit,
  ) async {
    emit(StudentPQLoading());

    final result = await _getPopularQuestionsForStudent(
      GetPopularQuestionsForStudentParams(
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
