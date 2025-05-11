import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/scheduler.dart';

/// 网络图片加载组件，统一处理图片加载失败的情况
/// 性能优化版本
class AppNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Color? errorBackgroundColor;
  final Duration cacheMaxAge;
  final int maxRetries;
  final Duration retryDelay;
  final ImageCategory imageCategory;
  final ShimmerStyle shimmerStyle;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;
  final bool useAdvancedShimmer; // 是否使用高级骨架屏动画
  final String? fallbackAssetImage; // 本地备用图片路径
  final String? errorMessage; // 自定义错误消息
  final bool autoRetry;

  // PC/Web平台相关参数
  final bool useOriginalUrl; // 是否使用原始URL而不转换为Lorem Picsum
  final bool forceHttps; // 强制将http转换为https (适用于Web平台)

  // 性能优化参数
  final bool useMemoryCache; // 是否使用内存缓存
  final bool useDiskCache; // 是否使用磁盘缓存
  final int? memCacheHeight; // 内存缓存高度
  final int? memCacheWidth; // 内存缓存宽度
  final bool isListItem; // 是否为列表项，用于优化列表性能

  const AppNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorWidget,
    this.errorBackgroundColor,
    this.cacheMaxAge = const Duration(days: 7),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.imageCategory = ImageCategory.general,
    this.shimmerStyle = ShimmerStyle.rectangle,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.useAdvancedShimmer = true, // 默认启用高级骨架屏
    this.fallbackAssetImage, // 本地备用图片
    this.errorMessage, // 错误信息
    this.autoRetry = true,
    this.useOriginalUrl = false, // 默认不使用原始URL
    this.forceHttps = true, // 默认强制https
    // 性能优化参数
    this.useMemoryCache = true,
    this.useDiskCache = true,
    this.memCacheHeight,
    this.memCacheWidth,
    this.isListItem = false,
  }) : super(key: key);

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

/// 图片分类，用于在加载失败时选择合适的默认图片
enum ImageCategory { general, profile, nature, food, travel, product }

/// 骨架屏样式
enum ShimmerStyle {
  rectangle, // 矩形
  rounded, // 圆角矩形
  circle, // 圆形
  custom, // 自定义形状
}

class _AppNetworkImageState extends State<AppNetworkImage>
    with SingleTickerProviderStateMixin {
  int _retryCount = 0;
  bool _hasError = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 图片加载完成标志
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    // Removed calculations depending on widget properties
    // _cacheKey = _generateCacheKey(widget.imageUrl);
    // _currentUrl = _processImageUrl(widget.imageUrl);

    // 减少动画控制器的初始化开销
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300), // 减少动画时间以提高性能
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // 移除预加载逻辑
  }

  // 生成缓存键 (Now called from build)
  String _generateCacheKey(String url) {
    // 基于URL、宽高和缩放比例创建唯一缓存键
    final widthPart = widget.width != null ? '${widget.width}' : 'auto';
    final heightPart = widget.height != null ? '${widget.height}' : 'auto';
    final fitPart = widget.fit.toString().split('.').last;
    return '$url-$widthPart-$heightPart-$fitPart';
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      // Reset state, calculations will happen in next build
      _retryCount = 0;
      _hasError = false;
      _imageLoaded = false;
      if (_fadeController.isCompleted) {
        _fadeController.reset();
      }
    }
  }

  // 处理图片URL (Now called from build)
  String _processImageUrl(String originalUrl) {
    // 处理空URL情况
    if (originalUrl.isEmpty) {
      return _getDefaultImageUrl();
    }

    // 检查是否是Web平台
    if (kIsWeb) {
      // 如果配置为强制https并且URL是http开头，则转换为https
      if (widget.forceHttps && originalUrl.startsWith('http://')) {
        return 'https://' + originalUrl.substring(7);
      }

      // 如果配置为使用原始URL，则直接返回
      if (widget.useOriginalUrl) {
        return originalUrl;
      }
    } else {
      // 移动平台，如果配置为使用原始URL，则直接返回
      if (widget.useOriginalUrl) {
        return originalUrl;
      }
    }

    // 默认行为：转换为Lorem Picsum格式
    return _transformToLoremPicsum(originalUrl);
  }

  // 获取默认图片URL
  String _getDefaultImageUrl() {
    // 根据图片类别返回不同的默认图片
    switch (widget.imageCategory) {
      case ImageCategory.profile:
        return 'https://picsum.photos/seed/profile/200/200';
      case ImageCategory.nature:
        return 'https://picsum.photos/seed/nature/800/600';
      case ImageCategory.food:
        return 'https://picsum.photos/seed/food/800/600';
      case ImageCategory.travel:
        return 'https://picsum.photos/seed/travel/800/600';
      case ImageCategory.product:
        return 'https://picsum.photos/seed/product/800/600';
      case ImageCategory.general:
      default:
        return 'https://picsum.photos/seed/default/800/600';
    }
  }

  // 将任何图片URL转换为Lorem Picsum格式
  String _transformToLoremPicsum(String originalUrl) {
    // 使用原始URL生成一个确定性的种子，使相同的URL始终生成相同的图片
    final int seed = originalUrl.hashCode.abs() % 1000;

    // 确定图片尺寸，根据widget指定的大小或使用默认尺寸
    double? rawWidth = widget.width;
    double? rawHeight = widget.height;

    // 安全转换为整数，避免无限值和NaN
    int width = 800;
    int height = 600;

    if (rawWidth != null && rawWidth.isFinite && rawWidth > 0) {
      width = rawWidth.toInt();
    }

    if (rawHeight != null && rawHeight.isFinite && rawHeight > 0) {
      height = rawHeight.toInt();
    }

    // 取整数并确保尺寸至少为100
    width = math.max(width, 100);
    height = math.max(height, 100);

    // 构造Lorem Picsum URL，添加图片ID（使用种子）和尺寸
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  void _retryLoading() {
    if (_retryCount < widget.maxRetries && mounted) {
      _retryCount++;
      setState(() {
        // State is updated, build will recalculate the URL
        // No need to manually update URL here
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用RepaintBoundary隔离重绘区域，提高性能
    return RepaintBoundary(child: _buildOptimizedImage(context));
  }

  Widget _buildOptimizedImage(BuildContext context) {
    // Calculate key and URL here, inside build
    final String cacheKey = _generateCacheKey(widget.imageUrl);
    final String currentUrl = _processImageUrl(widget.imageUrl);
    final String urlForRetryLogic =
        widget.useOriginalUrl
            ? widget.imageUrl
            : _transformToLoremPicsum(widget.imageUrl); // Base URL for retry

    // URL to use in CachedNetworkImage, potentially modified by retry logic
    String displayUrl = currentUrl;
    if (_retryCount > 0) {
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      final separator = urlForRetryLogic.contains('?') ? '&' : '?';
      displayUrl =
          '$urlForRetryLogic${separator}retry=$_retryCount&t=$timeStamp';
    }

    // 根据shimmerStyle设置默认borderRadius
    final BorderRadius effectiveBorderRadius =
        widget.borderRadius ?? _getDefaultBorderRadius();

    // 在build方法中安全计算缓存尺寸
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    int? effectiveMemCacheWidth;
    int? effectiveMemCacheHeight;

    if (widget.memCacheWidth != null) {
      effectiveMemCacheWidth = widget.memCacheWidth;
    } else if (widget.width != null && widget.width!.isFinite) {
      effectiveMemCacheWidth = (widget.width! * pixelRatio).ceil();
    } else {
      // 提供一个默认值或不设置，让库处理
      effectiveMemCacheWidth = (300 * pixelRatio).ceil(); // Default example
    }

    if (widget.memCacheHeight != null) {
      effectiveMemCacheHeight = widget.memCacheHeight;
    } else if (widget.height != null && widget.height!.isFinite) {
      effectiveMemCacheHeight = (widget.height! * pixelRatio).ceil();
    } else {
      // 提供一个默认值或不设置，让库处理
      effectiveMemCacheHeight = (300 * pixelRatio).ceil(); // Default example
    }

    // 安全计算磁盘缓存尺寸，避免无限值和NaN
    int? safeDiskCacheWidth;
    int? safeDiskCacheHeight;

    if (widget.width != null && widget.width!.isFinite && widget.width! > 0) {
      // 磁盘缓存通常可以更大
      safeDiskCacheWidth = (widget.width! * pixelRatio * 1.5).round();
    }

    if (widget.height != null &&
        widget.height!.isFinite &&
        widget.height! > 0) {
      // 磁盘缓存通常可以更大
      safeDiskCacheHeight = (widget.height! * pixelRatio * 1.5).round();
    }

    // 为Web平台使用基础Image.network组件
    if (kIsWeb) {
      return ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: Image.network(
          displayUrl, // Use displayUrl
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) {
            // 减少日志输出，提高性能
            if (!_hasError) {
              debugPrint('Error loading image on Web: $error');
              _hasError = true;
              if (widget.autoRetry) {
                Future.delayed(widget.retryDelay, _retryLoading);
              }
            }
            return widget.errorWidget ?? _buildErrorPlaceholder(context);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              // Image loaded successfully, reset error flag if needed
              if (_hasError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _hasError = false;
                      _retryCount = 0; // Reset retry count on success
                    });
                  }
                });
              }
              return child;
            }
            return widget.loadingWidget ??
                _buildShimmerEffect(
                  width: widget.width,
                  height: widget.height,
                  borderRadius: effectiveBorderRadius,
                );
          },
          // Web 平台使用浏览器缓存
        ),
      );
    }

    // 移动平台使用CachedNetworkImage
    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: CachedNetworkImage(
        imageUrl: displayUrl, // Use displayUrl
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        maxWidthDiskCache: widget.useDiskCache ? safeDiskCacheWidth : null,
        maxHeightDiskCache: widget.useDiskCache ? safeDiskCacheHeight : null,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
        placeholderFadeInDuration: const Duration(milliseconds: 200),
        memCacheWidth: widget.useMemoryCache ? effectiveMemCacheWidth : null,
        memCacheHeight: widget.useMemoryCache ? effectiveMemCacheHeight : null,
        cacheKey: cacheKey, // Use calculated cacheKey
        useOldImageOnUrlChange: true,
        placeholder:
            (context, url) =>
                widget.loadingWidget ??
                _buildShimmerEffect(
                  width: widget.width,
                  height: widget.height,
                  borderRadius: effectiveBorderRadius,
                ),
        errorWidget: (context, url, error) {
          if (!_hasError) {
            _hasError = true;
            if (widget.autoRetry && error is SocketException ||
                error.toString().contains('Connection') ||
                error.toString().contains('network') ||
                error.toString().contains('timeout')) {
              Future.delayed(widget.retryDelay, _retryLoading);
            }
            // Consider only forwarding fade controller if not retrying?
            _fadeController.forward();
          }

          return _retryCount < widget.maxRetries
              ? _buildShimmerEffect(
                width: widget.width,
                height: widget.height,
                borderRadius: effectiveBorderRadius,
              )
              : widget.errorWidget ?? _buildErrorPlaceholder(context);
        },
        imageBuilder: (context, imageProvider) {
          // Image loaded successfully, reset error flag if needed
          if (_hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _hasError = false;
                  _retryCount = 0; // Reset retry count on success
                });
              }
            });
          }
          _imageLoaded = true;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: effectiveBorderRadius,
              image: DecorationImage(image: imageProvider, fit: widget.fit),
            ),
          );
        },
      ),
    );
  }

  BorderRadius _getDefaultBorderRadius() {
    switch (widget.shimmerStyle) {
      case ShimmerStyle.rectangle:
        return BorderRadius.zero;
      case ShimmerStyle.rounded:
        return BorderRadius.circular(12.r);
      case ShimmerStyle.circle:
        return BorderRadius.circular(1000.r); // 一个足够大的值使其成为圆形
      case ShimmerStyle.custom:
        return BorderRadius.circular(8.r); // 自定义时的默认值
    }
  }

  Widget _buildShimmerEffect({
    double? width,
    double? height,
    required BorderRadius borderRadius,
  }) {
    if (!widget.useAdvancedShimmer) {
      // 基础骨架屏效果
      return Shimmer.fromColors(
        baseColor: widget.shimmerBaseColor ?? Colors.grey[300]!,
        highlightColor: widget.shimmerHighlightColor ?? Colors.grey[100]!,
        period: const Duration(milliseconds: 1500),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
          ),
        ),
      );
    }

    // 高级骨架屏效果 - 带波浪动画和渐变
    return Shimmer.fromColors(
      baseColor:
          widget.shimmerBaseColor ??
          _getShimmerBaseColorForCategory(widget.imageCategory),
      highlightColor:
          widget.shimmerHighlightColor ??
          _getShimmerHighlightColorForCategory(widget.imageCategory),
      period: const Duration(milliseconds: 1200),
      direction: ShimmerDirection.ltr,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: _buildShimmerContent(width, height, borderRadius),
      ),
    );
  }

  // 根据图片类别获取基础颜色
  Color _getShimmerBaseColorForCategory(ImageCategory category) {
    switch (category) {
      case ImageCategory.profile:
        return Color(0xFFE0E0E0);
      case ImageCategory.nature:
        return Color(0xFFECEFEF);
      case ImageCategory.food:
        return Color(0xFFEFE9E7);
      case ImageCategory.travel:
        return Color(0xFFE6EEF4);
      case ImageCategory.product:
        return Color(0xFFF3F3F3);
      case ImageCategory.general:
      default:
        return Color(0xFFE0E0E0);
    }
  }

  // 根据图片类别获取高亮颜色
  Color _getShimmerHighlightColorForCategory(ImageCategory category) {
    switch (category) {
      case ImageCategory.profile:
        return Color(0xFFF5F5F5);
      case ImageCategory.nature:
        return Color(0xFFF7F9F9);
      case ImageCategory.food:
        return Color(0xFFF9F5F4);
      case ImageCategory.travel:
        return Color(0xFFF5F9FD);
      case ImageCategory.product:
        return Color(0xFFFFFFFF);
      case ImageCategory.general:
      default:
        return Color(0xFFF5F5F5);
    }
  }

  // 构建骨架屏内容
  Widget _buildShimmerContent(
    double? width,
    double? height,
    BorderRadius borderRadius,
  ) {
    // 对于特殊类型的图片，添加一些视觉提示
    switch (widget.shimmerStyle) {
      case ShimmerStyle.circle:
        return SizedBox(); // 圆形不需要额外内容
      case ShimmerStyle.rounded:
      case ShimmerStyle.rectangle:
      case ShimmerStyle.custom:
        if (widget.imageCategory == ImageCategory.profile) {
          return Center(
            child: Icon(
              Icons.person_outline,
              size: min((width ?? 60.r) / 2, (height ?? 60.r) / 2),
              color: Colors.white.withOpacity(0.3),
            ),
          );
        } else if (height != null && height > 100.r) {
          // 对于较大的图片区域，添加视觉提示
          return Center(
            child: Icon(
              Icons.image_outlined,
              size: min((width ?? 60.r) / 3, (height ?? 60.r) / 3),
              color: Colors.white.withOpacity(0.3),
            ),
          );
        }
        return SizedBox();
    }
  }

  // 构建错误占位图
  Widget _buildErrorPlaceholder(BuildContext context) {
    // 如果提供了自定义错误Widget，则使用它
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
      ),
      child: Stack(
        children: [
          // 背景 - 使用渐变或本地备用图片
          _buildPlaceholderGradient(),

          // 错误提示内容
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  size: min(
                    (widget.width ?? 60.r) / 4,
                    (widget.height ?? 60.r) / 4,
                  ),
                  color: Colors.white,
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.errorMessage ?? "不好意思哦，图片被我吃掉了",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                // 重试按钮
                GestureDetector(
                  onTap: () {
                    // 重置状态，触发重新加载
                    setState(() {
                      _retryCount = 0;
                      _hasError = false;
                      _imageLoaded = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 14.r, color: Colors.white),
                        SizedBox(width: 4.w),
                        Text(
                          "点击重试",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
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

  // 生成随机渐变颜色
  List<Color> _generateRandomGradientColors() {
    // 定义一些基础颜色
    final List<List<Color>> baseGradients = [
      [const Color(0xFF74ebd5), const Color(0xFFACB6E5)],
      [const Color(0xFFff6e7f), const Color(0xFFbfe9ff)],
      [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
      [const Color(0xFFc31432), const Color(0xFF240b36)],
      [const Color(0xFFED8F03), const Color(0xFFFFB75E)],
    ];

    // 随机选择一组渐变颜色
    final Random random = Random();
    final int index = random.nextInt(baseGradients.length);
    return baseGradients[index];
  }

  // 构建占位符渐变背景
  Widget _buildPlaceholderGradient() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
        gradient: _getGradientForCategory(),
      ),
      child: Center(
        child: Icon(_getIconForCategory(), color: Colors.white70, size: 36.0),
      ),
    );
  }

  // 辅助函数：返回最小值
  double min(double a, double b) {
    return a < b ? a : b;
  }

  // 根据图片类别返回对应的图标
  IconData _getIconForCategory() {
    switch (widget.imageCategory) {
      case ImageCategory.profile:
        return Icons.person;
      case ImageCategory.nature:
        return Icons.landscape;
      case ImageCategory.food:
        return Icons.restaurant;
      case ImageCategory.travel:
        return Icons.flight;
      case ImageCategory.product:
        return Icons.shopping_bag;
      case ImageCategory.general:
      default:
        return Icons.image;
    }
  }

  // 根据图片类别获取渐变颜色
  LinearGradient _getGradientForCategory() {
    // 根据图片类别选择渐变颜色
    List<Color> gradientColors;

    switch (widget.imageCategory) {
      case ImageCategory.profile:
        gradientColors = [const Color(0xFF6A11CB), const Color(0xFF2575FC)];
        break;
      case ImageCategory.nature:
        gradientColors = [const Color(0xFF56ab2f), const Color(0xFFa8e063)];
        break;
      case ImageCategory.food:
        gradientColors = [const Color(0xFFff7e5f), const Color(0xFFfeb47b)];
        break;
      case ImageCategory.travel:
        gradientColors = [const Color(0xFF396afc), const Color(0xFF2948ff)];
        break;
      case ImageCategory.product:
        gradientColors = [const Color(0xFFf953c6), const Color(0xFFb91d73)];
        break;
      case ImageCategory.general:
      default:
        // 为一般类别生成随机渐变
        gradientColors = _generateRandomGradientColors();
        break;
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    );
  }
}
