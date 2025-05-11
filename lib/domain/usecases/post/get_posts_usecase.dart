import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../entities/post.dart';
import '../../repositories/post_repository.dart';

/// 获取帖子列表用例
class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  /// 执行获取帖子列表操作
  ///
  /// 参数:
  /// - [params]: 获取帖子参数，包含页码和每页数量
  ///
  /// 返回:
  /// - 成功: [Right] 包含帖子列表
  /// - 失败: [Left] 包含 [Failure] 对象
  Future<Either<Failure, List<Post>>> call(GetPostsParams params) {
    return repository.getPosts(params.page, params.pageSize);
  }
}

/// 获取帖子参数
class GetPostsParams extends Equatable {
  final int page;
  final int pageSize;

  const GetPostsParams({this.page = 1, this.pageSize = 10});

  @override
  List<Object?> get props => [page, pageSize];
}
