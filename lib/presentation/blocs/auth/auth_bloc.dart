// lib/presentation/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_sphere_app/domain/entities/user.dart';
import 'package:text_sphere_app/domain/usecases/user/get_current_user_usecase.dart';
import 'package:text_sphere_app/domain/usecases/user/login_usecase.dart';
import 'package:text_sphere_app/domain/usecases/user/register_usecase.dart';
import 'package:text_sphere_app/presentation/blocs/auth/auth_event.dart';
import 'package:text_sphere_app/presentation/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SharedPreferences sharedPreferences;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getCurrentUserUseCase,
    required this.sharedPreferences,
  }) : super(const AuthInitial()) {
    on<CheckAuthenticationEvent>(_onCheckAuthentication);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthentication(
    CheckAuthenticationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final result = await getCurrentUserUseCase();
      result.fold(
        (failure) => emit(const Unauthenticated()),
        (user) => emit(Authenticated(user: user)),
      );
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(username: event.username, password: event.password),
    );

    await result.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (user) async {
        await sharedPreferences.setBool('isLoggedIn', true);
        await sharedPreferences.setString('userId', user.id);
        await sharedPreferences.setString('userName', user.username);
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    await sharedPreferences.remove('isLoggedIn');
    await sharedPreferences.remove('userId');
    await sharedPreferences.remove('userName');

    emit(const Unauthenticated());
  }
}
