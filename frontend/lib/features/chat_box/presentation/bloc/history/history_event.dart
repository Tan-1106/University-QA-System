part of 'history_bloc.dart';

@immutable
sealed class HistoryEvent {}

final class GetHistoryEvent extends HistoryEvent {
  final int page;
  final bool isLoadMore;

  GetHistoryEvent({
    this.page = 1,
    this.isLoadMore = false,
  });
}

