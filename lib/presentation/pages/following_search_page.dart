import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';

class FollowingSearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> following;
  final String? userId;

  const FollowingSearchPage({Key? key, required this.following, this.userId})
    : super(key: key);

  @override
  State<FollowingSearchPage> createState() => _FollowingSearchPageState();
}

class _FollowingSearchPageState extends State<FollowingSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    print('FollowingSearchPage初始化：收到${widget.following.length}个关注数据');
    _searchResults = widget.following;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 自动获取焦点
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = widget.following;
        _isSearching = false;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filteredResults =
        widget.following.where((followed) {
          final name = (followed['name'] as String).toLowerCase();
          final username = (followed['username'] as String).toLowerCase();
          final bio = followed['bio'] as String?;

          return name.contains(lowercaseQuery) ||
              username.contains(lowercaseQuery) ||
              (bio != null && bio.toLowerCase().contains(lowercaseQuery));
        }).toList();

    setState(() {
      _searchResults = filteredResults;
      _isSearching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = widget.userId == null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: isCurrentUser ? '搜索我的关注' : '搜索${widget.userId}的关注',
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
                        _performSearch('');
                      },
                    )
                    : null,
          ),
          style: TextStyle(fontSize: 16.sp),
          textInputAction: TextInputAction.search,
          onChanged: _performSearch,
        ),
      ),
      body:
          _searchResults.isEmpty
              ? _buildEmptyResults()
              : ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                itemCount: _searchResults.length,
                separatorBuilder:
                    (context, index) => Divider(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                      height: 1,
                      indent: 80.w,
                      endIndent: 16.w,
                    ),
                itemBuilder: (context, index) {
                  final followed = _searchResults[index];
                  return _buildFollowingItem(followed);
                },
              ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_search,
            size: 80.w,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            _isSearching ? '未找到符合"${_searchController.text}"的关注' : '暂无关注',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingItem(Map<String, dynamic> followed) {
    final bool isFollowingBack = followed['isFollowingBack'] as bool;
    final String? bio = followed['bio'] as String?;

    return InkWell(
      onTap: () {
        // 导航到用户个人页面
        context.push('/profile/${followed['id']}');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment:
              bio != null
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
          children: [
            AppAvatar(
              imageUrl: followed['avatar'],
              size: 50,
              placeholderText: followed['name'],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    followed['name'],
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        '@${followed['username']}',
                        style: AppTheme.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isFollowingBack) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '互相关注',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (bio != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      bio,
                      style: AppTheme.bodySmall.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _buildFollowButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton() {
    return Container(
      height: 32.h,
      width: 70.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '已关注',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
