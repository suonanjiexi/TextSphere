import 'package:equatable/equatable.dart';
// 确保Circle类可以被其他文件导入

/// 圈子实体
///
/// 表示应用中的一个圈子，包含圈子的基本信息
class Circle extends Equatable {
  /// 圈子唯一标识
  final String id;

  /// 圈子名称
  final String name;

  /// 圈子描述
  final String description;

  /// 圈子头像URL
  final String avatarUrl;

  /// 圈子封面图URL
  final String coverUrl;

  /// 圈子成员数量
  final int membersCount;

  /// 圈子帖子数量
  final int postsCount;

  /// 当前用户是否已加入
  final bool isJoined;

  /// 是否为推荐圈子
  final bool isRecommended;

  /// 圈子类别（如：科技、生活、美食等）
  final String category;

  /// 圈子标签
  final List<String> tags;

  /// 创建时间
  final String createdAt;

  /// 圈子创建者ID
  final String creatorId;

  /// 圈子创建者名称
  final String creatorName;

  const Circle({
    required this.id,
    required this.name,
    required this.description,
    required this.avatarUrl,
    required this.coverUrl,
    required this.membersCount,
    required this.postsCount,
    required this.isJoined,
    this.isRecommended = true,
    required this.category,
    required this.tags,
    required this.createdAt,
    required this.creatorId,
    required this.creatorName,
  });

  @override
  List<Object> get props => [
    id,
    name,
    description,
    avatarUrl,
    coverUrl,
    membersCount,
    postsCount,
    isJoined,
    isRecommended,
    category,
    tags,
    createdAt,
    creatorId,
    creatorName,
  ];

  /// 获取圈子摘要（用于列表显示）
  String get summary {
    if (description.length <= 50) {
      return description;
    }
    return description.substring(0, 50) + '...';
  }

  /// 复制圈子对象并修改部分属性
  Circle copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? coverUrl,
    int? membersCount,
    int? postsCount,
    bool? isJoined,
    bool? isRecommended,
    String? category,
    List<String>? tags,
    String? createdAt,
    String? creatorId,
    String? creatorName,
  }) {
    return Circle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      membersCount: membersCount ?? this.membersCount,
      postsCount: postsCount ?? this.postsCount,
      isJoined: isJoined ?? this.isJoined,
      isRecommended: isRecommended ?? this.isRecommended,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
    );
  }
}
