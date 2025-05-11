import 'package:equatable/equatable.dart';

abstract class SquareEvent extends Equatable {
  const SquareEvent();

  @override
  List<Object?> get props => [];
}

// 加载广场帖子
class LoadSquarePosts extends SquareEvent {
  final String topic;
  final int pageSize;

  const LoadSquarePosts({this.topic = '', this.pageSize = 10});

  @override
  List<Object?> get props => [topic, pageSize];
}

// 刷新广场帖子
class RefreshSquarePosts extends SquareEvent {
  final String topic;
  final int pageSize;

  const RefreshSquarePosts({this.topic = '', this.pageSize = 10});

  @override
  List<Object?> get props => [topic, pageSize];
}

// 加载更多广场帖子
class LoadMoreSquarePosts extends SquareEvent {
  final String topic;
  final int pageSize;

  const LoadMoreSquarePosts({this.topic = '', this.pageSize = 10});

  @override
  List<Object?> get props => [topic, pageSize];
}

// 切换话题
class SwitchTopic extends SquareEvent {
  final String topic;

  const SwitchTopic({required this.topic});

  @override
  List<Object?> get props => [topic];
}

// 点赞/取消点赞帖子
class ToggleLikePost extends SquareEvent {
  final String postId;
  final bool isCurrentlyLiked;

  const ToggleLikePost({required this.postId, required this.isCurrentlyLiked});

  @override
  List<Object?> get props => [postId, isCurrentlyLiked];
}
