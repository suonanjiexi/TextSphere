import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 性能优化工具类
///
/// 提供全局性能优化方法和配置
class PerformanceUtils {
  /// 私有构造函数防止实例化
  PerformanceUtils._();

  /// 是否已初始化
  static bool _initialized = false;

  /// 图片缓存大小（默认100MB）
  static int _imageCacheMaxBytes = 100 * 1024 * 1024;

  /// 图片缓存最大数量
  static int _imageCacheMaxImages = 100;

  /// 是否启用性能覆盖层
  static bool _enablePerformanceOverlay = false;

  /// 是否在调试模式下展示性能监控
  static bool _showPerformanceMonitor = false;

  /// 全局导航键
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// 设置导航键
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// 初始化性能优化配置
  static void init({
    int? imageCacheMaxBytes,
    int? imageCacheMaxImages,
    bool enablePerformanceOverlay = false,
    bool showPerformanceMonitor = false,
  }) {
    if (_initialized) return;

    // 设置图片缓存大小
    if (imageCacheMaxBytes != null) {
      _imageCacheMaxBytes = imageCacheMaxBytes;
    }

    // 设置图片缓存数量
    if (imageCacheMaxImages != null) {
      _imageCacheMaxImages = imageCacheMaxImages;
    }

    // 更新缓存配置
    PaintingBinding.instance.imageCache.maximumSize = _imageCacheMaxImages;
    PaintingBinding.instance.imageCache.maximumSizeBytes = _imageCacheMaxBytes;

    // 设置性能覆盖层
    _enablePerformanceOverlay = enablePerformanceOverlay;

    // 设置是否显示性能监控
    _showPerformanceMonitor = showPerformanceMonitor;

    // 调试模式下启用额外的性能监控
    if (kDebugMode && _showPerformanceMonitor) {
      debugPrintRebuildDirtyWidgets = true;
      debugPrintLayouts = true;
      debugPrint('Performance monitoring enabled');

      // 开启布局边界可视化（仅在调试模式下）
      // debugPaintLayerBordersEnabled = true;
      // debugPaintBaselinesEnabled = true;
      // debugPaintPointersEnabled = true;
    }

    // 标记为已初始化
    _initialized = true;
  }

  /// 优化UI性能
  static void optimizeUiPerformance() {
    if (!_initialized) {
      init();
    }

    // 确保使用硬件加速
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
    }

    // 设置渲染优化
    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = true;
  }

  /// 清除图片缓存
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// 根据设备性能调整图片质量
  static FilterQuality getOptimalFilterQuality() {
    // 在低端设备上使用低质量图片过滤以提高性能
    if (isLowEndDevice()) {
      return FilterQuality.low;
    }

    // 默认使用中等质量
    return FilterQuality.medium;
  }

  /// 检测是否是低端设备
  static bool isLowEndDevice() {
    // 这里可以添加更复杂的设备性能检测逻辑
    // 例如检查设备型号、内存大小等

    // 简单实现：检查平台
    if (kIsWeb) {
      // Web端通常性能较差
      return true;
    }

    return false;
  }

  /// 获取性能覆盖层配置
  static bool get enablePerformanceOverlay => _enablePerformanceOverlay;

  /// 获取当前图片缓存大小（字节）
  static int get imageCacheMaxBytes => _imageCacheMaxBytes;

  /// 获取当前图片缓存数量
  static int get imageCacheMaxImages => _imageCacheMaxImages;

  /// 检查性能指标
  static void printPerformanceMetrics(String tag) {
    if (!kDebugMode) return;

    final stats = PaintingBinding.instance.imageCache.currentSizeBytes;
    final count = PaintingBinding.instance.imageCache.currentSize;

    debugPrint(
      '[$tag] Image cache stats: $count images, ${(stats / 1024 / 1024).toStringAsFixed(2)}MB',
    );
  }

  /// 缓存预热
  static void preWarmCache(List<String> imageUrls) {
    // 需要context来预缓存图片
    if (_navigatorKey?.currentContext == null) {
      debugPrint('Warning: Cannot prewarm cache without a valid context');
      return;
    }

    final context = _navigatorKey!.currentContext!;
    for (final url in imageUrls) {
      precacheImage(NetworkImage(url), context);
    }
  }

  /// 优化滚动性能
  static ScrollPhysics getOptimizedScrollPhysics() {
    return const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  /// 优化ListView性能
  static ListView getOptimizedListView({
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    bool addAutomaticKeepAlives = true,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    ScrollController? controller,
    IndexedWidgetBuilder? separatorBuilder,
  }) {
    // 对低端设备关闭某些开销大的功能
    if (isLowEndDevice()) {
      addAutomaticKeepAlives = false;
      addRepaintBoundaries = false;
    }

    // 对于分隔列表视图
    if (separatorBuilder != null) {
      return ListView.separated(
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder,
        itemCount: itemCount,
        physics: physics ?? getOptimizedScrollPhysics(),
        padding: padding,
        controller: controller,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        cacheExtent: 500, // 预缓存更多项目以便滚动更流畅
      );
    }

    // 普通列表视图
    return ListView.builder(
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      physics: physics ?? getOptimizedScrollPhysics(),
      padding: padding,
      controller: controller,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: 500, // 预缓存更多项目以便滚动更流畅
    );
  }

  /// 获取最佳渲染模式
  static bool shouldUseRepaintBoundary(Size widgetSize) {
    // 只对较大或复杂的 Widget 使用 RepaintBoundary
    // 小型简单的 Widget 使用 RepaintBoundary 反而会降低性能
    final size = widgetSize.width * widgetSize.height;
    return size > 10000; // 比如 100x100 的 Widget
  }
}
