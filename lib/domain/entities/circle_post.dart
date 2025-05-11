import 'package:equatable/equatable.dart';

class CirclePost extends Equatable {
  final String id;
  final String circleId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String createdAt;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isLiked;
  final bool isPinned;
  final bool isEssence;

  const CirclePost({
    required this.id,
    required this.circleId,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.isLiked,
    required this.isPinned,
    required this.isEssence,
  });

  // 浅拷贝方法，用于更新帖子状态
  CirclePost copyWith({
    String? id,
    String? circleId,
    String? title,
    String? content,
    List<String>? imageUrls,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? createdAt,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    bool? isLiked,
    bool? isPinned,
    bool? isEssence,
  }) {
    return CirclePost(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isLiked: isLiked ?? this.isLiked,
      isPinned: isPinned ?? this.isPinned,
      isEssence: isEssence ?? this.isEssence,
    );
  }

  @override
  List<Object> get props => [
    id,
    circleId,
    title,
    content,
    imageUrls,
    authorId,
    authorName,
    authorAvatar,
    createdAt,
    likesCount,
    commentsCount,
    viewsCount,
    isLiked,
    isPinned,
    isEssence,
  ];
}
