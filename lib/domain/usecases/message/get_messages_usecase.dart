import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/message.dart';
import '../../repositories/message_repository.dart';

/// 获取消息列表用例
class GetMessagesUseCase {
  final MessageRepository repository;

  GetMessagesUseCase(this.repository);

  /// 执行获取消息列表操作
  ///
  /// 参数:
  /// - [params]: 获取消息参数，包含会话ID、页码和每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含消息列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) {
    return repository.getMessages(
      params.conversationId,
      params.page,
      params.pageSize,
    );
  }
}

/// 获取消息参数
class GetMessagesParams extends Equatable {
  final String conversationId;
  final int page;
  final int pageSize;

  const GetMessagesParams({
    required this.conversationId,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [conversationId, page, pageSize];
}
