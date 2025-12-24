part of 'document_filter_bloc.dart';

@immutable
sealed class DocumentFilterState {
  const DocumentFilterState();
}

final class DocumentFilterInitial extends DocumentFilterState {}

final class DocumentFiltersLoading extends DocumentFilterState {}

final class DocumentFiltersLoaded extends DocumentFilterState {
  final Filters filters;

  const DocumentFiltersLoaded(this.filters);
}

final class DocumentFilterError extends DocumentFilterState {
  final String message;

  const DocumentFilterError(this.message);
}