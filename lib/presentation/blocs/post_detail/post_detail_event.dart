import 'package:equatable/equatable.dart';
import '../../../domain/entities/comment.dart';

abstract class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object?> get props => [];
}

// 加载帖子详情
class LoadPostDetail extends PostDetailEvent {
  final String postId;

  const LoadPostDetail(this.postId);

  @override
  List<Object> get props => [postId];
}

// 点赞/取消点赞
class ToggleLike extends PostDetailEvent {}

// 收藏/取消收藏
class ToggleCollect extends PostDetailEvent {}

// 关注/取消关注作者
class ToggleFollowAuthor extends PostDetailEvent {}

// 点赞/取消点赞评论
class ToggleLikeComment extends PostDetailEvent {
  final String commentId;

  const ToggleLikeComment(this.commentId);

  @override
  List<Object> get props => [commentId];
}

// 回复评论
class SetReplyTo extends PostDetailEvent {
  final Comment? comment;

  const SetReplyTo(this.comment);

  @override
  List<Object?> get props => [comment];
}

// 清除回复对象
class ClearReplyTo extends PostDetailEvent {}

// 设置评论文本
class SetCommentText extends PostDetailEvent {
  final String text;

  const SetCommentText(this.text);

  @override
  List<Object> get props => [text];
}

// 提交评论
class SubmitComment extends PostDetailEvent {}

// 删除帖子
class DeletePost extends PostDetailEvent {}
