import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/domain/entities/circle.dart';
import 'package:text_sphere_app/domain/entities/circle_post.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';
import 'package:text_sphere_app/presentation/widgets/app_network_image.dart';
import 'package:text_sphere_app/presentation/widgets/loading_indicator.dart';
import 'package:like_button/like_button.dart';

class CircleDetailPage extends StatefulWidget {
  final String circleId;

  const CircleDetailPage({Key? key, required this.circleId}) : super(key: key);

  @override
  State<CircleDetailPage> createState() => _CircleDetailPageState();
}

class _CircleDetailPageState extends State<CircleDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['全部', '精华', '最新', '热门'];

  // 模拟数据 - 实际应用中应该使用BLoC获取数据
  late Circle _circle;
  late List<CirclePost> _posts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // 模拟加载数据
    _loadData();
  }

  Future<void> _loadData() async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    // 模拟圈子数据
    _circle = Circle(
      id: widget.circleId,
      name: '探索Flutter圈',
      description: '这是一个讨论Flutter开发技术的圈子，欢迎各位开发者加入交流和分享经验。',
      avatarUrl: 'https://i.pravatar.cc/150?u=circle${widget.circleId}',
      coverUrl: 'https://picsum.photos/seed/circle${widget.circleId}/600/200',
      membersCount: 3258,
      postsCount: 1257,
      isJoined: false,
      category: '技术',
      tags: ['Flutter', 'Dart', '移动开发', '跨平台'],
      createdAt: '2023-01-15',
      creatorId: 'user1',
      creatorName: '张三',
    );

    // 模拟帖子数据
    _posts = List.generate(
      20,
      (index) => CirclePost(
        id: 'post$index',
        circleId: widget.circleId,
        title: '${index % 3 == 0 ? "[置顶] " : ""}Flutter ${index + 1}.0 新特性解析',
        content: '这是帖子内容，讲解了Flutter ${index + 1}.0版本的新特性和使用方法，希望对大家有所帮助。',
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
        isPinned: index % 10 == 0,
        isEssence: index % 5 == 0,
      ),
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: LoadingIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.h,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    // 实现圈内搜索功能
                    _showCircleSearchDialog();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    _showCircleOptions();
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(background: _buildCircleHeader()),
            ),
            SliverToBoxAdapter(child: _buildCircleInfo()),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: _buildPostsList(_posts),
            ), // 全部
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: _buildPostsList(
                _posts.where((post) => post.isEssence).toList(),
              ),
            ), // 精华
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: _buildPostsList(_posts),
            ), // 最新
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: _buildPostsList(
                _posts.where((post) => post.likesCount > 20).toList(),
              ),
            ), // 热门
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCircleHeader() {
    return Stack(
      children: [
        // 背景封面
        Positioned.fill(
          child: AppNetworkImage(imageUrl: _circle.coverUrl, fit: BoxFit.cover),
        ),
        // 渐变遮罩
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        // 圈子名称
        Positioned(
          left: 20.w,
          bottom: 20.h,
          right: 120.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _circle.name,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _circle.category,
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${_circle.membersCount}成员',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${_circle.postsCount}帖子',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 加入按钮
        Positioned(right: 20.w, bottom: 20.h, child: _buildJoinButton()),
      ],
    );
  }

  Widget _buildCircleInfo() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '圈子简介',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _circle.description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 16.h),
          // 圈子标签
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                _circle.tags.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<CirclePost> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 48.r, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              '暂无帖子',
              style: AppTheme.bodyMedium.copyWith(color: Colors.grey[500]),
            ),
            SizedBox(height: 8.h),
            Text(
              '快来发布第一个帖子吧',
              style: AppTheme.bodySmall.copyWith(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostItem(post);
      },
    );
  }

  Widget _buildPostItem(CirclePost post) {
    return GestureDetector(
      onTap: () {
        // 导航到帖子详情页
        context.push('/circle/post/${post.id}');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          post.createdAt,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20.r,
                    ),
                    onPressed: () {
                      _showPostOptions(post);
                    },
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 帖子图片
            if (post.imageUrls.isNotEmpty) ...[
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
                  LikeButton(
                    size: 16.r,
                    isLiked: post.isLiked,
                    likeCount: post.likesCount,
                    countBuilder: (int? count, bool isLiked, String text) {
                      return Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color:
                            isLiked
                                ? Colors.red
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                        size: 16.r,
                      );
                    },
                    onTap: (isLiked) async {
                      // 处理点赞操作 - 实际应用中应调用API或更新状态
                      print('点赞状态变更: ${post.id}, 当前状态: $isLiked');
                      // 返回操作后的新状态
                      return !isLiked;
                    },
                  ),
                  SizedBox(width: 16.w),
                  _buildActionButton(
                    icon: Icons.comment_outlined,
                    label: post.commentsCount.toString(),
                    onTap: () {
                      // 评论
                      context.push('/circle/post/${post.id}?openComment=true');
                    },
                  ),
                  SizedBox(width: 16.w),
                  _buildActionButton(
                    icon: Icons.remove_red_eye_outlined,
                    label: post.viewsCount.toString(),
                    onTap: null,
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
                  if (post.isPinned) ...[
                    if (post.isEssence) SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '置顶',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _circle = _circle.copyWith(isJoined: !_circle.isJoined);
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _circle.isJoined
                ? Theme.of(context).colorScheme.surfaceVariant
                : Theme.of(context).colorScheme.primary,
        foregroundColor:
            _circle.isJoined
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
      child: Text(
        _circle.isJoined ? '已加入' : '加入圈子',
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.r,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showCircleOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.share),
                title: Text('分享圈子'),
                onTap: () {
                  Navigator.pop(context);
                  // 分享圈子
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('圈子信息'),
                onTap: () {
                  Navigator.pop(context);
                  // 查看圈子信息
                },
              ),
              ListTile(
                leading: Icon(_circle.isJoined ? Icons.exit_to_app : Icons.add),
                title: Text(_circle.isJoined ? '退出圈子' : '加入圈子'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _circle = _circle.copyWith(isJoined: !_circle.isJoined);
                  });
                },
              ),
              if (_circle.isJoined)
                ListTile(
                  leading: Icon(Icons.flag_outlined),
                  title: Text('举报圈子'),
                  onTap: () {
                    Navigator.pop(context);
                    // 举报圈子
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showPostOptions(CirclePost post) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.share),
                title: Text('分享帖子'),
                onTap: () {
                  Navigator.pop(context);
                  // 分享帖子
                },
              ),
              ListTile(
                leading: Icon(Icons.bookmark_border),
                title: Text('收藏帖子'),
                onTap: () {
                  Navigator.pop(context);
                  // 收藏帖子
                },
              ),
              ListTile(
                leading: Icon(Icons.flag_outlined),
                title: Text('举报'),
                onTap: () {
                  Navigator.pop(context);
                  // 举报帖子
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreatePostDialog() {
    if (!_circle.isJoined) {
      // 如果未加入圈子，提示用户先加入
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请先加入圈子后再发布帖子'),
          action: SnackBarAction(
            label: '加入',
            onPressed: () {
              setState(() {
                _circle = _circle.copyWith(isJoined: true);
              });
            },
          ),
        ),
      );
      return;
    }

    // 跳转到发帖页面
    context.push('/circle/${_circle.id}/create-post');
  }

  void _showCircleSearchDialog() {
    // 跳转到圈子搜索页面，确保参数正确传递

    print('跳转到搜索页面: ');
  }

  void _performSearch(String keyword) {
    // 模拟搜索过程
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在搜索: $keyword'), duration: Duration(seconds: 2)),
    );

    // 这里应该实现真正的搜索逻辑
    // 例如: 过滤帖子列表或者请求后端接口
    final filteredPosts =
        _posts.where((post) {
          return post.title.toLowerCase().contains(keyword.toLowerCase()) ||
              post.content.toLowerCase().contains(keyword.toLowerCase()) ||
              post.authorName.toLowerCase().contains(keyword.toLowerCase());
        }).toList();

    // 显示搜索结果或者提示信息
    if (filteredPosts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('未找到与"$keyword"相关的内容'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // 刷新状态，显示搜索结果
      setState(() {
        _posts = filteredPosts;
        _tabController.animateTo(0); // 切换到"全部"标签
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('找到${filteredPosts.length}条相关内容'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

// TabBar代理类
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
