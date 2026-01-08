part of 'api_keys_bloc.dart';

@immutable
sealed class ApiKeysEvent {}

final class LoadApiKeysEvent extends ApiKeysEvent {
  final int page;
  final String? provider;
  final String? keyword;
  final bool isLoadMore;

  LoadApiKeysEvent({
    this.page = 1,
    this.provider,
    this.keyword,
    this.isLoadMore = false,
  });
}