import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_sphere_app/utils/app_logger.dart';

/// BLoC日志观察者，用于记录所有BLoC状态变化
class AppBlocObserver extends BlocObserver {
  final bool _verbose;

  AppBlocObserver({bool verbose = false}) : _verbose = verbose;

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    logger.d('BLoC创建: ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    if (_verbose) {
      logger.d(
        'BLoC [${bloc.runtimeType}] 状态变化:\n'
        '  从: ${change.currentState}\n'
        '  到: ${change.nextState}',
      );
    } else {
      logger.d(
        'BLoC [${bloc.runtimeType}] 状态变化: ${change.nextState.runtimeType}',
      );
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    logger.d('BLoC [${bloc.runtimeType}] 接收事件: ${event.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    if (_verbose) {
      logger.d(
        'BLoC [${bloc.runtimeType}] 转换:\n'
        '  事件: ${transition.event.runtimeType}\n'
        '  从: ${transition.currentState.runtimeType}\n'
        '  到: ${transition.nextState.runtimeType}',
      );
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logger.e('BLoC [${bloc.runtimeType}] 错误', error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    logger.d('BLoC销毁: ${bloc.runtimeType}');
  }
}
