import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:text_sphere_app/utils/app_logger.dart';
import 'package:text_sphere_app/utils/network_monitor.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 图像优先级枚举
enum ImagePriority {
  /// 低优先级：短时间缓存
  low,

  /// 中等优先级：默认缓存时间
  medium,

  /// 高优先级：长时间缓存
  high,

  /// 永久：尽可能长时间缓存
  permanent,
}

/// 图像加载来源枚举
enum ImageSource {
  /// 网络图像
  network,

  /// 资源图像
  asset,

  /// 文件图像
  file,

  /// 内存图像
  memory,
}

/// 网络类型枚举
enum NetworkType { wifi, mobile, ethernet, none }

/// 网络质量枚举
enum NetworkQuality { excellent, good, fair, poor }

/// 战略性图片缓存管理器
/// 根据图片的重要性和使用频率进行优化缓存
class StrategicImageCache {
  // 单例模式
  static final StrategicImageCache _instance = StrategicImageCache._internal();
  factory StrategicImageCache() => _instance;
  StrategicImageCache._internal();

  // 全局导航键，用于获取当前上下文
  static GlobalKey<NavigatorState>? _navigatorKey;

  // 缓存管理器
  final Map<ImagePriority, BaseCacheManager> _cacheManagers = {};

  // 图片URL优先级映射
  final Map<String, ImagePriority> _urlPriorityMap = {};

  // 高优先级图片缓存
  final Set<String> _highPriorityImages = {};

  // 低优先级图片缓存
  final Set<String> _lowPriorityImages = {};

  // 预加载请求队列
  final List<_PreloadRequest> _preloadQueue = [];

  // 当前正在处理的预加载请求数量
  int _activePreloadRequests = 0;

  // 最大并发预加载请求数
  final int _maxConcurrentRequests = 3;

  // 是否正在处理队列
  bool _isProcessingQueue = false;

  // 网络类型到图片质量映射
  final Map<NetworkType, int> _networkQualityMap = {
    NetworkType.wifi: 100,
    NetworkType.ethernet: 100,
    NetworkType.mobile: 75,
    NetworkType.none: 50,
  };

  // 网络质量到宽度调整因子映射
  final Map<NetworkQuality, double> _qualityWidthFactorMap = {
    NetworkQuality.excellent: 1.0,
    NetworkQuality.good: 0.85,
    NetworkQuality.fair: 0.7,
    NetworkQuality.poor: 0.5,
  };

  /// 设置导航键
  static void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  // 初始化缓存管理器
  void init() {
    // 高优先级缓存：较大容量，较长存留时间
    _cacheManagers[ImagePriority.high] = CacheManager(
      Config(
        'highPriorityCache',
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 200,
        repo: JsonCacheInfoRepository(databaseName: 'highPriorityCache'),
      ),
    );

    // 中等优先级缓存
    _cacheManagers[ImagePriority.medium] = CacheManager(
      Config(
        'mediumPriorityCache',
        stalePeriod: const Duration(days: 3),
        maxNrOfCacheObjects: 100,
        repo: JsonCacheInfoRepository(databaseName: 'mediumPriorityCache'),
      ),
    );

    // 低优先级缓存：较小容量，较短存留时间
    _cacheManagers[ImagePriority.low] = CacheManager(
      Config(
        'lowPriorityCache',
        stalePeriod: const Duration(days: 1),
        maxNrOfCacheObjects: 50,
        repo: JsonCacheInfoRepository(databaseName: 'lowPriorityCache'),
      ),
    );
  }

  // 根据URL获取缓存管理器
  BaseCacheManager getCacheManagerForUrl(String url) {
    final priority = _urlPriorityMap[url] ?? ImagePriority.medium;
    return _cacheManagers[priority] ?? _cacheManagers[ImagePriority.medium]!;
  }

  // 设置图片URL的优先级
  void setImagePriority(String url, ImagePriority priority) {
    _urlPriorityMap[url] = priority;
  }

  // 批量设置图片URL的优先级
  void setImagesPriority(List<String> urls, ImagePriority priority) {
    for (final url in urls) {
      _urlPriorityMap[url] = priority;
    }
  }

  /// 预热关键图片
  Future<void> prewarmCriticalImages(List<String> imageUrls) async {
    if (_navigatorKey?.currentContext == null) {
      logger.w('无法预热图片缓存：context不可用');
      return;
    }

    final context = _navigatorKey!.currentContext!;
    for (final url in imageUrls) {
      if (url.startsWith('http')) {
        await precacheImage(
          CachedNetworkImageProvider(url),
          context,
          onError: (e, stackTrace) {
            logger.w('预热图片失败: $url - 错误: $e');
          },
        );
        _highPriorityImages.add(url);
      } else {
        await precacheImage(
          AssetImage(url),
          context,
          onError: (e, stackTrace) {
            logger.w('预热本地图片失败: $url - 错误: $e');
          },
        );
      }
    }
  }

  /// 预加载图片
  void preloadImage(String imageUrl, {bool highPriority = false}) {
    final request = _PreloadRequest(
      url: imageUrl,
      priority: highPriority ? 1 : 0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // 将请求添加到队列
    _preloadQueue.add(request);

    // 按优先级排序队列
    _preloadQueue.sort((a, b) {
      // 首先按优先级排序
      final priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;

      // 然后按时间戳排序（新的先）
      return b.timestamp.compareTo(a.timestamp);
    });

    // 启动队列处理
    _processPreloadQueue();
  }

  /// 处理预加载队列
  Future<void> _processPreloadQueue() async {
    // 避免多个队列处理同时运行
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    try {
      while (_preloadQueue.isNotEmpty &&
          _activePreloadRequests < _maxConcurrentRequests) {
        final request = _preloadQueue.removeAt(0);
        _activePreloadRequests++;

        _preloadSingleImage(request.url, request.priority > 0)
            .then((_) {
              _activePreloadRequests--;
              // 处理完成后继续处理队列
              _processPreloadQueue();
            })
            .catchError((e) {
              _activePreloadRequests--;
              logger.w('预加载图片失败: ${request.url} - 错误: $e');
              _processPreloadQueue();
            });
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  /// 预加载单个图片
  Future<void> _preloadSingleImage(String url, bool highPriority) async {
    if (_navigatorKey?.currentContext == null) return;
    final context = _navigatorKey!.currentContext!;

    try {
      if (url.startsWith('http')) {
        await precacheImage(CachedNetworkImageProvider(url), context);
      } else {
        await precacheImage(AssetImage(url), context);
      }

      // 添加到相应优先级的缓存集
      if (highPriority) {
        _highPriorityImages.add(url);
      } else {
        _lowPriorityImages.add(url);
      }
    } catch (e) {
      logger.w('预加载图片失败: $url - 错误: $e');
    }
  }

  /// 获取图片尺寸调整因子
  double getImageSizeAdjustmentFactor() {
    // 由于没有直接引用NetworkMonitor，这里使用默认值
    final networkType = NetworkType.wifi;
    final networkQuality = NetworkQuality.good;

    // 根据网络类型和质量调整图片尺寸
    final qualityFactor = _qualityWidthFactorMap[networkQuality] ?? 1.0;

    // WiFi和以太网连接时，使用高质量图片
    if (networkType == NetworkType.wifi ||
        networkType == NetworkType.ethernet) {
      return qualityFactor;
    }

    // 移动网络时，进一步降低图片尺寸
    return qualityFactor * 0.8;
  }

  /// 获取图片质量
  int getImageQuality() {
    // 由于没有直接引用NetworkMonitor，这里使用默认值
    final networkType = NetworkType.wifi;

    return _networkQualityMap[networkType] ?? 100;
  }

  /// 创建优化的网络图片
  Widget optimizedNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    Widget? placeholder,
    bool highPriority = false,
  }) {
    // 根据网络条件调整尺寸
    final sizeFactor = getImageSizeAdjustmentFactor();
    final adjustedWidth = width != null ? width * sizeFactor : width;
    final adjustedHeight = height != null ? height * sizeFactor : height;

    // 获取当前网络条件下的图片质量
    final quality = getImageQuality();

    // 根据优先级决定是否标记为高优先级
    if (highPriority) {
      _highPriorityImages.add(imageUrl);
    }

    // 构建调整了质量参数的URL
    final adjustedUrl = _adjustImageUrl(imageUrl, quality);

    return CachedNetworkImage(
      imageUrl: adjustedUrl,
      width: adjustedWidth,
      height: adjustedHeight,
      fit: fit,
      placeholder:
          (context, url) =>
              placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget:
          errorWidget ?? (context, url, error) => const Icon(Icons.error),
      memCacheWidth: adjustedWidth?.toInt(),
      memCacheHeight: adjustedHeight?.toInt(),
    );
  }

  /// 调整图片URL，添加质量参数
  String _adjustImageUrl(String url, int quality) {
    // 对于支持质量参数的图片服务，添加质量参数
    if (url.contains('?')) {
      return '$url&quality=$quality';
    } else {
      return '$url?quality=$quality';
    }
  }

  /// 清理低优先级缓存
  void clearLowPriorityCache() {
    _cacheManagers[ImagePriority.low]?.emptyCache();
  }

  /// 清理所有缓存
  void clearAllCache() {
    _highPriorityImages.clear();
    _lowPriorityImages.clear();
    CachedNetworkImage.evictFromCache('');
    if (kDebugMode) {
      print('已清理所有图片缓存');
    }
  }

  /// 预加载当前页面可能需要的图片
  void preloadImagesForCurrentPage(List<String> imageUrls) {
    for (final url in imageUrls) {
      preloadImage(url, highPriority: true);
    }
  }

  /// 预加载下一页可能需要的图片
  void preloadImagesForNextPage(List<String> imageUrls) {
    for (final url in imageUrls) {
      preloadImage(url, highPriority: false);
    }
  }

  /// 获取当前缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return {
      'highPriorityCount': _highPriorityImages.length,
      'lowPriorityCount': _lowPriorityImages.length,
      'pendingPreloads': _preloadQueue.length,
      'activePreloads': _activePreloadRequests,
    };
  }

  // 预缓存高优先级图片
  Future<void> precacheHighPriorityImages(List<String> urls) async {
    if (_navigatorKey?.currentContext == null) {
      debugPrint('Warning: Cannot precache images without context');
      return;
    }

    final context = _navigatorKey!.currentContext!;

    // 设置为高优先级
    setImagesPriority(urls, ImagePriority.high);

    // 预缓存图片
    for (final url in urls) {
      await precacheImage(
        CachedNetworkImageProvider(
          url,
          cacheManager: _cacheManagers[ImagePriority.high],
        ),
        context,
      );
    }
  }

  // 获取优化的CachedNetworkImage
  Widget getOptimizedCachedImage({
    required String imageUrl,
    required ImagePriority priority,
    BoxFit? fit,
    double? width,
    double? height,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
    int? memCacheWidth,
    int? memCacheHeight,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    // 设置图片优先级
    setImagePriority(imageUrl, priority);

    // 获取对应的缓存管理器
    final cacheManager =
        _cacheManagers[priority] ?? _cacheManagers[ImagePriority.medium]!;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: cacheManager,
      fit: fit ?? BoxFit.cover,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      filterQuality: filterQuality,
      placeholder:
          placeholder ??
          (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      errorWidget:
          errorWidget ??
          (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          ),
    );
  }
}

/// 预加载请求类
class _PreloadRequest {
  final String url;
  final int priority; // 数字越大优先级越高
  final int timestamp;

  _PreloadRequest({
    required this.url,
    required this.priority,
    required this.timestamp,
  });
}
