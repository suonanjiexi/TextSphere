import 'package:equatable/equatable.dart';
import 'package:text_sphere_app/domain/entities/post.dart';

enum SquareStatus { initial, loading, loadMore, success, failure }

class SquareState extends Equatable {
  final SquareStatus status;
  final List<Post> posts;
  final String currentTopic;
  final bool hasReachedMax;
  final String errorMessage;
  final int currentPage;

  const SquareState({
    this.status = SquareStatus.initial,
    this.posts = const [],
    this.currentTopic = '',
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.currentPage = 1,
  });

  SquareState copyWith({
    SquareStatus? status,
    List<Post>? posts,
    String? currentTopic,
    bool? hasReachedMax,
    String? errorMessage,
    int? currentPage,
  }) {
    return SquareState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      currentTopic: currentTopic ?? this.currentTopic,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    posts,
    currentTopic,
    hasReachedMax,
    errorMessage,
    currentPage,
  ];
}
