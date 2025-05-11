import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';
import 'package:text_sphere_app/presentation/pages/following_search_page.dart';

class FollowingPage extends StatefulWidget {
  final String? userId;

  const FollowingPage({Key? key, this.userId}) : super(key: key);

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  // 模拟关注数据
  final List<Map<String, dynamic>> _following = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 模拟加载数据
    Future.delayed(const Duration(milliseconds: 500), () {
      _loadFollowing();
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _loadFollowing() {
    // 生成20个模拟关注数据
    for (int i = 1; i <= 20; i++) {
      _following.add({
        'id': 'user$i',
        'name': '用户$i',
        'username': 'user$i',
        'avatar': 'https://i.pravatar.cc/150?u=follow$i',
        'isFollowingBack': i % 4 == 0, // 每四个用户中有一个是互相关注的
        'followTime': '${i % 12 + 1}天前',
        'bio': i % 2 == 0 ? '这是用户$i的个人简介，介绍了TA的兴趣爱好和专业领域。' : null,
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
          isCurrentUser ? '我的关注' : '${widget.userId}的关注',
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
              // 导航到关注搜索页面
              try {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => FollowingSearchPage(
                          following: _following,
                          userId: widget.userId,
                        ),
                  ),
                );
              } catch (e) {
                print('直接导航到关注搜索页面失败: $e');

                try {
                  if (widget.userId == null) {
                    context.go(
                      '/user/following/search',
                      extra: {'following': _following},
                    );
                  } else {
                    context.go(
                      '/user/${widget.userId}/following/search',
                      extra: {'following': _following},
                    );
                  }
                } catch (e) {
                  print('go_router导航到关注搜索页面失败: $e');
                }
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingView()
              : _following.isEmpty
              ? _buildEmptyView()
              : _buildFollowingList(),
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
            Icons.people_outline,
            size: 64.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无关注',
            style: AppTheme.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '去发现感兴趣的人并关注他们',
            style: AppTheme.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              // 跳转到推荐用户页面
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              '查找推荐用户',
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: _following.length,
      separatorBuilder:
          (context, index) => Divider(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            height: 1,
            indent: 80.w,
            endIndent: 16.w,
          ),
      itemBuilder: (context, index) {
        final following = _following[index];
        return _buildFollowingItem(following);
      },
    );
  }

  Widget _buildFollowingItem(Map<String, dynamic> following) {
    final bool isFollowingBack = following['isFollowingBack'] as bool;
    final String? bio = following['bio'] as String?;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment:
            bio != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          AppAvatar(
            imageUrl: following['avatar'],
            size: 50,
            placeholderText: following['name'],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  following['name'],
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      '@${following['username']}',
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
                SizedBox(height: 4.h),
                Text(
                  '关注于 ${following['followTime']}',
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
          _buildFollowButton(),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return InkWell(
      onTap: () {
        // 处理取消关注
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          '已关注',
          style: TextStyle(
            fontSize: 13.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
