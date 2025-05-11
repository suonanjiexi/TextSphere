import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:text_sphere_app/utils/performance_utils.dart';

/// 优化后的列表视图，用于处理大量数据的高性能展示
class OptimizedListView<T> extends StatefulWidget {
  /// 列表数据项
  final List<T> items;

  /// 构建列表项的回调
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 分隔线构建器
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// 空列表显示的Widget
  final Widget? emptyWidget;

  /// 加载指示器
  final Widget? loadingWidget;

  /// 是否正在加载
  final bool isLoading;

  /// 是否支持下拉刷新
  final bool enablePullToRefresh;

  /// 刷新回调
  final Future<void> Function()? onRefresh;

  /// 列表末尾显示的Widget
  final Widget? endWidget;

  /// 是否启用自动分页
  final bool enablePagination;

  /// 加载更多的阈值
  final double loadMoreThreshold;

  /// 加载更多的回调
  final Future<void> Function()? onLoadMore;

  /// 是否有更多数据
  final bool hasMoreData;

  /// 是否启用滚动优化
  final bool enableScrollOptimization;

  /// 滚动控制器
  final ScrollController? scrollController;

  /// 边缘留白
  final EdgeInsetsGeometry? padding;

  /// 构造函数
  const OptimizedListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.isLoading = false,
    this.enablePullToRefresh = false,
    this.onRefresh,
    this.endWidget,
    this.enablePagination = false,
    this.loadMoreThreshold = 200.0,
    this.onLoadMore,
    this.hasMoreData = true,
    this.enableScrollOptimization = true,
    this.scrollController,
    this.padding,
  }) : super(key: key);

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>>
    with WidgetsBindingObserver {
  /// 列表滚动控制器
  late ScrollController _scrollController;

  /// 防止多次加载更多
  bool _isLoadingMore = false;

  /// 是否处于低帧率模式
  bool _isLowFrameRateMode = false;

  /// 记录渲染时间用的变量
  Stopwatch? _renderWatch;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();

    if (widget.enablePagination && widget.onLoadMore != null) {
      _scrollController.addListener(_scrollListener);
    }

    WidgetsBinding.instance.addObserver(this);

    // 测量初始渲染时间
    if (kDebugMode) {
      _renderWatch = Stopwatch()..start();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_renderWatch != null) {
          debugPrint(
            'OptimizedListView 初始渲染耗时: ${_renderWatch!.elapsedMilliseconds}ms',
          );
          _renderWatch?.stop();
        }
      });
    }
  }

  @override
  void dispose() {
    // 仅处理自创建的控制器
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 在应用进入后台时释放资源
    if (state == AppLifecycleState.paused) {
      _cleanupResources();
    }
  }

  /// 释放资源
  void _cleanupResources() {
    // 可以在这里进行资源清理
  }

  /// 滚动监听器
  void _scrollListener() {
    if (!widget.enablePagination || _isLoadingMore || !widget.hasMoreData) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.loadMoreThreshold) {
      _loadMore();
    }

    // 检测快速滚动，进入低帧率模式
    if (widget.enableScrollOptimization) {
      final velocity = _scrollController.position.activity?.velocity ?? 0;
      if (velocity.abs() > 1000 && !_isLowFrameRateMode) {
        _enterLowFrameRateMode();
      } else if (velocity.abs() < 500 && _isLowFrameRateMode) {
        _exitLowFrameRateMode();
      }
    }
  }

  /// 进入低帧率模式
  void _enterLowFrameRateMode() {
    setState(() {
      _isLowFrameRateMode = true;
    });
  }

  /// 退出低帧率模式
  void _exitLowFrameRateMode() {
    setState(() {
      _isLowFrameRateMode = false;
    });
  }

  /// 加载更多数据
  Future<void> _loadMore() async {
    if (_isLoadingMore || widget.onLoadMore == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 显示加载中
    if (widget.isLoading && widget.items.isEmpty) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    // 显示空列表
    if (!widget.isLoading && widget.items.isEmpty) {
      return widget.emptyWidget ?? const Center(child: Text('没有数据'));
    }

    // 构建列表
    Widget listView = _buildListView();

    // 包装下拉刷新
    if (widget.enablePullToRefresh && widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }

  /// 构建列表视图
  Widget _buildListView() {
    // 构建基础列表
    Widget listContent =
        widget.separatorBuilder != null
            ? ListView.separated(
              controller: _scrollController,
              physics: PerformanceUtils.getOptimizedScrollPhysics(),
              padding: widget.padding,
              itemCount:
                  widget.items.length + (widget.endWidget != null ? 1 : 0),
              itemBuilder: _buildItem,
              separatorBuilder: widget.separatorBuilder!,
            )
            : ListView.builder(
              controller: _scrollController,
              physics: PerformanceUtils.getOptimizedScrollPhysics(),
              padding: widget.padding,
              itemCount:
                  widget.items.length + (widget.endWidget != null ? 1 : 0),
              itemBuilder: _buildItem,
            );

    // 为优化性能，在快速滚动时降低图像质量
    if (_isLowFrameRateMode) {
      listContent = _wrapWithLowQualityMode(listContent);
    }

    return listContent;
  }

  /// 包装低质量模式
  Widget _wrapWithLowQualityMode(Widget child) {
    // 当快速滚动时使用低质量渲染
    return RepaintBoundary(
      child: OverflowBox(
        alignment: Alignment.center,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: child,
      ),
    );
  }

  /// 构建列表项
  Widget _buildItem(BuildContext context, int index) {
    // 处理末尾项
    if (widget.endWidget != null && index == widget.items.length) {
      if (_isLoadingMore) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: CircularProgressIndicator(),
          ),
        );
      } else if (widget.hasMoreData) {
        return widget.endWidget!;
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              '已经到底了',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
        );
      }
    }

    // 构建正常列表项，使用RepaintBoundary优化性能
    return RepaintBoundary(
      child: widget.itemBuilder(context, widget.items[index], index),
    );
  }
}
