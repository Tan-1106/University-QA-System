import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/dashboard/domain/use_cases/get_questions.dart';
import 'package:university_qa_system/features/dashboard/domain/use_cases/get_statistics.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_question.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/dashboard_statistics.dart';
import 'package:university_qa_system/features/dashboard/domain/use_cases/respond_to_question.dart';


part 'dashboard_event.dart';

part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetStatisticsUseCase _getStatistics;
  final GetQuestionsUseCase _getQuestions;
  final RespondToQuestionUseCase _respondToQuestion;

  DashboardStatisticsEntity? _statistics;
  List<DashboardQuestionEntity> _questions = [];
  int _currentPage = 0;
  int _totalPages = 1;

  DashboardBloc(
    GetStatisticsUseCase getStatistics,
    GetQuestionsUseCase getQuestions,
    RespondToQuestionUseCase respondToQuestion,
  ) : _getStatistics = getStatistics,
      _getQuestions = getQuestions,
      _respondToQuestion = respondToQuestion,
      super(DashboardInitial()) {
    on<GetDashboardStatisticsEvent>(_onGetStatistics);
    on<GetDashboardQuestionsEvent>(_onGetQuestions);
    on<RespondToQuestionEvent>(_onRespondToQuestion);
  }

  // Get dashboard statistics
  void _onGetStatistics(
    GetDashboardStatisticsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await _getStatistics(NoParams());

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (data) {
        _statistics = data;
        emit(DashboardStatisticsLoaded(data));
      },
    );
  }

  // Get list of questions with optional pagination and feedback type filtering
  void _onGetQuestions(
    GetDashboardQuestionsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.isLoadMore) {
      if (state is DashboardDataLoaded) {
        final currentState = state as DashboardDataLoaded;
        if (currentState.isLoadingMore || !currentState.hasMore) return;
        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      _questions = [];
      _currentPage = 0;
    }

    final result = await _getQuestions(
      GetQuestionsParams(
        page: event.page,
        feedbackType: event.feedbackType,
      ),
    );

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (data) {
        if (event.isLoadMore) {
          _questions.addAll(data.questions);
        } else {
          _questions = data.questions;
        }
        _currentPage = data.currentPage;
        _totalPages = data.totalPages;

        if (_statistics != null) {
          emit(DashboardDataLoaded(
            statistics: _statistics!,
            questions: List.from(_questions),
            currentPage: _currentPage,
            totalPages: _totalPages,
            hasMore: _currentPage < _totalPages,
            isLoadingMore: false,
          ));
        } else {
          emit(DashboardQuestionsLoaded(
            questions: List.from(_questions),
            currentPage: _currentPage,
            totalPages: _totalPages,
            hasMore: _currentPage < _totalPages,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  // Respond to a specific question
  void _onRespondToQuestion(
    RespondToQuestionEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await _respondToQuestion(
      RespondToQuestionParams(
        questionId: event.questionId,
        response: event.response,
      ),
    );

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (_) {
        add(GetDashboardQuestionsEvent());
      },
    );
  }
}
