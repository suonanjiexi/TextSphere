import 'package:dartz/dartz.dart';
import '../entities/post.dart';
import '../entities/comment.dart';
import '../../core/error/failures.dart';

/// 帖子仓库接口
///
/// 定义与帖子相关的数据操作方法
abstract class PostRepository {
  /// 获取广场帖子列表
  ///
  /// 参数:
  /// - [page]: 页码，从1开始
  /// - [pageSize]: 每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含帖子列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Post>>> getPosts(int page, int pageSize);

  /// 获取关注用户的帖子列表
  ///
  /// 参数:
  /// - [page]: 页码，从1开始
  /// - [pageSize]: 每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含帖子列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Post>>> getFollowingPosts(int page, int pageSize);

  /// 获取指定用户的帖子列表
  ///
  /// 参数:
  /// - [userId]: 用户ID
  /// - [page]: 页码，从1开始
  /// - [pageSize]: 每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含帖子列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Post>>> getUserPosts(
    String userId,
    int page,
    int pageSize,
  );

  /// 获取帖子详情
  ///
  /// 参数:
  /// - [postId]: 帖子ID
  ///
  /// 返回:
  /// - 成功: [Right] 包含帖子对象
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, Post>> getPostDetail(String postId);

  /// 发布帖子
  ///
  /// 参数:
  /// - [title]: 帖子标题
  /// - [content]: 帖子内容
  /// - [images]: 图片文件路径列表
  /// - [topics]: 话题列表
  ///
  /// 返回:
  /// - 成功: [Right] 包含发布的帖子
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, Post>> createPost(
    String title,
    String content,
    List<String> images,
    List<String> topics,
  );

  /// 更新帖子
  ///
  /// 参数:
  /// - [postId]: 帖子ID
  /// - [title]: 帖子标题
  /// - [content]: 帖子内容
  /// - [topics]: 话题列表
  ///
  /// 返回:
  /// - 成功: [Right] 包含更新后的帖子
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, Post>> updatePost(
    String postId,
    String title,
    String content,
    List<String> topics,
  );

  /// 删除帖子
  ///
  /// 参数:
  /// - [postId]: 帖子ID
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> deletePost(String postId);

  /// 点赞/取消点赞帖子
  ///
  /// 参数:
  /// - [postId]: 帖子ID
  /// - [isLike]: 是否点赞
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> likePost(String postId, bool isLike);

  /// 获取帖子评论列表
  ///
  /// 参数:
  /// - [postId]: 帖子ID
  /// - [page]: 页码，从1开始
  /// - [pageSize]: 每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含评论列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Comment>>> getComments(
    String postId,
    int page,
    int pageSize,
  );

  /// 发布评论
  ///
  /// 参数:
  /// - [postId]: 帖子ID
  /// - [content]: 评论内容
  /// - [parentId]: 父评论ID（可选，用于回复评论）
  /// - [replyToUserId]: 被回复用户ID（可选，用于回复评论）
  ///
  /// 返回:
  /// - 成功: [Right] 包含发布的评论
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, Comment>> createComment(
    String postId,
    String content, {
    String? parentId,
    String? replyToUserId,
  });

  /// 删除评论
  ///
  /// 参数:
  /// - [commentId]: 评论ID
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> deleteComment(String commentId);

  /// 点赞/取消点赞评论
  ///
  /// 参数:
  /// - [commentId]: 评论ID
  /// - [isLike]: 是否点赞
  ///
  /// 返回:
  /// - 成功: [Right] 包含布尔值，表示操作是否成功
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, bool>> likeComment(String commentId, bool isLike);

  /// 获取热门话题列表
  ///
  /// 参数:
  /// - [limit]: 获取数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含话题列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<String>>> getHotTopics(int limit);

  /// 根据话题获取帖子列表
  ///
  /// 参数:
  /// - [topic]: 话题
  /// - [page]: 页码，从1开始
  /// - [pageSize]: 每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含帖子列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Post>>> getPostsByTopic(
    String topic,
    int page,
    int pageSize,
  );

  /// 搜索帖子
  ///
  /// 参数:
  /// - [keyword]: 搜索关键词
  /// - [page]: 页码，从1开始
  /// - [pageSize]: 每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含帖子列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Post>>> searchPosts(
    String keyword,
    int page,
    int pageSize,
  );
}
