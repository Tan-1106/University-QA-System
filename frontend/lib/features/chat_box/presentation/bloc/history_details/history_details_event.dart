part of 'history_details_bloc.dart';

@immutable
sealed class HistoryDetailsEvent {}

final class ViewRecordDetailsEvent extends HistoryDetailsEvent {
  final String questionID;

  ViewRecordDetailsEvent({
    required this.questionID,
  });
}

