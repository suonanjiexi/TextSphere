import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';
import 'package:text_sphere_app/presentation/pages/followers_search_page.dart';

class FollowersPage extends StatefulWidget {
  final String? userId;

  const FollowersPage({Key? key, this.userId}) : super(key: key);

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  // 模拟粉丝数据
  final List<Map<String, dynamic>> _followers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 模拟加载数据
    Future.delayed(const Duration(milliseconds: 500), () {
      _loadFollowers();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _loadFollowers() {
    // 生成15个模拟粉丝数据
    for (int i = 1; i <= 15; i++) {
      _followers.add({
        'id': 'user$i',
        'name': '用户$i',
        'username': 'user$i',
        'avatar': 'https://i.pravatar.cc/150?u=user$i',
        'isFollowing': i % 3 == 0, // 每三个用户中有一个是互相关注的
        'followTime': '${i % 7 + 1}天前',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = widget.userId == null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isCurrentUser ? '我的粉丝' : '${widget.userId}的粉丝',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              // 导航到粉丝搜索页面
              try {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => FollowersSearchPage(
                          followers: _followers,
                          userId: widget.userId,
                        ),
                  ),
                );
              } catch (e) {
                print('直接导航到粉丝搜索页面失败: $e');

                try {
                  if (widget.userId == null) {
                    context.go(
                      '/user/followers/search',
                      extra: {'followers': _followers},
                    );
                  } else {
                    context.go(
                      '/user/${widget.userId}/followers/search',
                      extra: {'followers': _followers},
                    );
                  }
                } catch (e) {
                  print('go_router导航到粉丝搜索页面失败: $e');
                }
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingView()
              : _followers.isEmpty
              ? _buildEmptyView()
              : _buildFollowersList(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无粉丝',
            style: AppTheme.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '分享你的内容，吸引更多粉丝关注你',
            style: AppTheme.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowersList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: _followers.length,
      separatorBuilder:
          (context, index) => Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            height: 1,
            indent: 80.w,
            endIndent: 16.w,
          ),
      itemBuilder: (context, index) {
        final follower = _followers[index];
        return _buildFollowerItem(follower);
      },
    );
  }

  Widget _buildFollowerItem(Map<String, dynamic> follower) {
    final bool isFollowing = follower['isFollowing'] as bool;

    return Padding(
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
    );
  }

  Widget _buildFollowButton(bool isFollowing) {
    return InkWell(
      onTap: () {
        // 处理关注/取消关注
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
              isFollowing
                  ? Theme.of(context).colorScheme.surfaceVariant
                  : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20.r),
          border:
              isFollowing
                  ? Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.5),
                    width: 1,
                  )
                  : null,
        ),
        child: Text(
          isFollowing ? '已关注' : '关注',
          style: TextStyle(
            fontSize: 13.sp,
            color:
                isFollowing
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
