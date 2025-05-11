import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/domain/entities/circle_post.dart';
import 'package:text_sphere_app/domain/entities/circle.dart';
import 'package:text_sphere_app/presentation/widgets/app_network_image.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';
import 'package:text_sphere_app/presentation/widgets/loading_indicator.dart';

class CircleSearchPage extends StatefulWidget {
  final String circleId;
  final String circleName;

  const CircleSearchPage({
    Key? key,
    required this.circleId,
    required this.circleName,
  }) : super(key: key);

  @override
  State<CircleSearchPage> createState() => _CircleSearchPageState();
}

class _CircleSearchPageState extends State<CircleSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  // 搜索状态
  bool _isSearching = false;
  bool _hasSearched = false;
  String _searchKeyword = '';

  // 模拟数据
  List<CirclePost> _searchResults = [];
  List<String> _searchHistory = ['Flutter开发', '新手教程', '代码分享'];
  List<String> _hotTopics = ['公告', '新功能', '问题讨论', '经验分享', '求助', '资源', '活动'];

  @override
  void initState() {
    super.initState();
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

  // 模拟搜索逻辑
  void _performSearch(String keyword) {
    if (keyword.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchKeyword = keyword;
    });

    // 模拟网络请求延迟
    Future.delayed(const Duration(seconds: 1), () {
      // 模拟搜索结果
      final List<CirclePost> results = List.generate(
        10,
        (index) => CirclePost(
          id: 'post$index',
          circleId: widget.circleId,
          title: '${keyword} 相关讨论 ${index + 1}',
          content: '这是关于 $keyword 的帖子内容，包含了相关信息和讨论。帖子序号：${index + 1}',
          imageUrls:
              index % 2 == 0
                  ? ['https://picsum.photos/seed/post$index/400/300']
                  : [],
          authorId: 'user${index % 5 + 1}',
          authorName: '用户${index % 5 + 1}',
          authorAvatar: 'https://i.pravatar.cc/150?u=user${index % 5 + 1}',
          createdAt: '${index + 1}天前',
          likesCount: 42 - index % 30,
          commentsCount: 18 - index % 15,
          viewsCount: 108 + index * 5,
          isLiked: index % 3 == 0,
          isPinned: false,
          isEssence: index % 5 == 0,
        ),
      );

      setState(() {
        _isSearching = false;
        _hasSearched = true;
        _searchResults = keyword.toLowerCase().contains('无结果') ? [] : results;

        // 添加到搜索历史
        if (!_searchHistory.contains(keyword)) {
          _searchHistory.insert(0, keyword);
          if (_searchHistory.length > 10) {
            _searchHistory = _searchHistory.sublist(0, 10);
          }
        }
      });
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _hasSearched = false;
      _searchResults = [];
      _searchKeyword = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body:
            _isSearching
                ? Center(child: LoadingIndicator())
                : _hasSearched
                ? _buildSearchResults()
                : _buildInitialContent(),
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
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '在${widget.circleName}中搜索',
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
                    onPressed: _clearSearch,
                  )
                  : null,
        ),
        style: TextStyle(
          fontSize: 16.sp,
          color: theme.textTheme.bodyMedium?.color,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            _performSearch(value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_searchController.text.trim().isNotEmpty) {
              _performSearch(_searchController.text);
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
        ),
      ],
    );
  }

  Widget _buildInitialContent() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '圈内热门话题',
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
            children: _hotTopics.map((tag) => _buildSearchTag(tag)).toList(),
          ),
          SizedBox(height: 30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '搜索历史',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              if (_searchHistory.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchHistory.clear();
                    });
                  },
                  child: Text(
                    '清除',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          if (_searchHistory.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  '暂无搜索历史',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            )
          else
            Column(
              children:
                  _searchHistory
                      .map((keyword) => _buildHistoryItem(keyword))
                      .toList(),
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
        _performSearch(tag);
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
        _performSearch(keyword);
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final post = _searchResults[index];
        return _buildPostItem(post);
      },
    );
  }

  Widget _buildNoResults() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60.sp, color: theme.disabledColor),
          SizedBox(height: 20.h),
          Text(
            '未找到与"$_searchKeyword"相关的内容',
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

  Widget _buildPostItem(CirclePost post) {
    final theme = Theme.of(context);
    final bool hasImage = post.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: () {
        context.push('/circle/post/${post.id}');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 作者信息栏
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                children: [
                  AppAvatar(
                    imageUrl: post.authorAvatar,
                    size: 40,
                    placeholderText: post.authorName,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          post.createdAt,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20.r,
                  ),
                ],
              ),
            ),

            // 帖子内容
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 帖子图片
            if (hasImage) ...[
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
                child: AppNetworkImage(
                  imageUrl: post.imageUrls.first,
                  height: 180.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ] else
              SizedBox(height: 12.h),

            // 帖子操作栏
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                children: [
                  _buildActionButton(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: post.likesCount.toString(),
                    color: post.isLiked ? Colors.red : null,
                  ),
                  SizedBox(width: 16.w),
                  _buildActionButton(
                    icon: Icons.comment_outlined,
                    label: post.commentsCount.toString(),
                  ),
                  SizedBox(width: 16.w),
                  _buildActionButton(
                    icon: Icons.remove_red_eye_outlined,
                    label: post.viewsCount.toString(),
                  ),
                  Spacer(),
                  if (post.isEssence)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '精华',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.amber,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16.r,
          color: color ?? theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
