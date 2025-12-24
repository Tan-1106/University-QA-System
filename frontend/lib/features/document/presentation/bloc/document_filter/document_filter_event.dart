part of 'document_filter_bloc.dart';

@immutable
sealed class DocumentFilterEvent {}

final class GetDocumentFiltersEvent extends DocumentFilterEvent {
  GetDocumentFiltersEvent();
}