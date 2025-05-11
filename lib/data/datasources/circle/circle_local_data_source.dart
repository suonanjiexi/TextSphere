import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_sphere_app/models/circle_model.dart';

/// 圈子本地数据源接口
abstract class CircleLocalDataSource {
  /// 缓存推荐圈子列表
  Future<void> cacheRecommendedCircles(List<CircleModel> circles);

  /// 获取缓存的推荐圈子列表
  Future<List<CircleModel>> getLastRecommendedCircles();

  /// 缓存用户已加入的圈子列表
  Future<void> cacheJoinedCircles(List<CircleModel> circles);

  /// 获取缓存的用户已加入的圈子列表
  Future<List<CircleModel>> getLastJoinedCircles();
}

/// 圈子本地数据源实现
class CircleLocalDataSourceImpl implements CircleLocalDataSource {
  final SharedPreferences sharedPreferences;

  CircleLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheRecommendedCircles(List<CircleModel> circles) {
    // 实际项目中需要实现本地缓存逻辑
    return Future.value();
  }

  @override
  Future<List<CircleModel>> getLastRecommendedCircles() {
    // 实际项目中需要实现本地缓存获取逻辑
    return Future.value([]);
  }

  @override
  Future<void> cacheJoinedCircles(List<CircleModel> circles) {
    // 实际项目中需要实现本地缓存逻辑
    return Future.value();
  }

  @override
  Future<List<CircleModel>> getLastJoinedCircles() {
    // 实际项目中需要实现本地缓存获取逻辑
    return Future.value([]);
  }
}
