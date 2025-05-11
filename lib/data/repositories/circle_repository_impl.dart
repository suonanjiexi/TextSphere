import 'package:dartz/dartz.dart';
import 'package:text_sphere_app/core/error/failures.dart';
import 'package:text_sphere_app/core/network/network_info.dart';
import 'package:text_sphere_app/data/datasources/circle/circle_local_data_source.dart';
import 'package:text_sphere_app/data/datasources/circle/circle_remote_data_source.dart';
import 'package:text_sphere_app/domain/entities/circle.dart';
import 'package:text_sphere_app/domain/repositories/circle_repository.dart';
import 'package:text_sphere_app/models/circle_model.dart';

/// 圈子存储库实现
class CircleRepositoryImpl implements CircleRepository {
  final CircleRemoteDataSource remoteDataSource;
  final CircleLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CircleRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Circle>>> getRecommendedCircles() async {
    // 目前使用模拟数据，后续会接入真实API
    return Right(
      CircleModel.generateMockCircles()
          .where((circle) => circle.isRecommended)
          .toList(),
    );
  }

  @override
  Future<Either<Failure, List<Circle>>> getJoinedCircles() async {
    // 目前使用模拟数据，后续会接入真实API
    return Right(
      CircleModel.generateMockCircles()
          .where((circle) => circle.isJoined)
          .toList(),
    );
  }

  @override
  Future<Either<Failure, List<Circle>>> getCategorizedCircles(
    String category,
  ) async {
    // 目前使用模拟数据，后续会接入真实API
    return Right(
      CircleModel.generateMockCircles()
          .where((circle) => circle.category == category)
          .toList(),
    );
  }

  @override
  Future<Either<Failure, List<Circle>>> searchCircles(String keyword) async {
    // 目前使用模拟数据，后续会接入真实API
    return Right(
      CircleModel.generateMockCircles()
          .where(
            (circle) =>
                circle.name.toLowerCase().contains(keyword.toLowerCase()) ||
                circle.description.toLowerCase().contains(
                  keyword.toLowerCase(),
                ),
          )
          .toList(),
    );
  }

  @override
  Future<Either<Failure, Circle>> getCircleDetail(String circleId) async {
    // 目前使用模拟数据，后续会接入真实API
    try {
      final circle = CircleModel.generateMockCircles().firstWhere(
        (circle) => circle.id == circleId,
      );
      return Right(circle);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> joinCircle(String circleId) async {
    // 模拟加入圈子的操作
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> leaveCircle(String circleId) async {
    // 模拟退出圈子的操作
    return const Right(true);
  }

  @override
  Future<Either<Failure, Circle>> createCircle({
    required String name,
    required String description,
    required String category,
    required List<String> tags,
    String? avatarUrl,
    String? coverUrl,
  }) async {
    // 模拟创建圈子的操作
    try {
      // 生成一个新的圈子ID（实际应用中应该由后端生成）
      final String id = DateTime.now().millisecondsSinceEpoch.toString();

      // 使用当前时间作为创建时间
      final String createdAt = DateTime.now().toString().substring(0, 10);

      // 模拟创建者ID和名称（实际应用中应该使用当前登录用户）
      const String creatorId = 'current_user';
      const String creatorName = '当前用户';

      // 创建新的圈子对象
      final newCircle = CircleModel(
        id: id,
        name: name,
        description: description,
        avatarUrl:
            avatarUrl ?? 'https://picsum.photos/60/60?random=${id.hashCode}',
        coverUrl:
            coverUrl ?? 'https://picsum.photos/800/400?random=${id.hashCode}',
        membersCount: 1, // 初始只有创建者一个成员
        postsCount: 0,
        isJoined: true, // 创建者自动加入
        isRecommended: false,
        category: category,
        tags: tags,
        createdAt: createdAt,
        creatorId: creatorId,
        creatorName: creatorName,
      );

      // 返回创建的圈子
      return Right(newCircle);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
