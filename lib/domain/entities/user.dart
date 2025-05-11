import 'package:equatable/equatable.dart';
import 'package:text_sphere_app/domain/entities/membership.dart';

/// 用户实体
///
/// 表示应用中的用户，包含用户的基本信息
class User extends Equatable {
  /// 用户唯一标识
  final String id;

  /// 用户名
  final String username;

  /// 用户昵称
  final String nickname;

  /// 用户头像URL
  final String avatar;

  /// 用户简介
  final String? bio;

  /// 关注数量
  final int followingCount;

  /// 粉丝数量
  final int followerCount;

  /// 会员信息
  final Membership? membership;

  /// 用户状态（0-正常，1-禁言，2-封禁）
  final int status;

  /// 创建时间
  final DateTime createdAt;

  /// 上次登录时间
  final DateTime lastLoginAt;

  /// 是否已关注
  final bool? isFollowed;

  const User({
    required this.id,
    required this.username,
    required this.nickname,
    this.avatar = '',
    this.bio = '',
    this.followingCount = 0,
    this.followerCount = 0,
    this.membership,
    this.status = 0,
    required this.createdAt,
    required this.lastLoginAt,
    this.isFollowed,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    nickname,
    avatar,
    bio,
    followingCount,
    followerCount,
    membership,
    status,
    createdAt,
    lastLoginAt,
    isFollowed,
  ];

  /// 创建一个匿名用户（用于未登录状态）
  factory User.anonymous() => User(
    id: '',
    username: 'anonymous',
    nickname: '游客',
    membership: Membership.regular(),
    createdAt: DateTime.now(),
    lastLoginAt: DateTime.now(),
  );

  /// 判断用户是否已认证（即非匿名用户）
  bool get isAuthenticated => id.isNotEmpty;

  /// 判断用户账号是否正常
  bool get isActive => status == 0;

  /// 判断用户是否是会员
  bool get isMember =>
      membership != null &&
      membership!.level != MembershipLevel.regular &&
      !membership!.isExpired;

  /// 获取会员等级
  MembershipLevel get membershipLevel =>
      membership?.level ?? MembershipLevel.regular;

  /// 判断是否有特定会员特权
  bool hasPrivilege(MembershipPrivilege privilege) {
    if (!isMember) return false;
    return membership!.hasPrivilege(privilege);
  }

  /// 复制用户对象并修改部分属性
  User copyWith({
    String? id,
    String? username,
    String? nickname,
    String? avatar,
    String? bio,
    int? followingCount,
    int? followerCount,
    Membership? membership,
    int? status,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isFollowed,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      followingCount: followingCount ?? this.followingCount,
      followerCount: followerCount ?? this.followerCount,
      membership: membership ?? this.membership,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}
