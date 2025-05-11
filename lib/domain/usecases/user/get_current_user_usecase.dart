import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

/// 获取当前用户用例
class GetCurrentUserUseCase {
  final UserRepository repository;

  GetCurrentUserUseCase(this.repository);

  /// 执行获取当前用户操作
  ///
  /// 无参数
  ///
  /// 返回:
  /// - 成功: [Right] 包含 [User] 对象
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, User>> call() {
    return repository.getCurrentUser();
  }
}
