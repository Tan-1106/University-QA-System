part of 'history_details_bloc.dart';

@immutable
sealed class HistoryDetailsState {
  const HistoryDetailsState();
}

final class HistoryDetailsInitial extends HistoryDetailsState {}

final class HistoryDetailsLoading extends HistoryDetailsState {}

final class HistoryDetailsLoaded extends HistoryDetailsState {
  final QARecordDetails recordDetails;

  const HistoryDetailsLoaded(this.recordDetails);
}

final class HistoryDetailsError extends HistoryDetailsState {
  final String message;

  const HistoryDetailsError(this.message);
}

