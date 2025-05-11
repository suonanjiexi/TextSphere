import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_sphere_app/domain/repositories/user_repository.dart';
import 'package:text_sphere_app/presentation/blocs/user_search/user_search_event.dart';
import 'package:text_sphere_app/presentation/blocs/user_search/user_search_state.dart';

/// 用户搜索BLoC
class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final UserRepository _userRepository;
  final SharedPreferences _sharedPreferences;
  static const String _searchHistoryKey = 'user_search_history';

  /// 构造函数
  UserSearchBloc({
    required UserRepository userRepository,
    required SharedPreferences sharedPreferences,
  }) : _userRepository = userRepository,
       _sharedPreferences = sharedPreferences,
       super(UserSearchState.initial()) {
    on<SearchUsers>(_onSearchUsers);
    on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
    on<UpdateSearchKeyword>(_onUpdateSearchKeyword);
    on<ClearSearchResults>(_onClearSearchResults);
    on<AddSearchHistory>(_onAddSearchHistory);
    on<ClearSearchHistory>(_onClearSearchHistory);
    on<RemoveSearchHistoryItem>(_onRemoveSearchHistoryItem);
    on<UpdateSearchState>(_onUpdateSearchState);

    // 初始化搜索历史
    _loadSearchHistory();
  }

  /// 搜索用户事件处理
  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<UserSearchState> emit,
  ) async {
    emit(
      state.copyWith(
        status: UserSearchStatus.loading,
        keyword: event.keyword,
        page: 1,
        hasReachedMax: false,
      ),
    );

    try {
      final result = await _userRepository.searchUsers(
        event.keyword,
        1,
        event.pageSize,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: UserSearchStatus.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (users) {
          final hasReachedMax = users.length < event.pageSize;
          emit(
            state.copyWith(
              status: UserSearchStatus.success,
              searchResults: users,
              hasReachedMax: hasReachedMax,
            ),
          );

          // 添加搜索历史
          add(AddSearchHistory(event.keyword));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserSearchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// 加载更多搜索结果事件处理
  Future<void> _onLoadMoreSearchResults(
    LoadMoreSearchResults event,
    Emitter<UserSearchState> emit,
  ) async {
    if (state.hasReachedMax) return;

    emit(
      state.copyWith(status: UserSearchStatus.loadMore, keyword: event.keyword),
    );

    try {
      final nextPage = state.page + 1;
      final result = await _userRepository.searchUsers(
        event.keyword,
        nextPage,
        event.pageSize,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: UserSearchStatus.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (users) {
          final hasReachedMax = users.length < event.pageSize;
          emit(
            state.copyWith(
              status: UserSearchStatus.success,
              searchResults: [...state.searchResults, ...users],
              hasReachedMax: hasReachedMax,
              page: nextPage,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserSearchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// 更新搜索关键词事件处理
  void _onUpdateSearchKeyword(
    UpdateSearchKeyword event,
    Emitter<UserSearchState> emit,
  ) {
    emit(state.copyWith(keyword: event.keyword));
  }

  /// 清空搜索结果事件处理
  void _onClearSearchResults(
    ClearSearchResults event,
    Emitter<UserSearchState> emit,
  ) {
    emit(
      state.copyWith(
        status: UserSearchStatus.initial,
        searchResults: [],
        keyword: '',
        page: 1,
        hasReachedMax: false,
      ),
    );
  }

  /// 添加搜索历史事件处理
  Future<void> _onAddSearchHistory(
    AddSearchHistory event,
    Emitter<UserSearchState> emit,
  ) async {
    if (event.keyword.trim().isEmpty) return;

    // 获取当前搜索历史
    final List<String> newHistory = [...state.searchHistory];

    // 如果已存在，则先移除旧的
    newHistory.remove(event.keyword);

    // 添加到最前面
    newHistory.insert(0, event.keyword);

    // 保留最近20条
    if (newHistory.length > 20) {
      newHistory.removeLast();
    }

    // 保存到本地
    await _saveSearchHistory(newHistory);

    emit(state.copyWith(searchHistory: newHistory));
  }

  /// 清空搜索历史事件处理
  Future<void> _onClearSearchHistory(
    ClearSearchHistory event,
    Emitter<UserSearchState> emit,
  ) async {
    await _saveSearchHistory([]);
    emit(state.copyWith(searchHistory: []));
  }

  /// 删除单条搜索历史事件处理
  Future<void> _onRemoveSearchHistoryItem(
    RemoveSearchHistoryItem event,
    Emitter<UserSearchState> emit,
  ) async {
    final List<String> newHistory = [...state.searchHistory];
    newHistory.remove(event.keyword);

    await _saveSearchHistory(newHistory);
    emit(state.copyWith(searchHistory: newHistory));
  }

  /// 加载搜索历史
  Future<void> _loadSearchHistory() async {
    final List<String> history =
        _sharedPreferences.getStringList(_searchHistoryKey) ?? [];
    add(UpdateSearchState(searchHistory: history));
  }

  /// 保存搜索历史
  Future<void> _saveSearchHistory(List<String> history) async {
    await _sharedPreferences.setStringList(_searchHistoryKey, history);
  }

  /// 更新搜索状态事件处理
  void _onUpdateSearchState(
    UpdateSearchState event,
    Emitter<UserSearchState> emit,
  ) {
    if (event.searchHistory != null) {
      emit(state.copyWith(searchHistory: event.searchHistory));
    }
  }
}

/// 更新搜索状态事件（内部使用）
class UpdateSearchState extends UserSearchEvent {
  final List<String>? searchHistory;

  const UpdateSearchState({this.searchHistory});

  @override
  List<Object> get props => searchHistory != null ? [searchHistory!] : [];
}
