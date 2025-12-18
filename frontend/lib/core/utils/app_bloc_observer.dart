import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
  output: ConsoleOutput(),
);

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    logger.d('EVENT ADDED: ${bloc.runtimeType}\nPayload: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    if (bloc.runtimeType.toString() == 'TimerBloc') return;
    super.onTransition(bloc, transition);
    logger.i(
      'TRANSITION: ${bloc.runtimeType}\n'
      'Event: ${transition.event}\n'
      'From: ${transition.currentState}\n'
      'To:   ${transition.nextState}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    logger.e(
      'ERROR in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (bloc is Cubit) {
      logger.i('CUBIT CHANGE: ${bloc.runtimeType}\n$change');
    }
  }
}
