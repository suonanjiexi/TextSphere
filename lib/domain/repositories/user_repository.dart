import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/error/failures.dart';

/// 用户仓库接口
///
/// 定义与用户相关的数据操作方法
abstract class UserRepository {
  /// 用户登录
  ///
  /// 参数:
  /// - [username]: 用户名
  /// - [password]: 密码
  ///
  /// 返回:
  /// - 成功: [Right] 包含 [User] 对象
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, User>> login(String username, String password);

  /// 用户注册
  ///
  /// 参数:
  /// - [username]: 用户名
  /// - [password]: 密码
  /// - [nickname]: 昵称
  ///
  /// 返回:
  /// - 成功: [Right] 包含 [User] 对象
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, User>> register(
    String username,
    String password,
    String nickname,
  );

  /// 获取当前登录用户信息
  ///
  /// 返回:
  /// - 成功: [Right] 包含 [User] 对象
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, User>> getCurrentUser();

  /// 更新用户信息
  ///
  /// 参数:
  /// - [user]: 更新后的用户信息
  ///
  /// 返回:
  /// - 成功: [Right] 包含 [User] 对象
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, User>> updateUserInfo(User user);

  /// 上传用户头像
  ///
  /// 参数:
  /// - [filePath]: 头像文件路径
  ///
  /// 返回:
  /// - 成功: [Right] 包含头像URL
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, String>> uploadAvatar(String filePath);

  /// 获取用户关注列表
  ///
  /// 参数:
  /// - [userId]: 用户ID
  /// - [page]: 页码，从1开始
  /// - [pageSize]: 每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含用户列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<User>>> getFollowings(
    String userId,
    int page,
    int pageSize,
  );

  /// 获取用户粉丝列表
  ///
  /// 参数:
  /// - [userId]: 用户ID
  /// - [page]: 页码，从1开始
  /// - [pageSize]: 每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含用户列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<User>>> getFollowers(
    String userId,
    int page,
    int pageSize,
  );

  /// 关注用户
  ///
  /// 参数:
  /// - [userId]: 要关注的用户ID
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> followUser(String userId);

  /// 取消关注用户
  ///
  /// 参数:
  /// - [userId]: 要取消关注的用户ID
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> unfollowUser(String userId);

  /// 用户登出
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> logout();

  /// 搜索用户
  ///
  /// 参数:
  /// - [keyword]: 搜索关键词
  /// - [page]: 页码，从1开始
  /// - [pageSize]: 每页数量
  ///
  /// 返回:
  /// - 成功: 用户列表
  /// - 失败: [Failure] 对象
  Future<Either<Failure, List<User>>> searchUsers(
    String keyword,
    int page,
    int pageSize,
  );
}
