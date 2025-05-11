import 'dart:convert';
import 'package:text_sphere_app/domain/entities/membership.dart';

/// 会员模型类
///
/// 扩展自Membership实体，添加了序列化和反序列化能力
class MembershipModel extends Membership {
  const MembershipModel({
    required super.level,
    required super.startDate,
    required super.expiryDate,
    required super.privileges,
    super.isActive = true,
    super.autoRenew = false,
  });

  /// 从JSON映射创建会员模型
  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    try {
      return MembershipModel(
        level: MembershipLevel.values.firstWhere(
          (e) => e.toString() == 'MembershipLevel.${json['level']}',
          orElse: () => MembershipLevel.regular,
        ),
        startDate: DateTime.parse(
          json['start_date'] ?? DateTime.now().toIso8601String(),
        ),
        expiryDate: DateTime.parse(
          json['expiry_date'] ?? DateTime.now().toIso8601String(),
        ),
        privileges:
            (json['privileges'] as List<dynamic>?)
                ?.map(
                  (e) => MembershipPrivilege.values.firstWhere(
                    (p) => p.toString() == 'MembershipPrivilege.$e',
                    orElse: () => MembershipPrivilege.memberIcon,
                  ),
                )
                .toList() ??
            [],
        isActive: json['is_active'] as bool? ?? true,
        autoRenew: json['auto_renew'] as bool? ?? false,
      );
    } catch (e) {
      // 异常处理：返回默认会员模型
      print('解析会员数据异常: $e');
      return MembershipModel.regular();
    }
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'level': level.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'privileges':
          privileges
              .where((e) => e != null)
              .map((e) => e.toString().split('.').last)
              .toList(),
      'is_active': isActive,
      'auto_renew': autoRenew,
    };
  }

  /// 从JSON字符串创建会员模型
  factory MembershipModel.fromString(String source) {
    try {
      return MembershipModel.fromJson(
        json.decode(source) as Map<String, dynamic>,
      );
    } catch (e) {
      print('从字符串解析会员数据异常: $e');
      return MembershipModel.regular();
    }
  }

  /// 转换为JSON字符串
  String toJsonString() {
    try {
      return json.encode(toJson());
    } catch (e) {
      print('序列化会员数据异常: $e');
      return '{}';
    }
  }

  /// 创建普通用户会员模型
  factory MembershipModel.regular() {
    final membership = Membership.regular();
    return MembershipModel(
      level: membership.level,
      startDate: membership.startDate,
      expiryDate: membership.expiryDate,
      privileges: membership.privileges,
      isActive: membership.isActive,
      autoRenew: membership.autoRenew,
    );
  }

  /// 创建初级会员模型
  factory MembershipModel.bronze() {
    final membership = Membership.bronze();
    return MembershipModel(
      level: membership.level,
      startDate: membership.startDate,
      expiryDate: membership.expiryDate,
      privileges: membership.privileges,
      isActive: membership.isActive,
      autoRenew: membership.autoRenew,
    );
  }

  /// 创建中级会员模型
  factory MembershipModel.silver() {
    final membership = Membership.silver();
    return MembershipModel(
      level: membership.level,
      startDate: membership.startDate,
      expiryDate: membership.expiryDate,
      privileges: membership.privileges,
      isActive: membership.isActive,
      autoRenew: membership.autoRenew,
    );
  }

  /// 创建高级会员模型
  factory MembershipModel.gold() {
    final membership = Membership.gold();
    return MembershipModel(
      level: membership.level,
      startDate: membership.startDate,
      expiryDate: membership.expiryDate,
      privileges: membership.privileges,
      isActive: membership.isActive,
      autoRenew: membership.autoRenew,
    );
  }

  /// 创建模拟会员数据（用于开发和测试）
  static List<MembershipModel> generateMockMemberships() {
    return [
      MembershipModel.regular(),
      MembershipModel.bronze(),
      MembershipModel.silver(),
      MembershipModel.gold(),
    ];
  }
}
