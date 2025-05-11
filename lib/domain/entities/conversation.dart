import 'package:equatable/equatable.dart';
import 'message.dart';

/// 会话类型枚举
enum ConversationType {
  /// 单聊
  single,

  /// 群聊
  group,
}

/// 会话实体
///
/// 表示用户的一个聊天会话，可以是单聊或群聊
class Conversation extends Equatable {
  /// 会话唯一标识
  final String id;

  /// 会话名称（对于单聊，通常是对方的昵称；对于群聊，是群组名称）
  final String name;

  /// 会话头像（对于单聊，通常是对方的头像；对于群聊，是群组头像）
  final String avatar;

  /// 会话类型
  final ConversationType type;

  /// 会话参与者ID列表
  final List<String> participantIds;

  /// 未读消息数量
  final int unreadCount;

  /// 最后一条消息
  final Message? lastMessage;

  /// 最后一条消息的时间
  final DateTime lastMessageTime;

  /// 会话是否置顶
  final bool isPinned;

  /// 会话是否静音
  final bool isMuted;

  const Conversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.type,
    required this.participantIds,
    this.unreadCount = 0,
    this.lastMessage,
    required this.lastMessageTime,
    this.isPinned = false,
    this.isMuted = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    avatar,
    type,
    participantIds,
    unreadCount,
    lastMessage,
    lastMessageTime,
    isPinned,
    isMuted,
  ];

  /// 获取会话的最后一条消息显示文本
  String get lastMessageText {
    if (lastMessage == null) {
      return '';
    }

    switch (lastMessage!.type) {
      case MessageType.text:
        return lastMessage!.content;
      case MessageType.image:
        return '[图片]';
      case MessageType.voice:
        return '[语音]';
      case MessageType.video:
        return '[视频]';
      case MessageType.file:
        return '[文件]';
      case MessageType.system:
        return lastMessage!.content;
      default:
        return '';
    }
  }

  /// 复制会话对象并修改部分属性
  Conversation copyWith({
    String? id,
    String? name,
    String? avatar,
    ConversationType? type,
    List<String>? participantIds,
    int? unreadCount,
    Message? lastMessage,
    DateTime? lastMessageTime,
    bool? isPinned,
    bool? isMuted,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}
