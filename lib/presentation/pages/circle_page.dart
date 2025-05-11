// lib/presentation/pages/circle_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/components/app_avatar.dart';
import 'package:text_sphere_app/core/di/injection_container.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/domain/entities/circle.dart';
import 'package:text_sphere_app/presentation/blocs/circle/circle_bloc.dart';
import 'package:text_sphere_app/presentation/blocs/circle/circle_event.dart';
import 'package:text_sphere_app/presentation/blocs/circle/circle_state.dart';
import 'package:text_sphere_app/presentation/widgets/error_view.dart';
import 'package:text_sphere_app/presentation/widgets/parabolic_fab.dart';
import 'package:shimmer/shimmer.dart';
import 'package:text_sphere_app/presentation/widgets/app_network_image.dart';
import 'dart:math' as math;

class CirclePage extends StatefulWidget {
  const CirclePage({Key? key}) : super(key: key);

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final CircleBloc _circleBloc = sl<CircleBloc>();
  bool _showClearIcon = false;

  // Tab控制器
  late TabController _tabController;
  final List<String> _tabTitles = ['我的圈子', '推荐', '科技', '生活', '文化'];
  final List<CircleTab> _tabTypes = [
    CircleTab.joined,
    CircleTab.recommended,
    CircleTab.category,
    CircleTab.category,
    CircleTab.category,
  ];
  final List<String> _tabCategories = ['', '', '科技', '生活', '文化'];

  // 添加ParabolicFab控制器
  final ParabolicFabController _fabController = ParabolicFabController();

  // 多个滚动控制器，每个Tab一个
  final List<ScrollController> _scrollControllers = [];
  late ScrollController _activeScrollController;
  double _lastScrollOffset = 0;
  DateTime? _lastScrollTime;
  bool _isScrolling = false;

  // 顶部区域动画控制器
  late AnimationController _searchBarAnimationController;
  late Animation<Offset> _searchBarSlideAnimation;
  late AnimationController _tabBarAnimationController;
  late Animation<Offset> _tabBarSlideAnimation;

  // 两个区域是否可见
  bool _isSearchBarVisible = true;

  // 顶部区域高度和顶部边距
  final double _searchBarHeight = 54.0; // 搜索框高度
  final double _tabBarHeight = 44.0; // Tab栏的高度
  final double _topMargin = 8.0;

  @override
  void initState() {
    super.initState();

    // 初始化Tab控制器
    _tabController = TabController(length: _tabTitles.length, vsync: this);

    // 初始化滚动控制器
    for (int i = 0; i < _tabTitles.length; i++) {
      _scrollControllers.add(ScrollController());
    }
    _activeScrollController = _scrollControllers[0];

    // Tab切换监听
    _tabController.addListener(() {
      // 切换活跃的滚动控制器
      _activeScrollController = _scrollControllers[_tabController.index];

      // 无论是点击还是滑动切换，都触发数据加载
      final index = _tabController.index;
      final tab = _tabTypes[index];
      final category = _tabCategories[index];

      // 检查是否需要加载新数据
      final currentState = _circleBloc.state;
      final shouldReload =
          tab == CircleTab.joined &&
              currentState.activeTab != CircleTab.joined ||
          tab == CircleTab.recommended &&
              currentState.activeTab != CircleTab.recommended ||
          tab == CircleTab.category &&
              (currentState.activeTab != CircleTab.category ||
                  currentState.category != category);

      if (shouldReload) {
        _onTabChanged(tab, category);
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

    // 加载初始数据
    _circleBloc.add(const LoadRecommendedCircles());

    // 添加文本控制器监听器，监听文本变化
    _searchController.addListener(_onSearchChanged);

    // 添加焦点监听器，监听焦点变化
    _searchFocusNode.addListener(_onFocusChanged);

    // 为每个滚动控制器添加监听
    for (var controller in _scrollControllers) {
      controller.addListener(() {
        if (controller == _activeScrollController) {
          _onScroll();
        }
      });
    }
  }

  @override
  void dispose() {
    // 移除监听器
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);

    _searchController.dispose();
    _searchFocusNode.dispose();

    // 释放所有滚动控制器
    for (var controller in _scrollControllers) {
      controller.dispose();
    }

    _searchBarAnimationController.dispose();
    _tabBarAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // 当搜索文本变化时更新状态
  void _onSearchChanged() {
    final hasText = _searchController.text.isNotEmpty;
    if (_showClearIcon != hasText) {
      setState(() {
        _showClearIcon = hasText;
      });
    }

    // 搜索逻辑
    if (hasText && _searchController.text.length > 1) {
      // 输入2个字符以上时开始搜索
      _circleBloc.add(SearchCircles(_searchController.text));
    } else if (!hasText) {
      // 输入为空时恢复推荐列表
      _circleBloc.add(const LoadRecommendedCircles());
    }
  }

  // 当焦点变化时更新状态
  void _onFocusChanged() {
    // 强制刷新组件状态，确保光标状态正确更新
    setState(() {});

    // 失去焦点时更新清除图标状态
    if (!_searchFocusNode.hasFocus) {
      final hasText = _searchController.text.isNotEmpty;
      setState(() {
        _showClearIcon = hasText;
      });

      // 确保搜索状态与文本内容一致
      if (hasText && _searchController.text.length > 1) {
        // 当有足够的文本时，确保搜索状态正确
        _circleBloc.add(SearchCircles(_searchController.text));
      } else if (!hasText) {
        // 当文本为空时，恢复推荐列表
        _circleBloc.add(const LoadRecommendedCircles());
      }
    }
  }

  // 清空搜索框并重置状态
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showClearIcon = false;
    });
    _circleBloc.add(const LoadRecommendedCircles());
  }

  // 处理滚动事件的方法
  void _onScroll() {
    // 更新当前时间为最近一次滚动时间
    _lastScrollTime = DateTime.now();

    // 如果之前没有在滚动，现在开始滚动
    if (!_isScrolling) {
      _isScrolling = true;
      // 启动检测滚动停止的计时器
      _startScrollDetectionTimer();
    }

    // 控制顶部区域和FAB的显示/隐藏
    if (_activeScrollController.hasClients) {
      final currentOffset = _activeScrollController.offset;
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

        // 当滚动停止且在顶部时，显示搜索框
        if (!_isSearchBarVisible &&
            _activeScrollController.hasClients &&
            _activeScrollController.offset <= 0) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _circleBloc,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        floatingActionButton: ParabolicFab(
          iconData: Icons.add,
          routePath: '/circle/create',
          backgroundColor: theme.colorScheme.primary,
          iconColor: theme.colorScheme.onPrimary,
          controller: _fabController,
          onPressed: () {
            FocusScope.of(context).unfocus();
          },
        ),
        body: GestureDetector(
          onTap: () {
            if (_searchFocusNode.hasFocus) {
              _searchFocusNode.unfocus();
            }
          },
          child: SafeArea(
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
                  child: BlocBuilder<CircleBloc, CircleState>(
                    builder: (context, state) {
                      if (state.status == CircleStatus.initial) {
                        return const SizedBox();
                      } else if (state.status == CircleStatus.loading) {
                        return _buildSkeletonLoading();
                      } else if (state.status == CircleStatus.failure) {
                        return ErrorView(
                          message: state.errorMessage,
                          onRetry: () {
                            _onTabChanged(state.activeTab, state.category);
                          },
                        );
                      } else {
                        return TabBarView(
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(), // 弹性滑动物理效果
                          children: List.generate(_tabTitles.length, (index) {
                            // 当前Tab类型和分类
                            final tabType = _tabTypes[index];
                            final category = _tabCategories[index];

                            // 检查当前Tab是否应该显示内容
                            final bool shouldShowContent =
                                (tabType == CircleTab.joined &&
                                    state.activeTab == CircleTab.joined) ||
                                (tabType == CircleTab.recommended &&
                                    state.activeTab == CircleTab.recommended) ||
                                (tabType == CircleTab.category &&
                                    state.activeTab == CircleTab.category &&
                                    state.category == category);

                            // 如果是当前激活的Tab内容，显示内容
                            if (shouldShowContent) {
                              return _buildCircleList(state.circles, index);
                            }

                            // 对于非激活Tab，显示加载中或占位控件
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
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
                      child: _buildSearchBar(),
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
                      child: _buildCategoryTabs(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
      child: Row(
        children: [
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              height: 38.h,
              decoration: BoxDecoration(
                color:
                    theme.brightness == Brightness.dark
                        ? theme.colorScheme.surfaceVariant
                        : theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(19.r),
                boxShadow:
                    theme.brightness == Brightness.light
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ]
                        : [],
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Icon(Icons.search, color: theme.hintColor, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      showCursor: _searchFocusNode.hasFocus,
                      decoration: InputDecoration(
                        hintText: '搜索圈子',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 0.h),
                        fillColor: Colors.transparent,
                        filled: true,
                        isDense: true,
                        suffixIcon:
                            _showClearIcon
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: theme.hintColor,
                                    size: 18.sp,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    _clearSearch();
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                                : null,
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _circleBloc.add(SearchCircles(value));
                          setState(() {
                            _showClearIcon = true;
                          });
                          FocusScope.of(context).unfocus();
                        }
                      },
                      textInputAction: TextInputAction.search,
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return BlocBuilder<CircleBloc, CircleState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final bool isSearching = _searchController.text.isNotEmpty;

        // 搜索状态下不显示分类标签，显示搜索状态
        if (isSearching) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.search, size: 16.sp, color: theme.hintColor),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '正在搜索: "${_searchController.text}"',
                    style: TextStyle(fontSize: 14.sp, color: theme.hintColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (state.status == CircleStatus.loading)
                  SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        // 根据当前激活的Tab设置初始索引
        int initialIndex = 1; // 默认推荐Tab
        if (state.activeTab == CircleTab.joined) {
          initialIndex = 0;
        } else if (state.activeTab == CircleTab.recommended) {
          initialIndex = 1;
        } else if (state.activeTab == CircleTab.category) {
          // 根据分类名称找到对应的索引
          for (int i = 2; i < _tabCategories.length; i++) {
            if (_tabCategories[i] == state.category) {
              initialIndex = i;
              break;
            }
          }
        }

        // 如果Tab控制器当前索引与期望索引不同，更新它
        if (_tabController.index != initialIndex) {
          _tabController.animateTo(initialIndex);
        }

        return Container(
          height: 44.h,
          padding: EdgeInsets.only(bottom: 6.h),
          child: TabBar(
            controller: _tabController,
            isScrollable: true, // 可以滚动查看更多Tab
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
            tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCircleList(List<Circle> circles, int index) {
    final theme = Theme.of(context);
    final searchQuery = _searchController.text.trim().toLowerCase();
    final bool isSearching = searchQuery.isNotEmpty;

    if (circles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.dashboard_outlined,
              size: 64.sp,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              isSearching ? '没有找到相关圈子' : '暂无圈子',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isSearching ? '换个关键词试试' : '创建或加入更多圈子获取内容',
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isSearching) ...[
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  _circleBloc.add(const LoadRecommendedCircles());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text('返回推荐圈子'),
              ),
            ],
          ],
        ),
      );
    }

    // 为了增加内容，我们重复显示圈子列表
    List<Circle> repeatedCircles = [];

    // 重复3次圈子数据，确保有足够内容展示滑动效果
    for (int i = 0; i < 3; i++) {
      repeatedCircles.addAll(
        circles.map((circle) {
          // 创建圈子副本并修改ID避免重复
          return Circle(
            id: '${circle.id}_copy_$i',
            name: circle.name,
            description: circle.description,
            avatarUrl: circle.avatarUrl,
            coverUrl: circle.coverUrl,
            category: circle.category,
            tags: circle.tags,
            membersCount: circle.membersCount,
            postsCount: circle.postsCount,
            isJoined: circle.isJoined,
            createdAt: circle.createdAt,
            creatorId: circle.creatorId,
            creatorName: circle.creatorName,
          );
        }).toList(),
      );
    }

    // 获取底部安全区域高度
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ListView.builder(
      controller: _scrollControllers[index],
      padding: EdgeInsets.only(
        bottom: 80.h + bottomPadding,
        top: 0, // 完全移除顶部边距
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: repeatedCircles.length,
      itemBuilder: (context, index) {
        final circle = repeatedCircles[index];
        return Material(
          color:
              theme.brightness == Brightness.dark
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.cardColor,
          child: Column(
            children: [
              _buildCircleItem(circle),
              Divider(
                height: 1,
                thickness: 1,
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleItem(Circle circle) {
    final theme = Theme.of(context);
    final searchQuery = _searchController.text.trim().toLowerCase();
    final bool isSearching = searchQuery.isNotEmpty;

    return InkWell(
      onTap: () {
        try {
          if (circle.id.isNotEmpty) {
            context.push('/circle/${circle.id}');
          }
        } catch (e) {
          print('导航到圈子详情页失败: $e');
        }
      },
      splashColor: theme.colorScheme.primary.withOpacity(0.1),
      highlightColor: theme.colorScheme.primary.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 圈子封面图
          Stack(
            children: [
              SizedBox(
                height: 120.h,
                width: double.infinity,
                child: AppNetworkImage(
                  imageUrl: circle.coverUrl,
                  fit: BoxFit.cover,
                  useAdvancedShimmer: true,
                  shimmerStyle: ShimmerStyle.rounded,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16.w,
                bottom: 12.h,
                right: 16.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AppAvatar(imageUrl: circle.avatarUrl, radius: 16.r),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isSearching &&
                                    circle.name.toLowerCase().contains(
                                      searchQuery,
                                    )
                                ? _buildHighlightedText(
                                  circle.name,
                                  searchQuery,
                                  baseStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  highlightStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow,
                                  ),
                                )
                                : Text(
                                  circle.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                            SizedBox(height: 2.h),
                            Text(
                              '${circle.membersCount}成员',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        circle.category,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    if (circle.tags.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          circle.tags.first,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 12.h),
                isSearching &&
                        circle.description.toLowerCase().contains(searchQuery)
                    ? _buildHighlightedText(
                      circle.description,
                      searchQuery,
                      baseStyle: TextStyle(
                        fontSize: 14.sp,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                      highlightStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                      ),
                      maxLines: 2,
                    )
                    : Text(
                      circle.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    final theme = Theme.of(context);
    final baseColor =
        theme.brightness == Brightness.dark
            ? Colors.grey[700]!
            : Colors.grey[300]!;
    final highlightColor =
        theme.brightness == Brightness.dark
            ? Colors.grey[600]!
            : Colors.grey[100]!;

    // 获取底部安全区域高度
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80.h + bottomPadding, top: 0),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Material(
          color: theme.cardColor,
          child: Column(
            children: [
              // 圈子封面骨架
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  height: 120.h,
                  width: double.infinity,
                  color:
                      theme.brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.white,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 圈子信息骨架
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
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onTabChanged(CircleTab tab, String category) {
    switch (tab) {
      case CircleTab.joined:
        _circleBloc.add(const LoadJoinedCircles());
        break;
      case CircleTab.recommended:
        _circleBloc.add(const LoadRecommendedCircles());
        break;
      case CircleTab.category:
        _circleBloc.add(LoadCategorizedCircles(category));
        break;
      case CircleTab.search:
        // 搜索由输入框触发
        break;
    }
  }

  // 高亮显示搜索词的工具方法
  Widget _buildHighlightedText(
    String text,
    String query, {
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
    int? maxLines,
  }) {
    if (query.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    // 不区分大小写的搜索
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    do {
      indexOfHighlight = lowerText.indexOf(lowerQuery, start);
      if (indexOfHighlight < 0) {
        // 添加剩余文本
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        }
        break;
      }

      // 添加前面的普通文本
      if (indexOfHighlight > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, indexOfHighlight),
            style: baseStyle,
          ),
        );
      }

      // 添加高亮文本（使用原始文本以保持大小写）
      spans.add(
        TextSpan(
          text: text.substring(
            indexOfHighlight,
            indexOfHighlight + query.length,
          ),
          style: highlightStyle,
        ),
      );

      // 更新下一次搜索的起始位置
      start = indexOfHighlight + query.length;
    } while (true);

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }
}

// SliverAppBarDelegate 类用于实现固定标题栏
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
