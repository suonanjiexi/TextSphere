import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';

/// 带有动画效果的按钮
class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isOutlined;
  final bool isLoading;

  const AnimatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.color,
    this.textColor,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.isOutlined = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor =
        widget.color ??
        (widget.isOutlined ? Colors.transparent : AppTheme.primaryColor);

    final Color textColor =
        widget.textColor ??
        (widget.isOutlined ? AppTheme.primaryColor : Colors.white);

    // 禁用状态时的颜色
    final Color disabledColor =
        widget.isOutlined ? Colors.transparent : Colors.grey.withOpacity(0.3);

    final Color disabledTextColor =
        widget.isOutlined ? Colors.grey : Colors.white.withOpacity(0.7);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              padding:
                  widget.padding ??
                  EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
              decoration: BoxDecoration(
                color: widget.isLoading ? disabledColor : buttonColor,
                borderRadius: BorderRadius.circular(widget.borderRadius.r),
                border:
                    widget.isOutlined
                        ? Border.all(
                          color:
                              widget.isLoading
                                  ? Colors.grey
                                  : AppTheme.primaryColor,
                          width: 1.5,
                        )
                        : null,
                boxShadow:
                    _isPressed || widget.isOutlined || widget.isLoading
                        ? null
                        : [
                          BoxShadow(
                            color: buttonColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                            spreadRadius: -2,
                          ),
                        ],
              ),
              child: Center(
                child:
                    widget.isLoading
                        ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.isOutlined
                                  ? AppTheme.primaryColor
                                  : Colors.white,
                            ),
                          ),
                        )
                        : DefaultTextStyle(
                          style: TextStyle(
                            color:
                                widget.isLoading
                                    ? disabledTextColor
                                    : textColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          child: widget.child,
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}
