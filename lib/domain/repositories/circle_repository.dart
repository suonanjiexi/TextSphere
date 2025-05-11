import 'package:dartz/dartz.dart';
import 'package:text_sphere_app/core/error/failures.dart';
import 'package:text_sphere_app/domain/entities/circle.dart';

/// 圈子存储库接口
abstract class CircleRepository {
  /// 获取推荐圈子列表
  Future<Either<Failure, List<Circle>>> getRecommendedCircles();

  /// 获取用户已加入的圈子列表
  Future<Either<Failure, List<Circle>>> getJoinedCircles();

  /// 获取特定类别的圈子列表
  Future<Either<Failure, List<Circle>>> getCategorizedCircles(String category);

  /// 搜索圈子
  Future<Either<Failure, List<Circle>>> searchCircles(String keyword);

  /// 获取圈子详情
  Future<Either<Failure, Circle>> getCircleDetail(String circleId);

  /// 加入圈子
  Future<Either<Failure, bool>> joinCircle(String circleId);

  /// 退出圈子
  Future<Either<Failure, bool>> leaveCircle(String circleId);

  /// 创建圈子
  Future<Either<Failure, Circle>> createCircle({
    required String name,
    required String description,
    required String category,
    required List<String> tags,
    String? avatarUrl,
    String? coverUrl,
  });
}
