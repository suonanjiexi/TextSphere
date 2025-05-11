import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';

class FollowersSearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> followers;
  final String? userId;

  const FollowersSearchPage({Key? key, required this.followers, this.userId})
    : super(key: key);

  @override
  State<FollowersSearchPage> createState() => _FollowersSearchPageState();
}

class _FollowersSearchPageState extends State<FollowersSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    print('FollowersSearchPage初始化：收到${widget.followers.length}个粉丝数据');
    _searchResults = widget.followers;
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
        _searchResults = widget.followers;
        _isSearching = false;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final filteredResults =
        widget.followers.where((follower) {
          final name = (follower['name'] as String).toLowerCase();
          final username = (follower['username'] as String).toLowerCase();
          return name.contains(lowercaseQuery) ||
              username.contains(lowercaseQuery);
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
            hintText: isCurrentUser ? '搜索我的粉丝' : '搜索${widget.userId}的粉丝',
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
                  final follower = _searchResults[index];
                  return _buildFollowerItem(follower);
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
            _isSearching ? '未找到符合"${_searchController.text}"的粉丝' : '暂无粉丝',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowerItem(Map<String, dynamic> follower) {
    final bool isFollowing = follower['isFollowing'] as bool;

    return InkWell(
      onTap: () {
        // 导航到用户个人页面
        context.push('/profile/${follower['id']}');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            AppAvatar(
              imageUrl: follower['avatar'],
              size: 50,
              placeholderText: follower['name'],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    follower['name'],
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '@${follower['username']}',
                    style: AppTheme.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '关注于 ${follower['followTime']}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _buildFollowButton(isFollowing),
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
          isFollowing ? '互相关注' : '关注',
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
