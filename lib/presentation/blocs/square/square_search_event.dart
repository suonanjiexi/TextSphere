import 'package:equatable/equatable.dart';

abstract class SquareSearchEvent extends Equatable {
  const SquareSearchEvent();

  @override
  List<Object?> get props => [];
}

/// 搜索广场帖子
class SearchPosts extends SquareSearchEvent {
  final String keyword;
  final int pageSize;

  const SearchPosts({required this.keyword, this.pageSize = 10});

  @override
  List<Object?> get props => [keyword, pageSize];
}

/// 加载更多搜索结果
class LoadMoreSearchResults extends SquareSearchEvent {
  final String keyword;
  final int pageSize;

  const LoadMoreSearchResults({required this.keyword, this.pageSize = 10});

  @override
  List<Object?> get props => [keyword, pageSize];
}

/// 清除搜索结果
class ClearSearchResults extends SquareSearchEvent {}

/// 更新搜索关键词（不触发搜索）
class UpdateSearchKeyword extends SquareSearchEvent {
  final String keyword;

  const UpdateSearchKeyword(this.keyword);

  @override
  List<Object?> get props => [keyword];
}
