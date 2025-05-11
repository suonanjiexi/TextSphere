import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/conversation.dart';
import '../../repositories/message_repository.dart';

/// 获取会话列表用例
class GetConversationsUseCase {
  final MessageRepository repository;

  GetConversationsUseCase(this.repository);

  /// 执行获取会话列表操作
  ///
  /// 无参数
  ///
  /// 返回:
  /// - 成功: [Right] 包含会话列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Conversation>>> call() {
    return repository.getConversations();
  }
}
