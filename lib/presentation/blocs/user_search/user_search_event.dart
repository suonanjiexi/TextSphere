import 'package:equatable/equatable.dart';

/// 用户搜索事件基类
abstract class UserSearchEvent extends Equatable {
  /// 基础构造函数
  const UserSearchEvent();

  @override
  List<Object> get props => [];
}

/// 搜索用户事件
class SearchUsers extends UserSearchEvent {
  /// 搜索关键词
  final String keyword;

  /// 每页数量
  final int pageSize;

  /// 构造函数
  const SearchUsers({required this.keyword, this.pageSize = 10});

  @override
  List<Object> get props => [keyword, pageSize];
}

/// 加载更多搜索结果事件
class LoadMoreSearchResults extends UserSearchEvent {
  /// 搜索关键词
  final String keyword;

  /// 每页数量
  final int pageSize;

  /// 构造函数
  const LoadMoreSearchResults({required this.keyword, this.pageSize = 10});

  @override
  List<Object> get props => [keyword, pageSize];
}

/// 更新搜索关键词事件
class UpdateSearchKeyword extends UserSearchEvent {
  /// 搜索关键词
  final String keyword;

  /// 构造函数
  const UpdateSearchKeyword(this.keyword);

  @override
  List<Object> get props => [keyword];
}

/// 清空搜索结果事件
class ClearSearchResults extends UserSearchEvent {}

/// 添加搜索历史事件
class AddSearchHistory extends UserSearchEvent {
  /// 搜索关键词
  final String keyword;

  /// 构造函数
  const AddSearchHistory(this.keyword);

  @override
  List<Object> get props => [keyword];
}

/// 清空搜索历史事件
class ClearSearchHistory extends UserSearchEvent {}

/// 删除单条搜索历史事件
class RemoveSearchHistoryItem extends UserSearchEvent {
  /// 搜索关键词
  final String keyword;

  /// 构造函数
  const RemoveSearchHistoryItem(this.keyword);

  @override
  List<Object> get props => [keyword];
}
