import 'package:dartz/dartz.dart';
import '../entities/message.dart';
import '../entities/conversation.dart';
import '../../core/error/failures.dart';

/// 消息仓库接口
///
/// 定义与消息和会话相关的数据操作方法
abstract class MessageRepository {
  /// 获取用户的会话列表
  ///
  /// 返回:
  /// - 成功: [Right] 包含会话列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Conversation>>> getConversations();

  /// 获取指定会话的消息历史
  ///
  /// 参数:
  /// - [conversationId]: 会话ID
  /// - [page]: 页码，从1开始
  /// - [pageSize]: 每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含消息列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Message>>> getMessages(
    String conversationId,
    int page,
    int pageSize,
  );

  /// 发送消息
  ///
  /// 参数:
  /// - [message]: 要发送的消息
  ///
  /// 返回:
  /// - 成功: [Right] 包含发送成功的消息
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, Message>> sendMessage(Message message);

  /// 创建新会话
  ///
  /// 参数:
  /// - [receiverId]: 接收者ID（单聊）或参与者ID列表（群聊）
  /// - [type]: 会话类型
  ///
  /// 返回:
  /// - 成功: [Right] 包含创建的会话
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, Conversation>> createConversation(
    dynamic receiverId,
    ConversationType type,
  );

  /// 标记消息为已读
  ///
  /// 参数:
  /// - [messageId]: 消息ID
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> markAsRead(String messageId);

  /// 标记整个会话为已读
  ///
  /// 参数:
  /// - [conversationId]: 会话ID
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> markConversationAsRead(String conversationId);

  /// 删除消息
  ///
  /// 参数:
  /// - [messageId]: 消息ID
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> deleteMessage(String messageId);

  /// 删除会话
  ///
  /// 参数:
  /// - [conversationId]: 会话ID
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> deleteConversation(String conversationId);

  /// 置顶/取消置顶会话
  ///
  /// 参数:
  /// - [conversationId]: 会话ID
  /// - [isPinned]: 是否置顶
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> pinConversation(
    String conversationId,
    bool isPinned,
  );

  /// 静音/取消静音会话
  ///
  /// 参数:
  /// - [conversationId]: 会话ID
  /// - [isMuted]: 是否静音
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> muteConversation(
    String conversationId,
    bool isMuted,
  );

  /// 获取未读消息数
  ///
  /// 返回:
  /// - 成功: [Right] 包含未读消息总数
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, int>> getUnreadCount();
}
