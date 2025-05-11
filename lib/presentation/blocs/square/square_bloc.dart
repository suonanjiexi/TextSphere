import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

import '../../../domain/entities/post.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../core/error/failures.dart';
import 'square_event.dart';
import 'square_state.dart';

class SquareBloc extends Bloc<SquareEvent, SquareState> {
  final PostRepository _postRepository;

  SquareBloc({required PostRepository postRepository})
    : _postRepository = postRepository,
      super(const SquareState()) {
    on<LoadSquarePosts>(_onLoadSquarePosts);
    on<RefreshSquarePosts>(_onRefreshSquarePosts);
    on<LoadMoreSquarePosts>(_onLoadMoreSquarePosts);
    on<SwitchTopic>(_onSwitchTopic);
    on<ToggleLikePost>(_onToggleLikePost);
  }

  // 用于预加载图片的函数
  void _preloadImages(List<Post> posts) {
    // 提取所有需要预加载的图片URL
    final List<String> imageUrls = [];

    for (final post in posts) {
      // 添加用户头像
      if (post.userAvatar != null && post.userAvatar.isNotEmpty) {
        imageUrls.add(
          _transformToLoremPicsum(post.userAvatar, width: 200, height: 200),
        );
      }

      // 添加帖子图片
      if (post.images != null && post.images.isNotEmpty) {
        for (final img in post.images) {
          if (post.images.length == 1) {
            imageUrls.add(
              _transformToLoremPicsum(img, width: 800, height: 400),
            );
          } else {
            imageUrls.add(
              _transformToLoremPicsum(img, width: 300, height: 300),
            );
          }
        }
      }
    }

    // 批量预缓存图片 - 使用resolve方法替代precacheImage
    for (final url in imageUrls) {
      final provider = CachedNetworkImageProvider(url);
      provider.resolve(ImageConfiguration.empty);
    }
  }

  // 将图片URL转换为Lorem Picsum格式的URL
  String _transformToLoremPicsum(
    String originalUrl, {
    int width = 800,
    int height = 600,
  }) {
    // 使用原始URL生成一个确定性的种子，使相同的URL始终生成相同的图片
    final int seed = originalUrl.hashCode.abs() % 1000;

    // 确保尺寸至少为100
    width = math.max(width, 100);
    height = math.max(height, 100);

    // 构造Lorem Picsum URL，添加图片ID（使用种子）和尺寸
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  Future<void> _onLoadSquarePosts(
    LoadSquarePosts event,
    Emitter<SquareState> emit,
  ) async {
    if (state.status == SquareStatus.loading) return;

    emit(
      state.copyWith(
        status: SquareStatus.loading,
        currentTopic: event.topic,
        currentPage: 1,
        hasReachedMax: false,
      ),
    );

    final result = await _fetchPosts(event.topic, 1, event.pageSize);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SquareStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ),
      ),
      (posts) {
        // 在后台预加载图片
        _preloadImages(posts);

        emit(
          state.copyWith(
            status: SquareStatus.success,
            posts: posts,
            hasReachedMax: posts.length < event.pageSize,
          ),
        );

        // 如果有足够的内容，预加载下一页
        if (posts.length >= event.pageSize) {
          _prefetchNextPage(event.topic, 2, event.pageSize);
        }
      },
    );
  }

  Future<void> _onRefreshSquarePosts(
    RefreshSquarePosts event,
    Emitter<SquareState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SquareStatus.loading,
        currentPage: 1,
        hasReachedMax: false,
      ),
    );

    final result = await _fetchPosts(state.currentTopic, 1, event.pageSize);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SquareStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ),
      ),
      (posts) {
        // 在后台预加载图片
        _preloadImages(posts);

        emit(
          state.copyWith(
            status: SquareStatus.success,
            posts: posts,
            hasReachedMax: posts.length < event.pageSize,
          ),
        );

        // 如果有足够的内容，预加载下一页
        if (posts.length >= event.pageSize) {
          _prefetchNextPage(state.currentTopic, 2, event.pageSize);
        }
      },
    );
  }

  // 预取下一页内容
  Future<void> _prefetchNextPage(String topic, int page, int pageSize) async {
    final result = await _fetchPosts(topic, page, pageSize);

    result.fold(
      (failure) => null, // 忽略错误，因为这只是预加载
      (posts) {
        // 在后台预加载下一页的图片
        _preloadImages(posts);
      },
    );
  }

  Future<void> _onLoadMoreSquarePosts(
    LoadMoreSquarePosts event,
    Emitter<SquareState> emit,
  ) async {
    if (state.hasReachedMax || state.status == SquareStatus.loadMore) return;

    emit(state.copyWith(status: SquareStatus.loadMore));

    final nextPage = state.currentPage + 1;
    final result = await _fetchPosts(
      state.currentTopic,
      nextPage,
      event.pageSize,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SquareStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ),
      ),
      (posts) {
        if (posts.isEmpty) {
          emit(
            state.copyWith(status: SquareStatus.success, hasReachedMax: true),
          );
          return;
        }

        // 在后台预加载图片
        _preloadImages(posts);

        emit(
          state.copyWith(
            status: SquareStatus.success,
            posts: [...state.posts, ...posts],
            currentPage: nextPage,
            hasReachedMax: posts.length < event.pageSize,
          ),
        );

        // 预加载下一页
        if (posts.length >= event.pageSize) {
          _prefetchNextPage(state.currentTopic, nextPage + 1, event.pageSize);
        }
      },
    );
  }

  Future<void> _onSwitchTopic(
    SwitchTopic event,
    Emitter<SquareState> emit,
  ) async {
    if (state.currentTopic == event.topic) return;

    add(LoadSquarePosts(topic: event.topic));
  }

  Future<void> _onToggleLikePost(
    ToggleLikePost event,
    Emitter<SquareState> emit,
  ) async {
    // 找到需要更新的帖子
    final postIndex = state.posts.indexWhere((post) => post.id == event.postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    final isLiked = !event.isCurrentlyLiked;

    // 乐观更新UI
    final updatedPosts = List<Post>.from(state.posts);
    updatedPosts[postIndex] = post.copyWith(
      isLiked: isLiked,
      likeCount: isLiked ? post.likeCount + 1 : post.likeCount - 1,
    );

    emit(state.copyWith(posts: updatedPosts));

    // 请求服务器
    final result = await _postRepository.likePost(post.id, isLiked);

    result.fold(
      (failure) {
        // 恢复之前的状态
        final revertedPosts = List<Post>.from(state.posts);
        revertedPosts[postIndex] = post;
        emit(
          state.copyWith(
            posts: revertedPosts,
            errorMessage: _mapFailureToMessage(failure),
          ),
        );
      },
      (_) {
        // 服务器请求成功，无需处理
      },
    );
  }

  Future<Either<Failure, List<Post>>> _fetchPosts(
    String topic,
    int page,
    int pageSize,
  ) async {
    if (topic.isEmpty) {
      return _postRepository.getPosts(page, pageSize);
    } else {
      return _postRepository.getPostsByTopic(topic, page, pageSize);
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      default:
        return '发生了未知错误';
    }
  }
}
