import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';

/// 头像组件，统一处理头像图片加载失败的情况
class AppAvatar extends StatefulWidget {
  final String imageUrl;
  final double size;
  final String? placeholderText;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? badge;
  final VoidCallback? onTap;
  final int maxRetries;
  final Duration retryDelay;
  final bool useShimmer;
  final double? borderWidth;
  final Color? borderColor;

  const AppAvatar({
    Key? key,
    required this.imageUrl,
    required this.size,
    this.placeholderText,
    this.backgroundColor,
    this.textColor,
    this.badge,
    this.onTap,
    this.maxRetries = 1,
    this.retryDelay = const Duration(seconds: 1),
    this.useShimmer = true,
    this.borderWidth,
    this.borderColor,
  }) : super(key: key);

  @override
  State<AppAvatar> createState() => _AppAvatarState();
}

class _AppAvatarState extends State<AppAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _hasError = false;
  int _retryCount = 0;
  late String _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.imageUrl ?? '';
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
  }

  @override
  void didUpdateWidget(AppAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _currentUrl = widget.imageUrl ?? '';
        _hasError = false;
        _retryCount = 0;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _retryLoading() {
    if (mounted && _retryCount < widget.maxRetries && widget.imageUrl != null) {
      setState(() {
        _retryCount++;
        _currentUrl = '${widget.imageUrl}?retry=$_retryCount';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = widget.size.r;
    final double innerSize =
        avatarSize - (widget.borderWidth != null ? widget.borderWidth! * 2 : 0);

    Widget avatarWidget;

    if (widget.imageUrl != null && widget.imageUrl.isNotEmpty) {
      Widget imageWidget = CachedNetworkImage(
        imageUrl: _currentUrl,
        width: innerSize,
        height: innerSize,
        fit: BoxFit.cover,
        fadeInDuration: Duration(milliseconds: 300),
        fadeOutDuration: Duration(milliseconds: 300),
        memCacheWidth: innerSize.toInt() * 2,
        memCacheHeight: innerSize.toInt() * 2,
        cacheKey: _currentUrl,
        placeholder: (context, url) => _buildShimmerEffect(context),
        errorWidget: (context, url, error) {
          print('AppAvatar加载错误: $error, URL: $url');
          if (!_hasError) {
            _hasError = true;

            // 对于一些网络错误，尝试自动重试
            if (error is SocketException ||
                error.toString().contains('Connection') ||
                error.toString().contains('network') ||
                error.toString().contains('timeout')) {
              Future.delayed(widget.retryDelay, _retryLoading);
            }
            _fadeController.forward();
          }

          return _retryCount < widget.maxRetries
              ? _buildShimmerEffect(context)
              : _buildPlaceholder(context, innerSize);
        },
      );

      avatarWidget = ClipRRect(
        borderRadius: BorderRadius.circular(innerSize / 2),
        child: imageWidget,
      );
    } else {
      avatarWidget = _buildPlaceholder(context, innerSize);
    }

    // 基础容器，带有阴影效果
    Widget baseContainer = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            widget.backgroundColor ??
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: avatarSize / 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: avatarWidget,
    );

    // 如果设置了边框
    if (widget.borderWidth != null &&
        widget.borderWidth! > 0 &&
        widget.borderColor != null) {
      baseContainer = Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.borderColor,
        ),
        child: Center(
          child: SizedBox(
            width: innerSize,
            height: innerSize,
            child: avatarWidget,
          ),
        ),
      );
    }

    // 添加徽章和点击处理
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          baseContainer,
          if (widget.badge != null)
            Positioned(right: 0, bottom: 0, child: widget.badge!),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    if (widget.useShimmer) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: widget.size.r,
          height: widget.size.r,
          color: Colors.white,
        ),
      );
    } else {
      return Container(
        width: widget.size.r,
        height: widget.size.r,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      );
    }
  }

  Widget _buildPlaceholder(BuildContext context, double size) {
    // 从名字/昵称获取首字母
    String initial =
        widget.placeholderText != null && widget.placeholderText!.isNotEmpty
            ? widget.placeholderText![0].toUpperCase()
            : "?";

    // 生成颜色
    Color bgColor = _getColorFromText(widget.placeholderText ?? "?");

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 根据文本生成一致的颜色
  Color _getColorFromText(String text) {
    int hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    hash = hash.abs();
    final int red = (hash & 0xFF0000) >> 16;
    final int green = (hash & 0x00FF00) >> 8;
    final int blue = hash & 0x0000FF;

    // 使颜色更暗，以使白色文本更可读
    final darkenFactor = 0.7;

    return Color.fromRGBO(
      (red * darkenFactor).round(),
      (green * darkenFactor).round(),
      (blue * darkenFactor).round(),
      1,
    );
  }
}
