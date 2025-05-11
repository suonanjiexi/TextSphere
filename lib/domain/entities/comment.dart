import 'package:equatable/equatable.dart';

/// 评论实体
///
/// 表示帖子的一条评论，包含评论的基本信息
class Comment extends Equatable {
  /// 评论唯一标识
  final String id;

  /// 帖子ID
  final String postId;

  /// 评论者ID
  final String userId;

  /// 评论者名称
  final String username;

  /// 评论者头像
  final String userAvatar;

  /// 评论内容
  final String content;

  /// 父评论ID（如果是回复其他评论）
  final String? parentId;

  /// 被回复用户ID（如果是回复其他用户的评论）
  final String? replyToUserId;

  /// 被回复用户名称
  final String? replyToUsername;

  /// 点赞数量
  final int likeCount;

  /// 回复数量
  final int replyCount;

  /// 当前用户是否点赞
  final bool isLiked;

  /// 创建时间
  final DateTime createdAt;

  /// 子评论列表
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.content,
    this.parentId,
    this.replyToUserId,
    this.replyToUsername,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.replies = const [],
  });

  @override
  List<Object?> get props => [
    id,
    postId,
    userId,
    username,
    userAvatar,
    content,
    parentId,
    replyToUserId,
    replyToUsername,
    likeCount,
    replyCount,
    isLiked,
    createdAt,
    replies,
  ];

  /// 判断是否为回复评论
  bool get isReply => parentId != null && replyToUserId != null;

  /// 判断是否有回复
  bool get hasReplies => replies.isNotEmpty;

  /// 复制评论对象并修改部分属性
  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? username,
    String? userAvatar,
    String? content,
    String? parentId,
    String? replyToUserId,
    String? replyToUsername,
    int? likeCount,
    int? replyCount,
    bool? isLiked,
    DateTime? createdAt,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      replyToUserId: replyToUserId ?? this.replyToUserId,
      replyToUsername: replyToUsername ?? this.replyToUsername,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }
}
