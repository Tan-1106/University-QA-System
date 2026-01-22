import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:university_qa_system/features/api_management/domain/entities/api_key.dart';
import 'package:university_qa_system/features/api_management/domain/use_cases/get_api_keys.dart';

part 'api_keys_event.dart';

part 'api_keys_state.dart';

class ApiKeysBloc extends Bloc<ApiKeysEvent, ApiKeysState> {
  final LoadAPIKeysUseCase _loadAPIKeys;

  List<APIKeyEntity> _allApiKeys = [];
  int _currentPage = 0;
  int _totalPages = 1;

  ApiKeysBloc(
    LoadAPIKeysUseCase loadAPIKeys,
  ) : _loadAPIKeys = loadAPIKeys,
      super(ApiKeysInitial()) {
    on<LoadApiKeysEvent>(_onLoadAPIKeys);
  }

  void _onLoadAPIKeys(
    LoadApiKeysEvent event,
    Emitter<ApiKeysState> emit,
  ) async {
    if (event.isLoadMore) {
      if (state is ApiKeysLoaded) {
        final currentState = state as ApiKeysLoaded;
        if (currentState.isLoadingMore || !currentState.hasMore) return;
        emit(currentState.copyWith(isLoadingMore: true));
      }
    } else {
      _allApiKeys = [];
      _currentPage = 0;
    }

    final result = await _loadAPIKeys(
      LoadAPIKeysUseCaseParams(
        page: event.page,
        provider: event.provider,
        keyword: event.keyword,
      ),
    );

    result.fold(
      (failure) => emit(ApiKeysError(failure.message)),
      (data) {
        if (event.isLoadMore) {
          _allApiKeys.addAll(data.apiKeys);
        } else {
          _allApiKeys = data.apiKeys;
        }
        _currentPage = data.currentPage;
        _totalPages = data.totalPages;
        emit(
          ApiKeysLoaded(
            apiKeys: _allApiKeys,
            currentPage: _currentPage,
            totalPages: _totalPages,
            hasMore: _currentPage < _totalPages,
            isLoadingMore: false,
          ),
        );
      },
    );
  }
}
