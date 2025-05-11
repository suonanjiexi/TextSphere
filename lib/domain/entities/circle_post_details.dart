import 'package:equatable/equatable.dart';
import 'package:text_sphere_app/domain/entities/circle_post.dart';
import 'package:text_sphere_app/domain/entities/comment.dart';

class CirclePostDetails extends Equatable {
  final CirclePost post;
  final List<Comment> comments;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  const CirclePostDetails({
    required this.post,
    required this.comments,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  // 获取评论总数（包括回复）
  int get totalCommentsCount {
    int count = comments.length;
    for (var comment in comments) {
      count += comment.replies.length;
    }
    return count;
  }

  // 浅拷贝方法
  CirclePostDetails copyWith({
    CirclePost? post,
    List<Comment>? comments,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return CirclePostDetails(
      post: post ?? this.post,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    post,
    comments,
    isLoading,
    hasError,
    errorMessage,
  ];
}
