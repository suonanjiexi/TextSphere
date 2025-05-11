import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/post_repository.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/comment.dart';
import 'post_detail_event.dart';
import 'post_detail_state.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final PostRepository _postRepository;

  // 当前用户ID (模拟，实际应该从用户服务获取)
  final String _currentUserId = 'current_user_id';

  PostDetailBloc({required PostRepository postRepository})
    : _postRepository = postRepository,
      super(PostDetailInitial()) {
    on<LoadPostDetail>(_onLoadPostDetail);
    on<ToggleLike>(_onToggleLike);
    on<ToggleCollect>(_onToggleCollect);
    on<ToggleFollowAuthor>(_onToggleFollowAuthor);
    on<ToggleLikeComment>(_onToggleLikeComment);
    on<SetReplyTo>(_onSetReplyTo);
    on<ClearReplyTo>(_onClearReplyTo);
    on<SetCommentText>(_onSetCommentText);
    on<SubmitComment>(_onSubmitComment);
    on<DeletePost>(_onDeletePost);
  }

  Future<void> _onLoadPostDetail(
    LoadPostDetail event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(PostDetailLoading());

    final result = await _postRepository.getPostDetail(event.postId);
    await result.fold(
      (failure) async {
        emit(PostDetailError(_mapFailureToMessage(failure)));
      },
      (post) async {
        // 加载成功后，再加载评论
        emit(PostDetailLoaded(post: post, isLoadingComments: true));

        final commentsResult = await _postRepository.getComments(
          event.postId,
          1,
          20,
        );
        commentsResult.fold(
          (failure) {
            // 评论加载失败，但帖子已加载成功
            if (state is PostDetailLoaded) {
              emit(
                (state as PostDetailLoaded).copyWith(isLoadingComments: false),
              );
            }
          },
          (comments) {
            if (state is PostDetailLoaded) {
              emit(
                (state as PostDetailLoaded).copyWith(
                  comments: comments,
                  isLoadingComments: false,
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _onToggleLike(
    ToggleLike event,
    Emitter<PostDetailState> emit,
  ) async {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      final post = currentState.post;
      final isLiked = !post.isLiked;

      // 乐观更新UI
      emit(
        currentState.copyWith(
          post: post.copyWith(
            isLiked: isLiked,
            likeCount: isLiked ? post.likeCount + 1 : post.likeCount - 1,
          ),
        ),
      );

      // 请求服务器
      final result = await _postRepository.likePost(post.id, isLiked);
      result.fold(
        (failure) {
          // 恢复之前的状态
          emit(currentState.copyWith(post: post));
        },
        (_) {
          // 服务器请求成功，无需处理
        },
      );
    }
  }

  void _onToggleCollect(ToggleCollect event, Emitter<PostDetailState> emit) {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      emit(currentState.copyWith(isCollected: !currentState.isCollected));
    }
  }

  void _onToggleFollowAuthor(
    ToggleFollowAuthor event,
    Emitter<PostDetailState> emit,
  ) {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      emit(
        currentState.copyWith(
          isFollowingAuthor: !currentState.isFollowingAuthor,
        ),
      );
    }
  }

  void _onToggleLikeComment(
    ToggleLikeComment event,
    Emitter<PostDetailState> emit,
  ) {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      final index = currentState.comments.indexWhere(
        (c) => c.id == event.commentId,
      );

      if (index == -1) return;

      final comment = currentState.comments[index];
      final isLiked = !comment.isLiked;
      final updatedComments = List<Comment>.from(currentState.comments);
      updatedComments[index] = comment.copyWith(
        isLiked: isLiked,
        likeCount: isLiked ? comment.likeCount + 1 : comment.likeCount - 1,
      );

      emit(currentState.copyWith(comments: updatedComments));
    }
  }

  void _onSetReplyTo(SetReplyTo event, Emitter<PostDetailState> emit) {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      emit(currentState.copyWith(replyTo: event.comment));
    }
  }

  void _onClearReplyTo(ClearReplyTo event, Emitter<PostDetailState> emit) {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      emit(currentState.copyWith(clearReplyTo: true));
    }
  }

  void _onSetCommentText(SetCommentText event, Emitter<PostDetailState> emit) {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      emit(currentState.copyWith(commentText: event.text));
    }
  }

  Future<void> _onSubmitComment(
    SubmitComment event,
    Emitter<PostDetailState> emit,
  ) async {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      final commentText = currentState.commentText.trim();

      if (commentText.isEmpty) return;

      emit(currentState.copyWith(isSubmittingComment: true));

      // 实现评论提交逻辑，这里只是模拟
      final DateTime now = DateTime.now();
      final newComment = Comment(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        postId: currentState.post.id,
        userId: _currentUserId,
        username: 'CurrentUser',
        userAvatar: 'https://i.pravatar.cc/150?u=currentUser',
        content: commentText,
        parentId: currentState.replyTo?.id,
        replyToUserId: currentState.replyTo?.userId,
        replyToUsername: currentState.replyTo?.username,
        createdAt: now,
        likeCount: 0,
      );

      // 更新状态
      final updatedComments = [newComment, ...currentState.comments];
      final updatedPost = currentState.post.copyWith(
        commentCount: currentState.post.commentCount + 1,
      );

      emit(
        currentState.copyWith(
          post: updatedPost,
          comments: updatedComments,
          commentText: '',
          clearReplyTo: true,
          isSubmittingComment: false,
        ),
      );
    }
  }

  Future<void> _onDeletePost(
    DeletePost event,
    Emitter<PostDetailState> emit,
  ) async {
    if (state is PostDetailLoaded) {
      final currentState = state as PostDetailLoaded;
      emit(currentState.copyWith(isDeletingPost: true));

      final result = await _postRepository.deletePost(currentState.post.id);
      result.fold(
        (failure) {
          emit(currentState.copyWith(isDeletingPost: false));
        },
        (success) {
          if (success) {
            emit(PostDeleted());
          } else {
            emit(currentState.copyWith(isDeletingPost: false));
          }
        },
      );
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
