import 'package:equatable/equatable.dart';

/// 消息类型枚举
enum MessageType {
  /// 文本消息
  text,

  /// 图片消息
  image,

  /// 语音消息
  voice,

  /// 视频消息
  video,

  /// 文件消息
  file,

  /// 系统消息
  system,
}

/// 消息状态枚举
enum MessageStatus {
  /// 发送中
  sending,

  /// 已发送
  sent,

  /// 已送达
  delivered,

  /// 已读
  read,

  /// 发送失败
  failed,
}

/// 消息实体
///
/// 表示应用中的一条消息，包含消息的基本信息
class Message extends Equatable {
  /// 消息唯一标识
  final String id;

  /// 会话ID
  final String conversationId;

  /// 发送者ID
  final String senderId;

  /// 接收者ID（可能是用户ID或群组ID）
  final String receiverId;

  /// 消息内容
  final String content;

  /// 消息类型
  final MessageType type;

  /// 消息状态
  final MessageStatus status;

  /// 消息是否已读
  final bool isRead;

  /// 扩展信息（JSON字符串，用于存储不同类型消息的额外信息）
  final String extra;

  /// 消息发送时间
  final DateTime sentAt;

  /// 是否是当前用户发送的消息
  final bool isSelf;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.status,
    this.isRead = false,
    this.extra = '{}',
    required this.sentAt,
    required this.isSelf,
  });

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    receiverId,
    content,
    type,
    status,
    isRead,
    extra,
    sentAt,
    isSelf,
  ];

  /// 创建系统消息
  factory Message.system({
    required String id,
    required String conversationId,
    required String content,
    String extra = '{}',
  }) => Message(
    id: id,
    conversationId: conversationId,
    senderId: 'system',
    receiverId: conversationId,
    content: content,
    type: MessageType.system,
    status: MessageStatus.delivered,
    isRead: true,
    extra: extra,
    sentAt: DateTime.now(),
    isSelf: false,
  );

  /// 复制消息对象并修改部分属性
  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    bool? isRead,
    String? extra,
    DateTime? sentAt,
    bool? isSelf,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      extra: extra ?? this.extra,
      sentAt: sentAt ?? this.sentAt,
      isSelf: isSelf ?? this.isSelf,
    );
  }
}
