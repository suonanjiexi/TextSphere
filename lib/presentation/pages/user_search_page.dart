import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/domain/entities/user.dart';
import 'package:text_sphere_app/presentation/blocs/user_search/user_search_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/user_search/user_search_event.dart';
import 'package:text_sphere_app/presentation/blocs/user_search/user_search_state.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';
import 'package:text_sphere_app/presentation/widgets/error_view.dart';
import 'package:text_sphere_app/presentation/widgets/loading_indicator.dart';

class UserSearchPage extends StatefulWidget {
  final UserSearchBloc searchBloc;

  const UserSearchPage({Key? key, required this.searchBloc}) : super(key: key);

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  late UserSearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = widget.searchBloc;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 自动获取焦点
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = _searchBloc.state;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200.h &&
        state.status != UserSearchStatus.loadMore &&
        !state.hasReachedMax) {
      _searchBloc.add(
        LoadMoreSearchResults(keyword: state.keyword, pageSize: 10),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: BlocBuilder<UserSearchBloc, UserSearchState>(
        bloc: _searchBloc,
        builder: (context, state) {
          if (state.status == UserSearchStatus.initial) {
            return _buildEmptySearch();
          }

          if (state.status == UserSearchStatus.loading &&
              state.searchResults.isEmpty) {
            return Center(child: LoadingIndicator());
          }

          if (state.status == UserSearchStatus.failure &&
              state.searchResults.isEmpty) {
            return ErrorView(
              message: '搜索失败: ${state.errorMessage}',
              onRetry: () {
                _searchBloc.add(SearchUsers(keyword: state.keyword));
              },
            );
          }

          if (state.searchResults.isEmpty) {
            return _buildNoResults(state.keyword);
          }

          return _buildSearchResults(context, state);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => context.pop(),
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '搜索用户名/用户ID/手机号',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchBloc.add(ClearSearchResults());
                    },
                  )
                  : null,
        ),
        style: TextStyle(fontSize: 16.sp),
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          _searchBloc.add(UpdateSearchKeyword(value));
        },
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            _searchBloc.add(SearchUsers(keyword: value));
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_searchController.text.trim().isNotEmpty) {
              _searchBloc.add(SearchUsers(keyword: _searchController.text));
              FocusScope.of(context).unfocus();
            }
          },
          child: Text(
            '搜索',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySearch() {
    return BlocBuilder<UserSearchBloc, UserSearchState>(
      bloc: _searchBloc,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '搜索历史',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (state.searchHistory.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchBloc.add(ClearSearchHistory());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 16.w,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '清空',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              state.searchHistory.isEmpty
                  ? _buildEmptyHistory()
                  : Expanded(
                    child: ListView.builder(
                      itemCount: state.searchHistory.length,
                      itemBuilder: (context, index) {
                        final keyword = state.searchHistory[index];
                        return _buildHistoryItem(keyword);
                      },
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 40.h),
          Icon(
            Icons.history,
            size: 64.w,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无搜索历史',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '你可以搜索用户名、ID或手机号',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String keyword) {
    return InkWell(
      onTap: () {
        _searchController.text = keyword;
        _searchBloc.add(SearchUsers(keyword: keyword));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 4.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withOpacity(0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 18.w,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                keyword,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18.w,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                _searchBloc.add(RemoveSearchHistoryItem(keyword));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(String keyword) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 80.w,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            '未找到"$keyword"相关用户',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '请尝试其他搜索词或检查拼写',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, UserSearchState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: state.searchResults.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == state.searchResults.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h),
              child:
                  state.status == UserSearchStatus.loadMore
                      ? CircularProgressIndicator()
                      : Text(
                        '上拉加载更多',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
            ),
          );
        }

        final user = state.searchResults[index];
        return _buildUserItem(context, user);
      },
    );
  }

  Widget _buildUserItem(BuildContext context, User user) {
    return InkWell(
      onTap: () {
        // 导航到用户个人页面
        context.push('/profile/${user.id}');
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            AppAvatar(
              imageUrl: user.avatar,
              size: 50,
              placeholderText: user.nickname,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nickname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      user.bio!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _buildFollowButton(user.isFollowed ?? false),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(bool isFollowing) {
    return Container(
      height: 32.h,
      width: isFollowing ? 80.w : 70.w,
      decoration: BoxDecoration(
        color:
            isFollowing
                ? Theme.of(context).colorScheme.surfaceVariant
                : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              isFollowing
                  ? Theme.of(context).colorScheme.outlineVariant
                  : Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          isFollowing ? '已关注' : '关注',
          style: TextStyle(
            color:
                isFollowing
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
