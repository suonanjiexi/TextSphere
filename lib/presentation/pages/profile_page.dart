// lib/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/components/app_avatar.dart';
import 'package:text_sphere_app/domain/entities/membership.dart';
import 'package:text_sphere_app/presentation/widgets/app_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/presentation/pages/following_page.dart';
import 'package:text_sphere_app/presentation/pages/followers_page.dart';
import 'package:text_sphere_app/core/di/injection_container.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['帖子', '收藏', '喜欢'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = widget.userId == null;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 320.h,
              pinned: true,
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              scrolledUnderElevation: 1,
              automaticallyImplyLeading: !isCurrentUser,
              actions:
                  isCurrentUser
                      ? [
                        IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () {
                            context.push('/settings');
                          },
                        ),
                      ]
                      : [
                        IconButton(
                          icon: Icon(
                            Icons.share_outlined,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () {},
                        ),
                      ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(isCurrentUser),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(56.h),
                child: Container(
                  color: theme.colorScheme.surface,
                  child: TabBar(
                    controller: _tabController,
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorColor: AppTheme.primaryColor,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(),
            _buildCollectionsTab(),
            _buildLikesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isCurrentUser) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 320.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 顶部背景
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 140.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [
                            AppTheme.primaryColor.withOpacity(0.8),
                            theme.colorScheme.primaryContainer.withOpacity(0.6),
                          ]
                          : [
                            AppTheme.primaryColor.withOpacity(0.9),
                            theme.colorScheme.primaryContainer,
                          ],
                ),
              ),
            ),
          ),

          // 信息卡片
          Positioned(
            top: 100.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.r, 60.r, 20.r, 20.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isCurrentUser ? '我的用户名' : '用户${widget.userId}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '@${isCurrentUser ? 'myusername' : 'user${widget.userId}'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '这是我的个人简介，可以介绍一下自己。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(
                        '1.2k',
                        '关注',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      FollowingPage(userId: widget.userId),
                            ),
                          );
                        },
                      ),
                      Container(
                        height: 30.h,
                        width: 1,
                        color: theme.dividerColor,
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                      ),
                      _buildStatItem(
                        '5.7k',
                        '粉丝',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      FollowersPage(userId: widget.userId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 头像
          Positioned(
            top: 60.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 90.r,
                height: 90.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(45.r),
                  child: AppAvatar(
                    imageUrl:
                        'https://i.pravatar.cc/150?u=${isCurrentUser ? 1 : widget.userId}',
                    onTap: () {},
                    radius: 45.r,
                    membershipLevel:
                        widget.userId == null
                            ? null
                            : widget.userId?.endsWith('vip') == true
                            ? MembershipLevel.gold
                            : null,
                  ),
                ),
              ),
            ),
          ),

          // 关注/发消息按钮
          if (!isCurrentUser)
            Positioned(
              bottom: 15.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: 关注用户
                    },
                    icon: Icon(Icons.person_add_alt_1_outlined, size: 18.sp),
                    label: Text('关注'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: 发消息
                    },
                    icon: Icon(Icons.chat_bubble_outline, size: 18.sp),
                    label: Text('发消息'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String count,
    String label, {
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return _buildContentList(
      itemCount: 10,
      itemBuilder: (context, index) => _buildPostItem(index),
    );
  }

  Widget _buildCollectionsTab() {
    return _buildContentList(
      itemCount: 5,
      itemBuilder: (context, index) => _buildCollectedPostItem(index),
    );
  }

  Widget _buildLikesTab() {
    return _buildContentList(
      itemCount: 8,
      itemBuilder: (context, index) => _buildLikeItem(index),
    );
  }

  Widget _buildContentList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }

  Widget _buildPostItem(int index) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: Duration(milliseconds: 250),
      opacity: 1.0,
      curve: Curves.easeInOut,
      child: Card(
        margin: EdgeInsets.only(bottom: 6.h, left: 0, right: 0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color:
                    theme.brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 2),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppAvatar(
                      imageUrl: 'https://i.pravatar.cc/150?u=avatar${index}',
                      radius: 20.r,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userId == null
                                ? '我的用户名'
                                : '用户${widget.userId}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                          Text(
                            '${index + 1}天前',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20.r,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  '这是我发布的第${index + 1}条帖子内容，展示了我的日常生活和想法。',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                if (index % 2 == 0) ...[
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: AppNetworkImage(
                      imageUrl:
                          'https://picsum.photos/seed/post${index}/400/300',
                      height: 180.h,
                      width: MediaQuery.of(context).size.width - 64.w,
                      borderRadius: BorderRadius.circular(12.r),
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _buildActionChip(
                      icon: Icons.favorite_outline,
                      label: '${42 - index * 3}',
                    ),
                    SizedBox(width: 16.w),
                    _buildActionChip(
                      icon: Icons.chat_bubble_outline,
                      label: '${12 - index}',
                    ),
                    SizedBox(width: 16.w),
                    _buildActionChip(icon: Icons.share_outlined, label: '分享'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectedPostItem(int index) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 6.h, left: 0, right: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(
                  imageUrl: 'https://i.pravatar.cc/150?u=user${10 - index}',
                  radius: 20.r,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '用户${10 - index}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${index + 3}天前收藏',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark, color: Colors.amber, size: 20.r),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '这是您收藏的第${index + 1}条帖子内容，可能包含您感兴趣的信息或想要稍后阅读的内容。',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: AppNetworkImage(
                imageUrl: 'https://picsum.photos/seed/collect${index}/400/300',
                height: 150.h,
                width: MediaQuery.of(context).size.width - 64.w,
                borderRadius: BorderRadius.circular(12.r),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildActionChip(
                  icon: Icons.favorite_outline,
                  label: '${58 - index * 5}',
                ),
                SizedBox(width: 16.w),
                _buildActionChip(
                  icon: Icons.chat_bubble_outline,
                  label: '${24 - index * 2}',
                ),
                SizedBox(width: 16.w),
                _buildActionChip(
                  icon: Icons.bookmark,
                  label: '已收藏',
                  color: Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeItem(int index) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 6.h, left: 0, right: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      'U${index + 1}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '用户${index + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${index + 1}小时前',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.red, size: 20.r),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '这是用户${index + 1}发布的内容，您点赞了这条内容。',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 12.h),
            if (index % 2 == 1) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: AppNetworkImage(
                  imageUrl: 'https://picsum.photos/seed/post${index}/400/300',
                  height: 150.h,
                  width: MediaQuery.of(context).size.width - 64.w,
                  borderRadius: BorderRadius.circular(12.r),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 12.h),
            ],
            Row(
              children: [
                _buildActionChip(
                  icon: Icons.favorite,
                  label: '${30 + index * 2}',
                  color: Colors.red,
                ),
                SizedBox(width: 16.w),
                _buildActionChip(
                  icon: Icons.chat_bubble_outline,
                  label: '${8 + index}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: color ?? theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
