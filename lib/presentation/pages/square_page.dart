// lib/presentation/pages/square_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/domain/entities/post.dart';
import 'package:text_sphere_app/domain/entities/membership.dart';
import 'package:text_sphere_app/presentation/blocs/square/square_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/square/square_event.dart';
import 'package:text_sphere_app/presentation/blocs/square/square_state.dart';
import 'package:text_sphere_app/presentation/widgets/loading_indicator.dart';
import 'package:text_sphere_app/presentation/widgets/error_view.dart';
import 'package:text_sphere_app/presentation/widgets/parabolic_fab.dart';
import 'package:text_sphere_app/utils/responsive_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'package:shimmer/shimmer.dart';
import 'package:text_sphere_app/presentation/widgets/app_network_image.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart'
    as widget_avatar;
import 'package:text_sphere_app/components/app_avatar.dart';
import 'package:text_sphere_app/utils/performance_utils.dart';
import 'package:text_sphere_app/utils/performance_widgets.dart';
import 'package:text_sphere_app/utils/strategic_image_cache.dart';
import 'package:text_sphere_app/presentation/widgets/skeleton_loading.dart';
import 'package:like_button/like_button.dart';

class SquarePage extends StatefulWidget {
  const SquarePage({Key? key}) : super(key: key);

  @override
  State<SquarePage> createState() => _SquarePageState();
}

class _SquarePageState extends State<SquarePage> with TickerProviderStateMixin {
  final List<String> _topics = ['全部', '热门', '本地', '关注'];
  final ScrollController _scrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();

  // Tab控制器
  late TabController _tabController;

  // 控制器对象
  final ParabolicFabController _fabController = ParabolicFabController();

  // 添加顶部区域动画控制器
  late AnimationController _searchBarAnimationController;
  late Animation<Offset> _searchBarSlideAnimation;
  late AnimationController _tabBarAnimationController;
  late Animation<Offset> _tabBarSlideAnimation;

  // 两个区域是否可见
  bool _isSearchBarVisible = true;
  bool _isTabBarVisible = true;

  // 顶部区域高度
  final double _searchBarHeight = 54.0; // 搜索框高度
  final double _tabBarHeight = 44.0; // Tab栏高度
  final double _topMargin = 8.0;

  // 上一次滚动位置
  double _lastScrollOffset = 0;

  // 滑动计时器
  DateTime? _lastScrollTime;
  bool _isScrolling = false;

  // 将图片URL转换为Lorem Picsum格式的URL
  String _transformToLoremPicsum(
    String originalUrl, {
    int width = 800,
    int height = 600,
  }) {
    // 使用原始URL生成一个确定性的种子，使相同的URL始终生成相同的图片
    final int seed = originalUrl.hashCode.abs() % 1000;

    // 确保尺寸至少为100
    width = math.max(width, 100);
    height = math.max(height, 100);

    // 构造Lorem Picsum URL，添加图片ID（使用种子）和尺寸
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  @override
  void initState() {
    super.initState();
    _listScrollController.addListener(_onScroll);

    // 初始化Tab控制器
    _tabController = TabController(length: _topics.length, vsync: this);

    // Tab切换监听
    _tabController.addListener(() {
      // 无论是点击还是滑动切换，都触发数据加载
      final currentTopic = _topics[_tabController.index];
      final topic = currentTopic == '全部' ? '' : currentTopic;

      // 检查是否需要加载新数据
      final currentState = context.read<SquareBloc>().state;
      if (currentState.currentTopic != topic) {
        context.read<SquareBloc>().add(SwitchTopic(topic: topic));
      }
    });

    // 初始化搜索框动画控制器
    _searchBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _searchBarSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.0), // 增加偏移量，确保完全隐藏
    ).animate(
      CurvedAnimation(
        parent: _searchBarAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 初始化Tab栏动画控制器 - 不是隐藏而是位移
    _tabBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _tabBarSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -1.3), // 增加偏移量，确保上移到适当位置
    ).animate(
      CurvedAnimation(
        parent: _tabBarAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 默认显示顶部
    _searchBarAnimationController.reverse();
    _tabBarAnimationController.reverse();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listScrollController.dispose();
    _searchBarAnimationController.dispose();
    _tabBarAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SquareBloc>().add(const LoadMoreSquarePosts());
    }

    // 更新当前时间为最近一次滚动时间
    _lastScrollTime = DateTime.now();

    // 如果之前没有在滚动，现在开始滚动
    if (!_isScrolling) {
      _isScrolling = true;
      // 启动检测滚动停止的计时器
      _startScrollDetectionTimer();
    }

    // 控制顶部区域显示/隐藏
    if (_listScrollController.hasClients) {
      final currentOffset = _listScrollController.offset;
      final scrollingDown = currentOffset > _lastScrollOffset; // 向下滚动（屏幕上移）

      // 向下滚动超过一定距离时隐藏搜索框，Tab栏上移
      if (scrollingDown && currentOffset > 50) {
        if (_isSearchBarVisible) {
          _searchBarAnimationController.forward();
          _tabBarAnimationController.forward();
          _fabController.hideFab();
          setState(() {
            _isSearchBarVisible = false;
          });
        }
      }
      // 向上滚动时显示搜索框和Tab栏
      else if (!scrollingDown && currentOffset < _lastScrollOffset - 5) {
        if (!_isSearchBarVisible) {
          _searchBarAnimationController.reverse();
          _tabBarAnimationController.reverse();
          _fabController.showFab();
          setState(() {
            _isSearchBarVisible = true;
          });
        }
      }

      _lastScrollOffset = currentOffset;
    }
  }

  // 启动滚动检测计时器
  void _startScrollDetectionTimer() {
    Future.delayed(const Duration(milliseconds: 300), () {
      // 如果自上次滚动已经过去了300ms，认为滚动已停止
      if (_lastScrollTime != null &&
          DateTime.now().difference(_lastScrollTime!).inMilliseconds >= 300) {
        _isScrolling = false;

        // 显示FAB
        _fabController.showFab();

        // 当滚动停止且不在顶部时，可以考虑是否要显示搜索框
        if (!_isSearchBarVisible &&
            _listScrollController.hasClients &&
            _listScrollController.offset <= 0) {
          _searchBarAnimationController.reverse();
          _tabBarAnimationController.reverse();
          setState(() {
            _isSearchBarVisible = true;
          });
        }
      } else {
        // 继续检测滚动
        _startScrollDetectionTimer();
      }
    });
  }

  bool get _isBottom {
    if (!_listScrollController.hasClients) return false;
    final maxScroll = _listScrollController.position.maxScrollExtent;
    final currentScroll = _listScrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      // 添加整个页面的手势检测，点击空白处时取消焦点
      onTap: () {
        // 主动取消焦点，避免输入框保持焦点状态
        FocusScope.of(context).unfocus();
      },
      // 确保GestureDetector可以接收全屏幕的点击事件
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        floatingActionButton: ParabolicFab(
          iconData: Icons.add,
          routePath: '/home/square/post/create',
          backgroundColor: theme.colorScheme.primary,
          iconColor: theme.colorScheme.onPrimary,
          controller: _fabController,
          onPressed: () {
            FocusScope.of(context).unfocus();
          },
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // 内容区域
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                top:
                    _isSearchBarVisible
                        ? (_searchBarHeight + _tabBarHeight).h
                        : _tabBarHeight.h, // 当搜索框隐藏时，内容区域上移
                left: 0,
                right: 0,
                bottom: 0,
                child: BlocBuilder<SquareBloc, SquareState>(
                  builder: (context, state) {
                    final theme = Theme.of(context);

                    switch (state.status) {
                      case SquareStatus.initial:
                      case SquareStatus.loading:
                        return _buildLoadingList();
                      case SquareStatus.failure:
                        return ErrorView(
                          message: state.errorMessage,
                          onRetry: () {
                            context.read<SquareBloc>().add(
                              const LoadSquarePosts(),
                            );
                          },
                        );
                      case SquareStatus.success:
                      case SquareStatus.loadMore:
                        if (state.posts.isEmpty) {
                          return _buildEmptyView();
                        }

                        return TabBarView(
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(), // 弹性滑动物理效果
                          children: List.generate(_topics.length, (index) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                context.read<SquareBloc>().add(
                                  const RefreshSquarePosts(),
                                );
                              },
                              color: theme.colorScheme.primary,
                              child: PerformanceUtils.getOptimizedListView(
                                itemCount:
                                    state.posts.length +
                                    (state.status == SquareStatus.loadMore
                                        ? 1
                                        : 0),
                                itemBuilder: (context, index) {
                                  if (index >= state.posts.length) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.h,
                                      ),
                                      alignment: Alignment.center,
                                      child: LoadingIndicator(),
                                    );
                                  }
                                  return PerformanceWidgets.optimizedListItem(
                                    isComplexUI: true,
                                    child: _buildPostItem(
                                      context,
                                      state.posts[index],
                                    ),
                                  );
                                },
                                controller: _listScrollController,
                                physics:
                                    PerformanceUtils.getOptimizedScrollPhysics(),
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: true,
                              ),
                            );
                          }),
                        );
                    }
                  },
                ),
              ),

              // 搜索框区域 - 可完全隐藏
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _searchBarSlideAnimation,
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    height: _searchBarHeight.h,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                      child: Row(
                        children: [
                          SizedBox(width: 8.w), // 缩小边距与卡片对齐
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                context.push('/home/square/search');
                              },
                              child: Container(
                                height: 38.h,
                                decoration: BoxDecoration(
                                  color:
                                      theme.brightness == Brightness.dark
                                          ? theme.colorScheme.surfaceVariant
                                          : theme.colorScheme.primary
                                              .withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(19.r),
                                  boxShadow:
                                      theme.brightness == Brightness.light
                                          ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 3,
                                              offset: Offset(0, 1),
                                            ),
                                          ]
                                          : [],
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 12.w),
                                    Icon(
                                      Icons.search,
                                      color: theme.hintColor,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        '搜索感兴趣的内容',
                                        style: TextStyle(
                                          color: theme.hintColor,
                                          fontSize: 14.sp,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Tab栏区域 - 当搜索框隐藏时上移
              Positioned(
                top: _searchBarHeight.h,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _tabBarSlideAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: theme.scaffoldBackgroundColor,
                    height: _tabBarHeight.h,
                    padding: EdgeInsets.only(
                      top:
                          _isSearchBarVisible
                              ? 0
                              : MediaQuery.of(context).padding.top > 0
                              ? 0 // 刘海屏已经有安全区域了
                              : 6.h, // 非刘海屏添加一些顶部边距
                    ),
                    child: _buildTopicSelector(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicSelector() {
    return BlocBuilder<SquareBloc, SquareState>(
      builder: (context, state) {
        final theme = Theme.of(context);

        return Container(
          height: 44.h,
          color: theme.scaffoldBackgroundColor,
          padding: EdgeInsets.only(bottom: 6.h),
          child: TabBar(
            controller: _tabController,
            isScrollable: false, // 固定宽度，平均分布
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
            ),
            tabs: _topics.map((topic) => Tab(text: topic)).toList(),
            onTap: (index) {
              // 当Tab被点击时，切换对应的主题
              final currentTopic = _topics[index];
              final topic = currentTopic == '全部' ? '' : currentTopic;
              if (state.currentTopic != topic) {
                context.read<SquareBloc>().add(SwitchTopic(topic: topic));
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    final theme = Theme.of(context);

    // 获取底部安全区域高度
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // 主题相关颜色
    final baseColor =
        theme.brightness == Brightness.dark
            ? Colors.grey[700]!
            : Colors.grey[300]!;
    final highlightColor =
        theme.brightness == Brightness.dark
            ? Colors.grey[600]!
            : Colors.grey[100]!;

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80.h + bottomPadding, top: 8.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildSquarePostSkeleton(
          context: context,
          hasImage: index % 2 == 0,
          baseColor: baseColor,
          highlightColor: highlightColor,
        );
      },
    );
  }

  // 自定义广场页面帖子骨架屏
  Widget _buildSquarePostSkeleton({
    required BuildContext context,
    required bool hasImage,
    required Color baseColor,
    required Color highlightColor,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 6.h, left: 8.w, right: 8.w),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      color:
          theme.brightness == Brightness.dark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息骨架
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color:
                          theme.brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        child: Container(
                          width: 120.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color:
                                theme.brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Shimmer.fromColors(
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        child: Container(
                          width: 80.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color:
                                theme.brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      color:
                          theme.brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 文本内容骨架
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: double.infinity,
                height: 16.h,
                decoration: BoxDecoration(
                  color:
                      theme.brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: double.infinity,
                height: 16.h,
                decoration: BoxDecoration(
                  color:
                      theme.brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),

            // 图片骨架
            if (hasImage) ...[
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  color:
                      theme.brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ],

            SizedBox(height: 16.h),

            // 分隔线
            Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                width: double.infinity,
                height: 1.h,
                color: theme.dividerColor.withOpacity(0.1),
              ),
            ),

            SizedBox(height: 12.h),

            // 操作按钮骨架
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < 3; i++)
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Row(
                      children: [
                        Container(
                          width: 18.r,
                          height: 18.r,
                          decoration: BoxDecoration(
                            color:
                                theme.brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Container(
                          width: 40.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color:
                                theme.brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64.sp,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无内容',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '关注更多话题或用户获取更多内容',
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, Post post) {
    final theme = Theme.of(context);

    // 美化后的卡片设计
    return Card(
      margin: EdgeInsets.only(bottom: 6.h, left: 8.w, right: 8.w),
      elevation: 0, // 无阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias, // 确保子组件不超出圆角边界
      color:
          theme.brightness == Brightness.dark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.cardColor,
      child: InkWell(
        onTap: () {
          context.push('/home/square/detail/${post.id}');
        },
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息行
              Row(
                children: [
                  AppAvatar(
                    imageUrl: post.userAvatar,
                    radius: 20.r,
                    membershipLevel: _getMembershipLevelFromUserId(post.userId),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _formatPostTime(post.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h), // 增加间距
              // 帖子内容
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),

              // 图片展示（如果有图片）
              if (post.images.isNotEmpty) ...[
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: PerformanceWidgets.optimizedImage(
                    imageSize: Size(400, 400),
                    child: StrategicImageCache().getOptimizedCachedImage(
                      imageUrl: _transformToLoremPicsum(
                        post.images[0],
                        width: 400,
                        height: 300,
                      ),
                      priority: ImagePriority.medium,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200.h,
                      memCacheWidth: 800,
                      memCacheHeight: 600,
                      placeholder:
                          (context, url) => Container(
                            width: double.infinity,
                            height: 200.h,
                            decoration: BoxDecoration(
                              color:
                                  theme.brightness == Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                      filterQuality: PerformanceUtils.getOptimalFilterQuality(),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 16.h),

              // 分隔线
              Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerColor.withOpacity(0.1),
              ),
              SizedBox(height: 12.h),

              // 操作区域
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.favorite_border,
                    label: post.likeCount.toString(),
                    onTap: () {
                      // TODO: 点赞操作
                      print("Like post ${post.id}");
                    },
                    isLikeButton: true,
                    isLiked: post.isLiked,
                    post: post,
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.chat_bubble_outline,
                    label: post.commentCount.toString(),
                    onTap: () {
                      context.push(
                        '/home/square/detail/${post.id}?openComment=true',
                      );
                    },
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.share_outlined,
                    label: '分享',
                    onTap: () {
                      // TODO: 分享操作
                      print("Share post ${post.id}");
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 改进后的交互按钮
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLikeButton = false,
    bool? isLiked,
    Post? post,
  }) {
    final theme = Theme.of(context);

    // 如果是点赞按钮，使用LikeButton组件
    if (isLikeButton && post != null) {
      return LikeButton(
        size: 18.sp,
        isLiked: isLiked ?? false,
        likeCount: post.likeCount,
        countBuilder: (int? count, bool isLiked, String text) {
          return Text(
            count.toString(),
            style: TextStyle(
              fontSize: 13.sp,
              color: isLiked ? Colors.red : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          );
        },
        likeBuilder: (bool isLiked) {
          return Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
            size: 18.sp,
          );
        },
        onTap: (isLiked) async {
          // 触发点赞事件
          context.read<SquareBloc>().add(
            ToggleLikePost(postId: post.id, isCurrentlyLiked: isLiked),
          );
          // 返回操作的反向状态，UI将立即更新，后续由bloc处理实际状态
          return !isLiked;
        },
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        mainAxisAlignment: MainAxisAlignment.center,
      );
    }

    // 其他按钮保持原样
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 格式化帖子时间的方法
  String _formatPostTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 3) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  // 获取会员等级的方法
  MembershipLevel? _getMembershipLevelFromUserId(String userId) {
    if (userId.contains('vip1')) {
      return MembershipLevel.bronze;
    } else if (userId.contains('vip2')) {
      return MembershipLevel.silver;
    } else if (userId.contains('vip3')) {
      return MembershipLevel.gold;
    }
    return null;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
