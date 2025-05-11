import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

/// 登录用例
class LoginUseCase {
  final UserRepository repository;

  LoginUseCase(this.repository);

  /// 执行登录操作
  ///
  /// 参数:
  /// - [params]: 登录参数，包含用户名和密码
  ///
  /// 返回:
  /// - 成功: [Right] 包含 [User] 对象
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.login(params.username, params.password);
  }
}

/// 登录参数
class LoginParams extends Equatable {
  final String username;
  final String password;

  const LoginParams({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}
