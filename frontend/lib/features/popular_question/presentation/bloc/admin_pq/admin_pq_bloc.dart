import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/popular_question/domain/entities/popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_admin_popular_questions.dart';
import 'package:university_qa_system/features/popular_question/domain/use_cases/load_existing_faculties.dart';

import '../../../../../core/use_case/use_case.dart';

part 'admin_pq_event.dart';

part 'admin_pq_state.dart';

class AdminPQBloc extends Bloc<AdminPQEvent, AdminPQState> {
  final LoadAdminPopularQuestionsUseCase _loadAdminPopularQuestionsUseCase;
  final LoadExistingFacultiesUseCase _loadExistingFacultiesUseCase;

  List<PopularQuestion> _allQuestions = [];
  int _currentPage = 0;
  int _totalPages = 1;

  AdminPQBloc(
    LoadAdminPopularQuestionsUseCase loadAdminPopularQuestionsUseCase,
    LoadExistingFacultiesUseCase loadExistingFacultiesUseCase,
  ) : _loadAdminPopularQuestionsUseCase = loadAdminPopularQuestionsUseCase,
      _loadExistingFacultiesUseCase = loadExistingFacultiesUseCase,
      super(AdminPQInitial()) {
    on<GetAdminPopularQuestionsEvent>(_onGetAdminPopularQuestions);
    on<LoadExistingFacultiesEvent>(_onLoadExistingFaculties);
  }

  void _onGetAdminPopularQuestions(
    GetAdminPopularQuestionsEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    emit(AdminPQLoading());

    if (event.isLoadMore) {
      if (state is AdminPQLoaded) {
        final currentState = state as AdminPQLoaded;
        if (currentState.isLoadingMore || !currentState.hasMore) return;
        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      _allQuestions = [];
      _currentPage = 0;
    }

    final result = await _loadAdminPopularQuestionsUseCase(
      LoadAdminPopularQuestionsParams(
        page: event.page,
        isDisplay: event.isDisplay,
        faculty: event.faculty,
      ),
    );

    result.fold((failure) => emit(AdminPQError(failure.message)), (data) {
      if (event.isLoadMore) {
        _allQuestions.addAll(data.popularQuestions);
      } else {
        _allQuestions = data.popularQuestions;
      }
      _currentPage = data.currentPage;
      _totalPages = data.totalPages;

      emit(
        AdminPQLoaded(
          questions: List.from(_allQuestions),
          currentPage: data.currentPage,
          totalPages: data.totalPages,
          hasMore: _currentPage < _totalPages,
          isLoadingMore: false,
        ),
      );
    });
  }

  void _onLoadExistingFaculties(
    LoadExistingFacultiesEvent event,
    Emitter<AdminPQState> emit,
  ) async {
    emit(AdminPQLoading());

    final result = await _loadExistingFacultiesUseCase(NoParams());

    result.fold((failure) => emit(AdminPQError(failure.message)), (data) {
      emit(AdminPQFacultiesLoaded(faculties: data.faculties));
    });
  }
}
