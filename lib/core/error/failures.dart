import 'package:equatable/equatable.dart';

/// 基础失败类
abstract class Failure extends Equatable {
  /// 错误消息
  String get message;

  @override
  List<Object> get props => [message];
}

/// 服务器失败
class ServerFailure extends Failure {
  final String message;

  ServerFailure({this.message = '服务器错误'});

  @override
  List<Object> get props => [message];
}

/// 缓存失败
class CacheFailure extends Failure {
  final String message;

  CacheFailure({this.message = '缓存错误'});

  @override
  List<Object> get props => [message];
}

/// 网络失败
class NetworkFailure extends Failure {
  final String message;

  NetworkFailure({this.message = '网络连接错误'});

  @override
  List<Object> get props => [message];
}

/// 认证失败
class AuthenticationFailure extends Failure {
  final String message;

  AuthenticationFailure({this.message = '认证失败'});

  @override
  List<Object> get props => [message];
}

/// 请求失败
class RequestFailure extends Failure {
  final String message;

  RequestFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// 身份验证错误
class AuthFailure extends Failure {
  final String message;

  AuthFailure({this.message = '身份验证失败'});

  @override
  List<Object> get props => [message];
}

/// 输入验证错误
class ValidationFailure extends Failure {
  final String message;
  final Map<String, String> errors;

  ValidationFailure({this.message = '输入验证失败', this.errors = const {}});

  @override
  List<Object> get props => [message, errors];
}

/// 权限错误
class PermissionFailure extends Failure {
  final String message;

  PermissionFailure({this.message = '权限不足'});

  @override
  List<Object> get props => [message];
}

/// 未找到资源错误
class NotFoundFailure extends Failure {
  final String message;

  NotFoundFailure({this.message = '资源不存在'});

  @override
  List<Object> get props => [message];
}

/// 未知错误
class UnknownFailure extends Failure {
  final String message;

  UnknownFailure({this.message = '未知错误'});

  @override
  List<Object> get props => [message];
}
