import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

/// 注册用例
class RegisterUseCase {
  final UserRepository repository;

  RegisterUseCase(this.repository);

  /// 执行注册操作
  ///
  /// 参数:
  /// - [params]: 注册参数，包含用户名、密码和昵称
  ///
  /// 返回:
  /// - 成功: [Right] 包含 [User] 对象
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, User>> call(RegisterParams params) {
    return repository.register(
      params.username,
      params.password,
      params.nickname,
    );
  }
}

/// 注册参数
class RegisterParams extends Equatable {
  final String username;
  final String password;
  final String nickname;

  const RegisterParams({
    required this.username,
    required this.password,
    required this.nickname,
  });

  @override
  List<Object?> get props => [username, password, nickname];
}
