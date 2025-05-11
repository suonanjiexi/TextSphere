// lib/presentation/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthenticationEvent extends AuthEvent {
  const CheckAuthenticationEvent();
}

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginEvent({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String password;
  final String nickname;

  const RegisterEvent({
    required this.username,
    required this.password,
    required this.nickname,
  });

  @override
  List<Object?> get props => [username, password, nickname];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
