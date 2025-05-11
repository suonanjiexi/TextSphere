import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/domain/entities/membership.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';

/// 会员卡组件，用于显示会员基本信息
class MembershipCard extends StatelessWidget {
  /// 会员信息
  final Membership membership;

  /// 点击卡片回调
  final VoidCallback? onTap;

  const MembershipCard({Key? key, required this.membership, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 根据会员等级设置不同的卡片样式
    Color cardColor;
    Color textColor;
    String levelName = Membership.getLevelName(membership.level);

    switch (membership.level) {
      case MembershipLevel.bronze:
        cardColor = const Color(0xFFCD7F32);
        textColor = Colors.white;
        break;
      case MembershipLevel.silver:
        cardColor = const Color(0xFFC0C0C0);
        textColor = Colors.black87;
        break;
      case MembershipLevel.gold:
        cardColor = const Color(0xFFFFD700);
        textColor = Colors.black;
        break;
      case MembershipLevel.regular:
      default:
        cardColor = colorScheme.surface;
        textColor = colorScheme.onSurface;
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  membership.level == MembershipLevel.regular
                      ? [colorScheme.surface, colorScheme.surfaceVariant]
                      : [cardColor, cardColor.withOpacity(0.7)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (membership.level != MembershipLevel.regular)
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: textColor.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.shield,
                                color: textColor,
                                size: 20.w,
                              ),
                            ),
                          ),
                        if (membership.level != MembershipLevel.regular)
                          SizedBox(width: 8.w),
                        Text(
                          levelName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    if (membership.level != MembershipLevel.regular)
                      Icon(Icons.verified, color: textColor, size: 24.w),
                  ],
                ),
                SizedBox(height: 16.h),
                if (membership.level != MembershipLevel.regular) ...[
                  Text(
                    membership.isExpired
                        ? '会员已过期'
                        : '剩余${membership.remainingDays}天',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  LinearProgressIndicator(
                    value:
                        membership.isExpired
                            ? 0.0
                            : membership.remainingDays / 30,
                    backgroundColor: textColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor.withOpacity(0.8),
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ] else
                  Text(
                    '开通会员，获得专属会员图标',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colorScheme.primary,
                    ),
                  ),

                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (membership.level == MembershipLevel.regular)
                      OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                        child: const Text('开通会员'),
                      )
                    else if (membership.isExpired)
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textColor.withOpacity(0.9),
                          foregroundColor: cardColor,
                        ),
                        child: const Text('立即续费'),
                      )
                    else
                      TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(foregroundColor: textColor),
                        child: const Text('管理会员'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
