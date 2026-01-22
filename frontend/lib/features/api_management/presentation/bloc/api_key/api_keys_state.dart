part of 'api_keys_bloc.dart';

@immutable
sealed class ApiKeysState {
  const ApiKeysState();
}

final class ApiKeysInitial extends ApiKeysState {}

final class ApiKeysLoading extends ApiKeysState {}

final class ApiKeysLoaded extends ApiKeysState {
  final List<APIKeyEntity> apiKeys;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;

  const ApiKeysLoaded({
    required this.apiKeys,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  ApiKeysLoaded copyWith({
    List<APIKeyEntity>? apiKeys,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ApiKeysLoaded(
      apiKeys: apiKeys ?? this.apiKeys,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class ApiKeysError extends ApiKeysState {
  final String message;

  const ApiKeysError(this.message);
}
