import 'package:equatable/equatable.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/entities/comment.dart';

abstract class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

// 初始状态
class PostDetailInitial extends PostDetailState {}

// 加载中状态
class PostDetailLoading extends PostDetailState {}

// 加载失败状态
class PostDetailError extends PostDetailState {
  final String message;

  const PostDetailError(this.message);

  @override
  List<Object> get props => [message];
}

// 加载成功状态
class PostDetailLoaded extends PostDetailState {
  final Post post;
  final List<Comment> comments;
  final bool isLoadingComments;
  final bool isFollowingAuthor;
  final bool isCollected;
  final Comment? replyTo;
  final String commentText;
  final bool isSubmittingComment;
  final bool isDeletingPost;

  const PostDetailLoaded({
    required this.post,
    this.comments = const [],
    this.isLoadingComments = false,
    this.isFollowingAuthor = false,
    this.isCollected = false,
    this.replyTo,
    this.commentText = '',
    this.isSubmittingComment = false,
    this.isDeletingPost = false,
  });

  // 复制状态并修改部分属性
  PostDetailLoaded copyWith({
    Post? post,
    List<Comment>? comments,
    bool? isLoadingComments,
    bool? isFollowingAuthor,
    bool? isCollected,
    Comment? replyTo,
    String? commentText,
    bool? isSubmittingComment,
    bool? isDeletingPost,
    bool clearReplyTo = false,
  }) {
    return PostDetailLoaded(
      post: post ?? this.post,
      comments: comments ?? this.comments,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
      isCollected: isCollected ?? this.isCollected,
      replyTo: clearReplyTo ? null : (replyTo ?? this.replyTo),
      commentText: commentText ?? this.commentText,
      isSubmittingComment: isSubmittingComment ?? this.isSubmittingComment,
      isDeletingPost: isDeletingPost ?? this.isDeletingPost,
    );
  }

  // 判断当前用户是否是帖子作者
  bool get isAuthor => post.userId == 'current_user_id'; // 模拟，实际应该从用户服务获取

  @override
  List<Object?> get props => [
    post,
    comments,
    isLoadingComments,
    isFollowingAuthor,
    isCollected,
    replyTo,
    commentText,
    isSubmittingComment,
    isDeletingPost,
  ];
}

// 帖子已删除状态
class PostDeleted extends PostDetailState {}
