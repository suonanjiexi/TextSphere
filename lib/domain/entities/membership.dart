import 'package:equatable/equatable.dart';

/// 会员等级类型
enum MembershipLevel {
  /// 普通用户（非会员）
  regular,

  /// 初级会员
  bronze,

  /// 中级会员
  silver,

  /// 高级会员
  gold,
}

/// 会员特权类型
enum MembershipPrivilege {
  /// 会员图标
  memberIcon,
}

/// 会员实体类
///
/// 表示用户的会员信息，包含会员级别、期限和权益等
class Membership extends Equatable {
  /// 会员级别
  final MembershipLevel level;

  /// 会员开始时间
  final DateTime startDate;

  /// 会员到期时间
  final DateTime expiryDate;

  /// 会员特权列表
  final List<MembershipPrivilege> privileges;

  /// 是否处于活跃状态
  final bool isActive;

  /// 自动续费状态
  final bool autoRenew;

  const Membership({
    required this.level,
    required this.startDate,
    required this.expiryDate,
    required this.privileges,
    this.isActive = true,
    this.autoRenew = false,
  });

  /// 判断会员是否已过期
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// 获取会员剩余天数
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(expiryDate)) {
      return 0;
    }
    return expiryDate.difference(now).inDays;
  }

  /// 检查是否具有指定特权
  bool hasPrivilege(MembershipPrivilege privilege) {
    return privileges.contains(privilege);
  }

  /// 创建普通用户会员信息（非会员）
  factory Membership.regular() {
    final now = DateTime.now();
    return Membership(
      level: MembershipLevel.regular,
      startDate: now,
      expiryDate: now,
      privileges: const [],
      isActive: false,
    );
  }

  /// 创建初级会员
  factory Membership.bronze() {
    final now = DateTime.now();
    return Membership(
      level: MembershipLevel.bronze,
      startDate: now,
      expiryDate: now.add(const Duration(days: 30)),
      privileges: const [MembershipPrivilege.memberIcon],
      isActive: true,
    );
  }

  /// 创建中级会员
  factory Membership.silver() {
    final now = DateTime.now();
    return Membership(
      level: MembershipLevel.silver,
      startDate: now,
      expiryDate: now.add(const Duration(days: 30)),
      privileges: const [MembershipPrivilege.memberIcon],
      isActive: true,
    );
  }

  /// 创建高级会员
  factory Membership.gold() {
    final now = DateTime.now();
    return Membership(
      level: MembershipLevel.gold,
      startDate: now,
      expiryDate: now.add(const Duration(days: 30)),
      privileges: const [MembershipPrivilege.memberIcon],
      isActive: true,
    );
  }

  @override
  List<Object?> get props => [
    level,
    startDate,
    expiryDate,
    privileges,
    isActive,
    autoRenew,
  ];

  /// 获取指定会员等级的名称
  static String getLevelName(MembershipLevel level) {
    switch (level) {
      case MembershipLevel.regular:
        return '普通用户';
      case MembershipLevel.bronze:
        return '初级会员';
      case MembershipLevel.silver:
        return '中级会员';
      case MembershipLevel.gold:
        return '高级会员';
      default:
        return '未知会员';
    }
  }

  /// 获取特权描述
  static String getPrivilegeDescription(MembershipPrivilege privilege) {
    switch (privilege) {
      case MembershipPrivilege.memberIcon:
        return '会员等级图标';
      default:
        return '未知特权';
    }
  }

  /// 复制会员对象并修改部分属性
  Membership copyWith({
    MembershipLevel? level,
    DateTime? startDate,
    DateTime? expiryDate,
    List<MembershipPrivilege>? privileges,
    bool? isActive,
    bool? autoRenew,
  }) {
    return Membership(
      level: level ?? this.level,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      privileges: privileges ?? this.privileges,
      isActive: isActive ?? this.isActive,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }
}
