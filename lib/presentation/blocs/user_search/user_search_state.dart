import 'package:equatable/equatable.dart';
import 'package:text_sphere_app/domain/entities/user.dart';

/// 用户搜索状态
enum UserSearchStatus {
  /// 初始状态
  initial,

  /// 加载中
  loading,

  /// 加载更多
  loadMore,

  /// 加载成功
  success,

  /// 加载失败
  failure,
}

/// 用户搜索状态类
class UserSearchState extends Equatable {
  /// 搜索关键词
  final String keyword;

  /// 搜索结果列表
  final List<User> searchResults;

  /// 搜索状态
  final UserSearchStatus status;

  /// 错误信息
  final String? errorMessage;

  /// 是否已经加载全部结果
  final bool hasReachedMax;

  /// 当前页码
  final int page;

  /// 搜索历史
  final List<String> searchHistory;

  /// 创建搜索状态
  const UserSearchState({
    this.keyword = '',
    this.searchResults = const [],
    this.status = UserSearchStatus.initial,
    this.errorMessage,
    this.hasReachedMax = false,
    this.page = 1,
    this.searchHistory = const [],
  });

  /// 创建初始状态
  factory UserSearchState.initial() {
    return const UserSearchState();
  }

  /// 创建新状态
  UserSearchState copyWith({
    String? keyword,
    List<User>? searchResults,
    UserSearchStatus? status,
    String? errorMessage,
    bool? hasReachedMax,
    int? page,
    List<String>? searchHistory,
  }) {
    return UserSearchState(
      keyword: keyword ?? this.keyword,
      searchResults: searchResults ?? this.searchResults,
      status: status ?? this.status,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      searchHistory: searchHistory ?? this.searchHistory,
    );
  }

  @override
  List<Object?> get props => [
    keyword,
    searchResults,
    status,
    errorMessage,
    hasReachedMax,
    page,
    searchHistory,
  ];
}
