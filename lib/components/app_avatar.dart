import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';
import 'package:text_sphere_app/domain/entities/membership.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 头像组件
///
/// 用于显示用户或圈子头像
class AppAvatar extends StatelessWidget {
  /// 头像图片URL
  final String imageUrl;

  /// 头像半径
  final double radius;

  /// 头像边框
  final Border? border;

  /// 点击事件回调
  final VoidCallback? onTap;

  /// 徽章组件
  final Widget? badge;

  /// 会员等级
  final MembershipLevel? membershipLevel;

  const AppAvatar({
    Key? key,
    required this.imageUrl,
    this.radius = 20,
    this.border,
    this.onTap,
    this.badge,
    this.membershipLevel,
  }) : super(key: key);

  // 将图片URL转换为Lorem Picsum格式的URL
  String _transformToLoremPicsum(String url) {
    // 如果URL为空，使用随机图片
    if (url.isEmpty) {
      return 'https://picsum.photos/${(radius * 2).toInt()}/${(radius * 2).toInt()}?random=${DateTime.now().millisecondsSinceEpoch}';
    }
    return url;
  }

  // 获取会员图标的颜色
  Color _getMembershipColor(MembershipLevel level) {
    switch (level) {
      case MembershipLevel.bronze:
        return const Color(0xFFCD7F32);
      case MembershipLevel.silver:
        return const Color(0xFFC0C0C0);
      case MembershipLevel.gold:
        return const Color(0xFFFFD700);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget avatar = CachedNetworkImage(
      imageUrl: _transformToLoremPicsum(imageUrl),
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Container(
            color: AppTheme.inputBackground,
            child: Icon(
              Icons.person,
              size: radius * 1.2,
              color: AppTheme.textLight,
            ),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: AppTheme.inputBackground,
            child: Icon(
              Icons.person,
              size: radius * 1.2,
              color: AppTheme.textLight,
            ),
          ),
    );

    final Widget circleAvatar = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      clipBehavior: Clip.antiAlias,
      child: avatar,
    );

    Widget result = circleAvatar;

    if (onTap != null) {
      result = InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: result,
      );
    }

    // 添加会员图标
    if (membershipLevel != null && membershipLevel != MembershipLevel.regular) {
      final membershipColor = _getMembershipColor(membershipLevel!);

      // 创建会员图标
      final membershipBadge = Container(
        width: radius * 0.8,
        height: radius * 0.8,
        decoration: BoxDecoration(
          color: membershipColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          Icons.shield,
          color:
              membershipLevel == MembershipLevel.gold ||
                      membershipLevel == MembershipLevel.silver
                  ? Colors.black
                  : Colors.white,
          size: radius * 0.5,
        ),
      );

      // 添加会员图标，优先于徽章
      result = Stack(
        children: [
          result,
          Positioned(right: 0, bottom: 0, child: membershipBadge),
        ],
      );
    }

    // 添加徽章
    if (badge != null) {
      result = Stack(
        children: [
          result,
          Positioned(
            right:
                membershipLevel != null &&
                        membershipLevel != MembershipLevel.regular
                    ? radius * 0.8
                    : 0,
            bottom: 0,
            child: badge!,
          ),
        ],
      );
    }

    return result;
  }
}
