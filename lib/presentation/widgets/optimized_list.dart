import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/presentation/widgets/app_loading_indicator.dart';
import 'package:text_sphere_app/utils/responsive_utils.dart';

/// 优化列表组件
///
/// 针对长列表场景进行了性能优化:
/// 1. 使用RepaintBoundary隔离重绘区域
/// 2. 按需构建列表项
/// 3. 支持懒加载和分页
/// 4. 支持预加载下一页内容
class OptimizedList<T> extends StatefulWidget {
  /// 列表数据
  final List<T> items;

  /// 列表项构建器
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 列表为空时显示的组件
  final Widget? emptyWidget;

  /// 加载中显示的组件
  final Widget? loadingWidget;

  /// 错误时显示的组件
  final Widget? errorWidget;

  /// 是否正在加载
  final bool isLoading;

  /// 是否加载出错
  final bool hasError;

  /// 错误信息
  final String? errorMessage;

  /// 刷新回调
  final Future<void> Function()? onRefresh;

  /// 加载更多回调
  final Future<void> Function()? onLoadMore;

  /// 是否已加载全部数据
  final bool hasReachedMax;

  /// 列表滚动控制器
  final ScrollController? scrollController;

  /// 列表填充方式
  final Axis scrollDirection;

  /// 列表内边距
  final EdgeInsetsGeometry? padding;

  /// 是否启用物理边界效果
  final bool enablePhysics;

  /// 加载阈值 - 当滚动到距离底部多少比例时触发加载更多
  final double loadMoreThreshold;

  /// 预渲染窗口大小
  final double? cacheExtent;

  /// 是否保持离屏状态
  final bool addAutomaticKeepAlives;

  /// 是否为各项添加RepaintBoundary
  final bool addRepaintBoundaries;

  /// 分隔组件构建器
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// 加载更多指示器
  final Widget? loadMoreIndicator;

  /// 是否使用物理滚动
  final ScrollPhysics? physics;

  /// 加载指示器位置偏移
  final double loadingIndicatorOffset;

  const OptimizedList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRefresh,
    this.onLoadMore,
    this.hasReachedMax = false,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.enablePhysics = true,
    this.loadMoreThreshold = 0.8,
    this.cacheExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.separatorBuilder,
    this.loadMoreIndicator,
    this.physics,
    this.loadingIndicatorOffset = 0.0,
  }) : super(key: key);

  @override
  State<OptimizedList<T>> createState() => _OptimizedListState<T>();
}

class _OptimizedListState<T> extends State<OptimizedList<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // 快速滚动时延迟处理，避免频繁触发
    final scrollPosition = _scrollController.position;
    final isScrollingFast =
        scrollPosition.activity?.velocity != null &&
        scrollPosition.activity!.velocity!.abs() > 20;

    if (isScrollingFast) {
      // 快速滚动中，延迟检查
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _checkLoadMore();
      });
    } else {
      // 正常滚动，立即检查
      _checkLoadMore();
    }
  }

  void _checkLoadMore() {
    if (!mounted) return;

    if (!_isLoadingMore &&
        !widget.isLoading &&
        !widget.hasError &&
        !widget.hasReachedMax &&
        widget.onLoadMore != null &&
        _isScrolledToLoadMoreThreshold()) {
      _loadMore();
    }
  }

  bool _isScrolledToLoadMoreThreshold() {
    if (!_scrollController.hasClients) return false;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // 当滚动位置达到阈值时触发加载更多
    return currentScroll >= (maxScroll * widget.loadMoreThreshold);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Widget _buildList() {
    // 列表为空时显示空状态
    if (widget.items.isEmpty) {
      if (widget.isLoading) {
        return _buildLoadingIndicator();
      }

      if (widget.hasError) {
        return _buildErrorIndicator();
      }

      return _buildEmptyIndicator();
    }

    // 构建列表内容
    Widget listContent;

    // 使用带分隔符的列表
    if (widget.separatorBuilder != null) {
      listContent = _buildSeparatedListView();
    }
    // 使用普通列表
    else {
      listContent = _buildListView();
    }

    // 添加下拉刷新功能
    if (widget.onRefresh != null) {
      listContent = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listContent,
      );
    }

    return listContent;
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      physics:
          widget.physics ??
          (widget.enablePhysics ? null : const NeverScrollableScrollPhysics()),
      cacheExtent: widget.cacheExtent,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      itemCount: widget.items.length + (_isAtBottom() ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return _buildLoadMoreIndicator();
        }

        final item = widget.items[index];
        return widget.itemBuilder(context, item, index);
      },
    );
  }

  Widget _buildSeparatedListView() {
    return ListView.separated(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      physics:
          widget.physics ??
          (widget.enablePhysics ? null : const NeverScrollableScrollPhysics()),
      cacheExtent: widget.cacheExtent,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      itemCount: widget.items.length + (_isAtBottom() ? 1 : 0),
      separatorBuilder: widget.separatorBuilder!,
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return _buildLoadMoreIndicator();
        }

        final item = widget.items[index];
        return widget.itemBuilder(context, item, index);
      },
    );
  }

  bool _isAtBottom() {
    return !widget.hasReachedMax &&
        widget.onLoadMore != null &&
        widget.items.isNotEmpty;
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: widget.loadMoreIndicator ?? AppLoadingIndicator.small(),
    );
  }

  // 分页加载指示器
  Widget _buildPaginationLoading() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: widget.loadMoreIndicator ?? AppLoadingIndicator.small(),
    );
  }

  Widget _buildLoadingIndicator() {
    final isWideScreen = ResponsiveUtils.isWideScreen(context);

    return Container(
      padding: EdgeInsets.only(
        top: widget.loadingIndicatorOffset + (isWideScreen ? 32 : 32.h),
      ),
      alignment: Alignment.center,
      child:
          widget.loadingWidget ??
          const AppLoadingIndicator(
            type: LoadingIndicatorType.circular,
            message: '加载中...',
          ),
    );
  }

  Widget _buildErrorIndicator() {
    final theme = Theme.of(context);
    final isWideScreen = ResponsiveUtils.isWideScreen(context);

    return widget.errorWidget ??
        Container(
          padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 32 : 32.w),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: isWideScreen ? 48 : 48.r,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: isWideScreen ? 16 : 16.h),
              Text(
                widget.errorMessage ?? '加载失败，请重试',
                style: TextStyle(
                  fontSize: isWideScreen ? 16 : 16.sp,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.onRefresh != null) ...[
                SizedBox(height: isWideScreen ? 24 : 24.h),
                ElevatedButton(
                  onPressed: widget.onRefresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen ? 24 : 24.w,
                      vertical: isWideScreen ? 12 : 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        isWideScreen ? 8 : 8.r,
                      ),
                    ),
                  ),
                  child: Text('重新加载'),
                ),
              ],
            ],
          ),
        );
  }

  Widget _buildEmptyIndicator() {
    final theme = Theme.of(context);
    final isWideScreen = ResponsiveUtils.isWideScreen(context);

    return widget.emptyWidget ??
        Container(
          padding: EdgeInsets.symmetric(horizontal: isWideScreen ? 32 : 32.w),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: isWideScreen ? 48 : 48.r,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              SizedBox(height: isWideScreen ? 16 : 16.h),
              Text(
                '暂无内容',
                style: TextStyle(
                  fontSize: isWideScreen ? 16 : 16.sp,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return _buildList();
  }
}
