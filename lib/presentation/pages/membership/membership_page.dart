import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/components/membership/membership_card.dart';
import 'package:text_sphere_app/domain/entities/membership.dart';
import 'package:text_sphere_app/core/theme/app_theme.dart';

/// 会员中心页面
class MembershipPage extends StatefulWidget {
  /// 当前用户的会员状态
  final Membership? currentMembership;

  const MembershipPage({Key? key, this.currentMembership}) : super(key: key);

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPlanIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 设置默认选择的会员级别
    if (widget.currentMembership != null &&
        widget.currentMembership!.level != MembershipLevel.regular) {
      switch (widget.currentMembership!.level) {
        case MembershipLevel.bronze:
          _selectedPlanIndex = 0;
          _tabController.animateTo(0);
          break;
        case MembershipLevel.silver:
          _selectedPlanIndex = 1;
          _tabController.animateTo(1);
          break;
        case MembershipLevel.gold:
          _selectedPlanIndex = 2;
          _tabController.animateTo(2);
          break;
        default:
          break;
      }
    }

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedPlanIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentMembership = widget.currentMembership ?? Membership.regular();

    return Scaffold(
      appBar: AppBar(title: const Text('会员中心'), elevation: 0),
      body: Column(
        children: [
          // 当前会员状态卡片
          MembershipCard(
            membership: currentMembership,
            onTap: () {
              // 如果已经是会员，则跳转到会员详情
              if (currentMembership.level != MembershipLevel.regular &&
                  !currentMembership.isExpired) {
                // TODO: 跳转到会员详情页面
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('会员详情功能正在开发中')));
              }
            },
          ),

          SizedBox(height: 16.h),

          // 会员等级选择
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '会员等级',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: Membership.getLevelName(MembershipLevel.bronze)),
                    Tab(text: Membership.getLevelName(MembershipLevel.silver)),
                    Tab(text: Membership.getLevelName(MembershipLevel.gold)),
                  ],
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 会员等级内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMembershipPlanDetails(MembershipLevel.bronze),
                _buildMembershipPlanDetails(MembershipLevel.silver),
                _buildMembershipPlanDetails(MembershipLevel.gold),
              ],
            ),
          ),

          // 底部购买按钮
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMembershipPriceText(_selectedPlanIndex),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        '获得专属${_getMembershipLevelName(_selectedPlanIndex)}图标',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _handleSubscribe(_selectedPlanIndex);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(
                    currentMembership.level != MembershipLevel.regular &&
                            !currentMembership.isExpired
                        ? '立即续费'
                        : '立即开通',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建会员等级详情
  Widget _buildMembershipPlanDetails(MembershipLevel level) {
    final colorScheme = Theme.of(context).colorScheme;

    // 根据等级创建不同的会员实例
    final membershipPlan =
        level == MembershipLevel.bronze
            ? Membership.bronze()
            : level == MembershipLevel.silver
            ? Membership.silver()
            : Membership.gold();

    // 获取会员颜色
    final Color memberColor = _getMembershipColor(level);
    final String membershipName = Membership.getLevelName(level);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        // 会员等级图标展示
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                // 会员图标展示
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: memberColor.withOpacity(0.1),
                    border: Border.all(color: memberColor, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.shield_outlined,
                      size: 60.w,
                      color: memberColor,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  membershipName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: memberColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '专属会员图标',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // 会员价格卡片
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '套餐价格',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildPriceOption(
                  title: '月度会员',
                  price:
                      level == MembershipLevel.bronze
                          ? '￥18'
                          : level == MembershipLevel.silver
                          ? '￥38'
                          : '￥58',
                  isPopular: false,
                ),
                SizedBox(height: 8.h),
                _buildPriceOption(
                  title: '季度会员',
                  price:
                      level == MembershipLevel.bronze
                          ? '￥48'
                          : level == MembershipLevel.silver
                          ? '￥98'
                          : '￥158',
                  isPopular: true,
                  discount: '节省￥6',
                ),
                SizedBox(height: 8.h),
                _buildPriceOption(
                  title: '年度会员',
                  price:
                      level == MembershipLevel.bronze
                          ? '￥168'
                          : level == MembershipLevel.silver
                          ? '￥328'
                          : '￥568',
                  isPopular: false,
                  discount: '节省￥48',
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // 会员特权列表
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '特权详情',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                ...membershipPlan.privileges.map((privilege) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                          size: 20.w,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            Membership.getPrivilegeDescription(privilege),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // 会员使用说明
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '使用说明',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '1. 成功开通会员后，专属图标将立即显示\n'
                  '2. 会员有效期自开通之日起计算\n'
                  '3. 可随时关闭自动续费功能\n'
                  '4. 若有其他问题，请联系客服',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 32.h),
      ],
    );
  }

  // 获取会员等级对应的颜色
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

  // 构建价格选项
  Widget _buildPriceOption({
    required String title,
    required String price,
    required bool isPopular,
    String? discount,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              isPopular
                  ? AppTheme.primaryColor
                  : colorScheme.outline.withOpacity(0.5),
          width: isPopular ? 2 : 1,
        ),
        color: isPopular ? AppTheme.primaryColor.withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isPopular ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (discount != null)
                Text(
                  discount,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            price,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isPopular ? AppTheme.primaryColor : colorScheme.onSurface,
            ),
          ),
          if (isPopular) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '推荐',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 处理订阅
  void _handleSubscribe(int planIndex) {
    // 根据选择的会员等级和当前会员状态执行不同操作
    final level =
        planIndex == 0
            ? MembershipLevel.bronze
            : planIndex == 1
            ? MembershipLevel.silver
            : MembershipLevel.gold;

    // TODO: 实现实际的订阅逻辑

    // 显示测试消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('订阅${Membership.getLevelName(level)}功能正在开发中'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 获取会员级别名称
  String _getMembershipLevelName(int index) {
    switch (index) {
      case 0:
        return Membership.getLevelName(MembershipLevel.bronze);
      case 1:
        return Membership.getLevelName(MembershipLevel.silver);
      case 2:
        return Membership.getLevelName(MembershipLevel.gold);
      default:
        return '';
    }
  }

  // 获取会员价格文本
  String _getMembershipPriceText(int index) {
    switch (index) {
      case 0:
        return '￥18/月起';
      case 1:
        return '￥38/月起';
      case 2:
        return '￥58/月起';
      default:
        return '';
    }
  }
}
