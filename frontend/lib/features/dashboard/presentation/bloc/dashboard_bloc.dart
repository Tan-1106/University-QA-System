import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/core/use_case/use_case.dart';
import 'package:university_qa_system/features/dashboard/data/models/question_records_data.dart';
import 'package:university_qa_system/features/dashboard/domain/entities/statistic.dart';
import 'package:university_qa_system/features/dashboard/domain/use_cases/load_dashboard_question_records.dart';
import 'package:university_qa_system/features/dashboard/domain/use_cases/load_dashboard_statistic.dart';

part 'dashboard_event.dart';

part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final LoadDashboardStatisticUseCase _loadDashboardStatistic;
  final LoadDashboardQuestionRecordsUseCase _loadDashboardQuestionRecords;

  Statistic? _statisticData;
  List<Questions> _allQuestions = [];
  int _currentPage = 0;
  int _totalPages = 1;

  DashboardBloc(
    LoadDashboardStatisticUseCase loadDashboardStatistic,
    LoadDashboardQuestionRecordsUseCase loadDashboardQuestionRecords,
  ) : _loadDashboardStatistic = loadDashboardStatistic,
      _loadDashboardQuestionRecords = loadDashboardQuestionRecords,
      super(DashboardInitial()) {
    on<LoadDashboardStatisticEvent>(_onLoadDashboardStatisticData);
    on<LoadDashboardQuestionRecordsEvent>(_onLoadDashboardQuestionRecordsData);
  }

  void _onLoadDashboardStatisticData(
    LoadDashboardStatisticEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await _loadDashboardStatistic(NoParams());

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (data) {
        _statisticData = data;
        emit(DashboardStatisticLoaded(data));
      },
    );
  }

  void _onLoadDashboardQuestionRecordsData(
    LoadDashboardQuestionRecordsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (event.isLoadMore) {
      if (state is DashboardDataLoaded) {
        final currentState = state as DashboardDataLoaded;
        if (currentState.isLoadingMore || !currentState.hasMore) return;
        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      _allQuestions = [];
      _currentPage = 0;
    }

    final result = await _loadDashboardQuestionRecords(
      LoadDashboardQuestionRecordsParams(
        page: event.page,
        feedbackType: event.feedbackType,
      ),
    );

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (data) {
        if (event.isLoadMore) {
          _allQuestions.addAll(data.questions);
        } else {
          _allQuestions = data.questions;
        }
        _currentPage = data.currentPage;
        _totalPages = data.totalPages;

        if (_statisticData != null) {
          emit(DashboardDataLoaded(
            statisticData: _statisticData!,
            questions: List.from(_allQuestions),
            currentPage: _currentPage,
            totalPages: _totalPages,
            hasMore: _currentPage < _totalPages,
            isLoadingMore: false,
          ));
        } else {
          emit(DashboardQuestionRecordsLoaded(
            questions: List.from(_allQuestions),
            currentPage: _currentPage,
            totalPages: _totalPages,
            hasMore: _currentPage < _totalPages,
            isLoadingMore: false,
          ));
        }
      },
    );
  }
}
