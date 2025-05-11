import 'package:equatable/equatable.dart';

/// 帖子模型
class PostModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final int likes;
  final int comments;
  final bool isFavorite;

  const PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.likes = 0,
    this.comments = 0,
    this.isFavorite = false,
  });

  /// 从JSON映射创建帖子模型
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((tag) => tag as String)
              .toList() ??
          [],
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'isFavorite': isFavorite,
    };
  }

  /// 复制帖子模型并更新指定字段
  PostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    int? likes,
    int? comments,
    bool? isFavorite,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    authorId,
    authorName,
    createdAt,
    updatedAt,
    tags,
    likes,
    comments,
    isFavorite,
  ];
}
