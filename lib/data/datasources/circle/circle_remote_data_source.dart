import 'package:dio/dio.dart';
import 'package:text_sphere_app/models/circle_model.dart';

/// 圈子远程数据源接口
abstract class CircleRemoteDataSource {
  /// 获取推荐圈子列表
  Future<List<CircleModel>> getRecommendedCircles();

  /// 获取用户已加入的圈子列表
  Future<List<CircleModel>> getJoinedCircles();

  /// 获取特定类别的圈子列表
  Future<List<CircleModel>> getCategorizedCircles(String category);

  /// 搜索圈子
  Future<List<CircleModel>> searchCircles(String keyword);

  /// 获取圈子详情
  Future<CircleModel> getCircleDetail(String circleId);

  /// 加入圈子
  Future<bool> joinCircle(String circleId);

  /// 退出圈子
  Future<bool> leaveCircle(String circleId);
}

/// 圈子远程数据源实现
class CircleRemoteDataSourceImpl implements CircleRemoteDataSource {
  final Dio dio;

  CircleRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CircleModel>> getRecommendedCircles() async {
    // 模拟网络请求
    return CircleModel.generateMockCircles()
        .where((circle) => circle.isRecommended)
        .toList();
  }

  @override
  Future<List<CircleModel>> getJoinedCircles() async {
    // 模拟网络请求
    return CircleModel.generateMockCircles()
        .where((circle) => circle.isJoined)
        .toList();
  }

  @override
  Future<List<CircleModel>> getCategorizedCircles(String category) async {
    // 模拟网络请求
    return CircleModel.generateMockCircles()
        .where((circle) => circle.category == category)
        .toList();
  }

  @override
  Future<List<CircleModel>> searchCircles(String keyword) async {
    // 模拟网络请求
    return CircleModel.generateMockCircles()
        .where(
          (circle) =>
              circle.name.toLowerCase().contains(keyword.toLowerCase()) ||
              circle.description.toLowerCase().contains(keyword.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<CircleModel> getCircleDetail(String circleId) async {
    // 模拟网络请求
    final circle = CircleModel.generateMockCircles().firstWhere(
      (circle) => circle.id == circleId,
    );
    return circle;
  }

  @override
  Future<bool> joinCircle(String circleId) async {
    // 模拟网络请求
    return true;
  }

  @override
  Future<bool> leaveCircle(String circleId) async {
    // 模拟网络请求
    return true;
  }
}
