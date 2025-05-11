import 'package:equatable/equatable.dart';

/// 帖子实体
///
/// 表示应用中的一个帖子，包含帖子的基本信息
class Post extends Equatable {
  /// 帖子唯一标识
  final String id;

  /// 发布者ID
  final String userId;

  /// 发布者名称
  final String username;

  /// 发布者头像
  final String userAvatar;

  /// 帖子标题
  final String title;

  /// 帖子内容
  final String content;

  /// 帖子图片列表（URL）
  final List<String> images;

  /// 话题列表
  final List<String> topics;

  /// 点赞数量
  final int likeCount;

  /// 评论数量
  final int commentCount;

  /// 分享数量
  final int shareCount;

  /// 当前用户是否点赞
  final bool isLiked;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.title,
    required this.content,
    this.images = const [],
    this.topics = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    username,
    userAvatar,
    title,
    content,
    images,
    topics,
    likeCount,
    commentCount,
    shareCount,
    isLiked,
    createdAt,
    updatedAt,
  ];

  /// 获取帖子摘要（用于列表显示）
  String get summary {
    if (content.length <= 50) {
      return content;
    }
    return content.substring(0, 50) + '...';
  }

  /// 判断帖子是否包含图片
  bool get hasImages => images.isNotEmpty;

  /// 判断帖子是否包含话题
  bool get hasTopics => topics.isNotEmpty;

  /// 复制帖子对象并修改部分属性
  Post copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? title,
    String? content,
    List<String>? images,
    List<String>? topics,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      topics: topics ?? this.topics,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
