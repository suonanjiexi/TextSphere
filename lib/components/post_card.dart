import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/components/app_avatar.dart';
import 'package:text_sphere_app/utils/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:text_sphere_app/domain/entities/membership.dart';
import 'dart:math' as math;

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCard({
    Key? key,
    required this.post,
    required this.onTap,
    this.onLike,
    this.onComment,
    this.onShare,
  }) : super(key: key);

  // 将图片URL转换为Lorem Picsum格式的URL
  String _transformToLoremPicsum(
    String originalUrl, {
    int width = 800,
    int height = 600,
  }) {
    // 使用原始URL生成一个确定性的种子，使相同的URL始终生成相同的图片
    final int seed = originalUrl.hashCode.abs() % 1000;

    // 确保尺寸至少为100
    width = math.max(width, 100);
    height = math.max(height, 100);

    // 构造Lorem Picsum URL，添加图片ID（使用种子）和尺寸
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: AppTheme.cardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(post['content'], style: AppTheme.bodyLarge),
            ),
            if (post['images'].isNotEmpty) ...[
              SizedBox(height: 12.h),
              _buildImageGrid(),
            ],
            Padding(
              padding: EdgeInsets.all(16.w),
              child: _buildPostFooter(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    // 从post中获取会员等级信息
    MembershipLevel? membershipLevel;
    if (post['author'].containsKey('membership') &&
        post['author']['membership'] != null) {
      final String levelStr =
          post['author']['membership']['level'] ?? 'regular';
      switch (levelStr) {
        case 'bronze':
          membershipLevel = MembershipLevel.bronze;
          break;
        case 'silver':
          membershipLevel = MembershipLevel.silver;
          break;
        case 'gold':
          membershipLevel = MembershipLevel.gold;
          break;
        default:
          membershipLevel = null;
      }
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: post['author']['avatar'],
            radius: 20.r,
            membershipLevel: membershipLevel,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['author']['name'],
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(post['time'], style: AppTheme.bodySmall),
              ],
            ),
          ),
          AppTheme.iconButton(
            icon: Icons.more_horiz,
            onPressed: () {},
            color: AppTheme.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    final List<dynamic> images = post['images'];

    if (images.length == 1) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        width: double.infinity,
        height: 200.h,
        child: ClipRRect(
          borderRadius: AppTheme.defaultRadius,
          child: CachedNetworkImage(
            imageUrl: _transformToLoremPicsum(
              images[0],
              width: 800,
              height: 400,
            ),
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                ),
            errorWidget:
                (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.error),
                ),
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: images.length >= 2 ? 3 : 2,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
          itemCount: images.length > 9 ? 9 : images.length,
          itemBuilder: (context, index) {
            if (index == 8 && images.length > 9) {
              // 显示更多图片
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppTheme.defaultRadius,
                    child: CachedNetworkImage(
                      imageUrl: _transformToLoremPicsum(
                        images[index],
                        width: 300,
                        height: 300,
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(color: Colors.grey[200]),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.error),
                          ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: AppTheme.defaultRadius,
                    ),
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Text(
                        '+${images.length - 9}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ClipRRect(
              borderRadius: AppTheme.defaultRadius,
              child: CachedNetworkImage(
                imageUrl: _transformToLoremPicsum(
                  images[index],
                  width: 300,
                  height: 300,
                ),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey[200]),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.error),
                    ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildPostFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFooterButton(
          icon: Icons.favorite_border,
          label: '${post['likes']}',
          onTap: onLike,
        ),
        _buildFooterButton(
          icon: Icons.chat_bubble_outline,
          label: '${post['comments']}',
          onTap: onComment,
        ),
        _buildFooterButton(
          icon: Icons.share_outlined,
          label: '${post['shares']}',
          onTap: onShare,
        ),
      ],
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppTheme.textSecondary),
            SizedBox(width: 4.w),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
