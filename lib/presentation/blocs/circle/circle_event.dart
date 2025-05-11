import 'package:equatable/equatable.dart';

/// 圈子事件基类
abstract class CircleEvent extends Equatable {
  const CircleEvent();

  @override
  List<Object> get props => [];
}

/// 加载用户已加入的圈子事件
class LoadJoinedCircles extends CircleEvent {
  const LoadJoinedCircles();

  @override
  List<Object> get props => [];
}

/// 加载推荐圈子事件
class LoadRecommendedCircles extends CircleEvent {
  const LoadRecommendedCircles();

  @override
  List<Object> get props => [];
}

/// 加载特定类别圈子事件
class LoadCategorizedCircles extends CircleEvent {
  final String category;

  const LoadCategorizedCircles(this.category);

  @override
  List<Object> get props => [category];
}

/// 搜索圈子事件
class SearchCircles extends CircleEvent {
  final String keyword;

  const SearchCircles(this.keyword);

  @override
  List<Object> get props => [keyword];
}

/// 加入圈子事件
class JoinCircle extends CircleEvent {
  final String circleId;

  const JoinCircle(this.circleId);

  @override
  List<Object> get props => [circleId];
}

/// 退出圈子事件
class LeaveCircle extends CircleEvent {
  final String circleId;

  const LeaveCircle(this.circleId);

  @override
  List<Object> get props => [circleId];
}

/// 创建圈子事件
class CreateCircle extends CircleEvent {
  final String name;
  final String description;
  final String category;
  final List<String> tags;
  final String? avatarUrl;
  final String? coverUrl;

  const CreateCircle({
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    this.avatarUrl,
    this.coverUrl,
  });

  @override
  List<Object> get props => [name, description, category, tags];
}
