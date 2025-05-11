import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/message.dart';
import '../../repositories/message_repository.dart';

/// 发送消息用例
class SendMessageUseCase {
  final MessageRepository repository;

  SendMessageUseCase(this.repository);

  /// 执行发送消息操作
  ///
  /// 参数:
  /// - [message]: 要发送的消息对象
  ///
  /// 返回:
  /// - 成功: [Right] 包含发送成功的消息
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, Message>> call(Message message) {
    return repository.sendMessage(message);
  }
}
