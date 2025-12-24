import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'document_view_event.dart';
part 'document_view_state.dart';

class DocumentViewBloc extends Bloc<DocumentViewEvent, DocumentViewState> {
  DocumentViewBloc() : super(DocumentViewInitial()) {
    on<DocumentViewEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
