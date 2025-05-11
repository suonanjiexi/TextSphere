import 'dart:convert';
import 'package:text_sphere_app/domain/entities/circle.dart';

/// 圈子数据模型
///
/// 用于API通信和数据库操作
class CircleModel extends Circle {
  const CircleModel({
    required super.id,
    required super.name,
    required super.description,
    required super.avatarUrl,
    required super.coverUrl,
    required super.membersCount,
    required super.postsCount,
    super.isJoined = false,
    super.isRecommended = true,
    super.category = '',
    super.tags = const [],
    required super.createdAt,
    required super.creatorId,
    required super.creatorName,
  });

  /// 从JSON映射创建圈子模型
  factory CircleModel.fromJson(Map<String, dynamic> json) {
    return CircleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
      coverUrl: json['cover_url'] as String? ?? '',
      membersCount: json['members_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
      isJoined: json['is_joined'] as bool? ?? false,
      isRecommended: json['is_recommended'] as bool? ?? true,
      category: json['category'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      createdAt: json['created_at'] as String? ?? '',
      creatorId: json['creator_id'] as String,
      creatorName: json['creator_name'] as String? ?? '',
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'members_count': membersCount,
      'posts_count': postsCount,
      'is_joined': isJoined,
      'is_recommended': isRecommended,
      'category': category,
      'tags': tags,
      'created_at': createdAt,
      'creator_id': creatorId,
      'creator_name': creatorName,
    };
  }

  /// 从JSON字符串创建圈子模型
  factory CircleModel.fromString(String source) =>
      CircleModel.fromJson(json.decode(source) as Map<String, dynamic>);

  /// 转换为JSON字符串
  String toJsonString() => json.encode(toJson());

  /// 创建模拟数据（用于开发和测试）
  static List<CircleModel> generateMockCircles() {
    return [
      CircleModel(
        id: '1',
        name: '科技爱好者',
        description: '分享最新科技资讯，讨论技术话题',
        avatarUrl: 'https://picsum.photos/60/60?random=1',
        coverUrl: 'https://picsum.photos/800/400?random=11',
        creatorId: 'admin',
        creatorName: '管理员',
        membersCount: 1200,
        postsCount: 356,
        category: '科技',
        tags: ['科技', '编程', '人工智能'],
        isJoined: true,
        isRecommended: true,
        createdAt: '2023-01-15',
      ),
      CircleModel(
        id: '2',
        name: '美食达人',
        description: '分享美食心得，交流烹饪技巧',
        avatarUrl: 'https://picsum.photos/60/60?random=2',
        coverUrl: 'https://picsum.photos/800/400?random=12',
        creatorId: 'foodie',
        creatorName: '美食家',
        membersCount: 856,
        postsCount: 223,
        category: '生活',
        tags: ['美食', '烹饪', '健康'],
        isJoined: false,
        isRecommended: true,
        createdAt: '2023-02-20',
      ),
      CircleModel(
        id: '3',
        name: '旅行爱好者',
        description: '分享旅行经验，推荐旅游景点',
        avatarUrl: 'https://picsum.photos/60/60?random=3',
        coverUrl: 'https://picsum.photos/800/400?random=13',
        creatorId: 'traveler',
        creatorName: '旅行者',
        membersCount: 2300,
        postsCount: 512,
        category: '生活',
        tags: ['旅行', '摄影', '文化'],
        isJoined: false,
        isRecommended: true,
        createdAt: '2023-03-10',
      ),
      CircleModel(
        id: '4',
        name: '读书会',
        description: '交流阅读心得，推荐好书，分享读书笔记',
        avatarUrl: 'https://picsum.photos/60/60?random=4',
        coverUrl: 'https://picsum.photos/800/400?random=14',
        creatorId: 'reader123',
        creatorName: '书虫',
        membersCount: 768,
        postsCount: 189,
        category: '文化',
        tags: ['读书', '文学', '心理'],
        isJoined: true,
        isRecommended: false,
        createdAt: '2023-04-05',
      ),
      CircleModel(
        id: '5',
        name: '编程爱好者',
        description: '分享编程技巧，讨论技术问题，互相学习进步',
        avatarUrl: 'https://picsum.photos/60/60?random=5',
        coverUrl: 'https://picsum.photos/800/400?random=15',
        creatorId: 'coder001',
        creatorName: '程序员',
        membersCount: 1560,
        postsCount: 423,
        category: '科技',
        tags: ['编程', 'Flutter', '人工智能'],
        isJoined: true,
        isRecommended: false,
        createdAt: '2023-05-20',
      ),
    ];
  }
}
