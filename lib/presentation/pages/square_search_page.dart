import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/post.dart';
import '../blocs/square/square_search_bloc.dart';
import '../blocs/square/square_search_event.dart';
import '../blocs/square/square_search_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';

class SquareSearchPage extends StatefulWidget {
  final SquareSearchBloc searchBloc;

  const SquareSearchPage({Key? key, required this.searchBloc})
    : super(key: key);

  @override
  State<SquareSearchPage> createState() => _SquareSearchPageState();
}

class _SquareSearchPageState extends State<SquareSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  late SquareSearchBloc _searchBloc;

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
        state.status != SquareSearchStatus.loadMore &&
        !state.hasReachedMax) {
      _searchBloc.add(
        LoadMoreSearchResults(keyword: state.keyword, pageSize: 10),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      // 添加整个页面的手势检测，点击空白处时取消焦点
      onTap: () {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      },
      // 确保GestureDetector可以接收全屏幕的点击事件
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: StreamBuilder<SquareSearchState>(
          stream: _searchBloc.stream,
          initialData: _searchBloc.state,
          builder: (context, snapshot) {
            final state = snapshot.data!;

            if (state.status == SquareSearchStatus.initial) {
              return _buildEmptySearch();
            }

            if (state.status == SquareSearchStatus.loading &&
                state.searchResults.isEmpty) {
              return Center(child: LoadingIndicator());
            }

            if (state.status == SquareSearchStatus.failure &&
                state.searchResults.isEmpty) {
              return ErrorView(
                message: '搜索失败: ${state.errorMessage}',
                onRetry: () {
                  _searchBloc.add(SearchPosts(keyword: state.keyword));
                },
              );
            }

            if (state.searchResults.isEmpty) {
              return _buildNoResults(state.keyword);
            }

            return _buildSearchResults(context, state);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
        onPressed: () => context.pop(),
      ),
      title: StreamBuilder<SquareSearchState>(
        stream: _searchBloc.stream,
        initialData: _searchBloc.state,
        builder: (context, snapshot) {
          return TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: '搜索帖子、话题或用户',
              hintStyle: TextStyle(color: theme.hintColor, fontSize: 16.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.clear, color: theme.hintColor),
                        onPressed: () {
                          _searchController.clear();
                          _searchBloc.add(ClearSearchResults());
                        },
                      )
                      : null,
            ),
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              _searchBloc.add(UpdateSearchKeyword(value));
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _searchBloc.add(SearchPosts(keyword: value));
              }
            },
          );
        },
      ),
      actions: [
        StreamBuilder<SquareSearchState>(
          stream: _searchBloc.stream,
          initialData: _searchBloc.state,
          builder: (context, snapshot) {
            return TextButton(
              onPressed: () {
                if (_searchController.text.trim().isNotEmpty) {
                  _searchBloc.add(SearchPosts(keyword: _searchController.text));
                  FocusScope.of(context).unfocus();
                }
              },
              child: Text(
                '搜索',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptySearch() {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '热门搜索',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 15.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children:
                [
                  '新冠疫情',
                  '健身',
                  '读书',
                  '美食',
                  '旅行',
                  '数码',
                  '电影',
                  '音乐',
                  '游戏',
                  '投资',
                ].map((tag) => _buildSearchTag(tag)).toList(),
          ),
          SizedBox(height: 30.h),
          Text(
            '搜索历史',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 15.h),
          // 模拟搜索历史
          Column(
            children: [
              _buildHistoryItem('Flutter开发'),
              _buildHistoryItem('最新手机评测'),
              _buildHistoryItem('美食推荐'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTag(String tag) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        _searchController.text = tag;
        _searchBloc.add(SearchPosts(keyword: tag));
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String keyword) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.history, color: theme.iconTheme.color),
      title: Text(
        keyword,
        style: TextStyle(
          fontSize: 16.sp,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14.sp,
        color: theme.iconTheme.color,
      ),
      onTap: () {
        _searchController.text = keyword;
        _searchBloc.add(SearchPosts(keyword: keyword));
      },
    );
  }

  Widget _buildNoResults(String keyword) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60.sp, color: theme.disabledColor),
          SizedBox(height: 20.h),
          Text(
            '未找到与"$keyword"相关的内容',
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '尝试其他关键词',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SquareSearchState state) {
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
                  state.status == SquareSearchStatus.loadMore
                      ? CircularProgressIndicator()
                      : Text('上拉加载更多', style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        final post = state.searchResults[index];
        return _buildPostItem(context, post);
      },
    );
  }

  Widget _buildPostItem(BuildContext context, Post post) {
    final bool hasImage = post.hasImages;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        context.push('/home/square/detail/${post.id}');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage:
                        post.userAvatar != null && post.userAvatar.isNotEmpty
                            ? CachedNetworkImageProvider(post.userAvatar)
                            : null,
                    child:
                        post.userAvatar == null || post.userAvatar.isEmpty
                            ? Icon(Icons.person, color: Colors.grey[400])
                            : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.username,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _formatDateTime(post.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (post.title.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                post.content,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasImage && post.images.isNotEmpty)
              Container(
                height: 200.h,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: post.images.first,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[200],
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.error),
                      ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPostAction(
                    Icons.favorite_border,
                    post.likeCount.toString(),
                  ),
                  _buildPostAction(
                    Icons.chat_bubble_outline,
                    post.commentCount.toString(),
                  ),
                  _buildPostAction(Icons.share, '分享'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostAction(IconData icon, String text) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18.sp, color: theme.iconTheme.color),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(fontSize: 14.sp, color: theme.iconTheme.color),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
