import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// 骨架屏加载组件
class SkeletonLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  const SkeletonLoading({
    Key? key,
    required this.child,
    this.isLoading = true,
    this.baseColor = const Color(0xFFEEEEEE),
    this.highlightColor = const Color(0xFFF8F8F8),
    this.period = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: period,
      child: child,
    );
  }

  /// 创建简单的骨架加载项
  static Widget item({
    double? width,
    double? height,
    double borderRadius = 8,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }

  /// 创建圆形骨架加载项，适用于头像
  static Widget circle({double size = 48, EdgeInsetsGeometry? margin}) {
    return Container(
      width: size.r,
      height: size.r,
      margin: margin,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  /// 创建文本行骨架加载
  static Widget text({
    double? width,
    double height = 16,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height.h,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  /// 创建列表项骨架加载
  static Widget listItem({
    required BuildContext context,
    double height = 100,
    EdgeInsetsGeometry? margin,
    bool hasImage = true,
  }) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) ...[circle(size: 48), SizedBox(width: 12.w)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(width: 120.w),
                SizedBox(height: 8.h),
                text(width: 80.w, height: 12),
                SizedBox(height: 12.h),
                text(width: double.infinity),
                SizedBox(height: 8.h),
                text(width: MediaQuery.of(context).size.width * 0.6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 创建帖子卡片骨架加载
  static Widget postCard({
    required BuildContext context,
    bool hasImage = true,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息骨架
            Row(
              children: [
                circle(size: 40),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      text(width: 120.w),
                      SizedBox(height: 4.h),
                      text(width: 80.w, height: 12),
                    ],
                  ),
                ),
                item(width: 24.w, height: 24.h, borderRadius: 12),
              ],
            ),
            SizedBox(height: 16.h),
            // 内容骨架
            text(width: double.infinity),
            SizedBox(height: 8.h),
            text(width: double.infinity),

            // 图片骨架
            if (hasImage) ...[
              SizedBox(height: 16.h),
              item(width: double.infinity, height: 180.h, borderRadius: 12),
            ],

            SizedBox(height: 16.h),
            // 操作按钮骨架
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                3,
                (i) => item(width: 80.w, height: 24.h, borderRadius: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 创建个人资料卡片骨架加载
  static Widget profileCard({
    required BuildContext context,
    double height = 200,
    EdgeInsetsGeometry? margin,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: margin ?? EdgeInsets.all(16.r),
      height: height.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          circle(size: 80),
          SizedBox(height: 16.h),
          text(width: screenWidth * 0.4),
          SizedBox(height: 8.h),
          text(width: screenWidth * 0.3, height: 12),
          SizedBox(height: 16.h),
          text(width: screenWidth * 0.6),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  text(width: 40.w),
                  SizedBox(height: 4.h),
                  text(width: 60.w, height: 12),
                ],
              ),
              SizedBox(width: 32.w),
              Column(
                children: [
                  text(width: 40.w),
                  SizedBox(height: 4.h),
                  text(width: 60.w, height: 12),
                ],
              ),
              SizedBox(width: 32.w),
              Column(
                children: [
                  text(width: 40.w),
                  SizedBox(height: 4.h),
                  text(width: 60.w, height: 12),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
