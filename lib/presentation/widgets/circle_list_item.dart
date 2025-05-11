import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_sphere_app/domain/entities/circle.dart';
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart';
import 'package:text_sphere_app/presentation/widgets/app_network_image.dart';

class CircleListItem extends StatelessWidget {
  final Circle circle;
  final VoidCallback? onJoinTap;

  const CircleListItem({Key? key, required this.circle, this.onJoinTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 安全获取尺寸，避免NaN或Infinity值
    final double safeWidth =
        MediaQuery.of(context).size.width > 0
            ? MediaQuery.of(context).size.width
            : 360.0;

    return GestureDetector(
      onTap: () {
        try {
          // 确保id存在且有效
          if (circle.id.isNotEmpty) {
            context.push('/circle/${circle.id}');
          }
        } catch (e) {
          print('导航到圈子详情页失败: $e');
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 圈子封面图
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: SizedBox(
                height: 120.h,
                width: safeWidth - 32.w, // 使用安全值减去边距
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      imageUrl: circle.coverUrl,
                      fit: BoxFit.cover,
                      useAdvancedShimmer: true,
                      shimmerStyle: ShimmerStyle.rounded,
                    ),
                    Container(
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
                    Positioned(
                      left: 16.w,
                      bottom: 16.h,
                      child: Row(
                        children: [
                          AppAvatar(
                            imageUrl: circle.avatarUrl,
                            size: 40,
                            placeholderText: circle.name,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderWidth: 2,
                            borderColor: Colors.white,
                            useShimmer: true,
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                circle.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${circle.membersCount}成员 · ${circle.postsCount}帖子',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 16.w,
                      bottom: 16.h,
                      child: _buildJoinButton(context),
                    ),
                  ],
                ),
              ),
            ),

            // 圈子信息
            Padding(
              padding: EdgeInsets.all(16.r),
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
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          circle.category,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (circle.tags.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            circle.tags.first,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    circle.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    return GestureDetector(
      onTap: onJoinTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
              circle.isJoined
                  ? Colors.white.withOpacity(0.3)
                  : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              circle.isJoined ? Icons.check : Icons.add,
              color: Colors.white,
              size: 16.r,
            ),
            SizedBox(width: 4.w),
            Text(
              circle.isJoined ? '已加入' : '加入',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
