import 'package:equatable/equatable.dart';
import 'package:text_sphere_app/domain/entities/post.dart';

enum SquareSearchStatus { initial, loading, loadMore, success, failure }

class SquareSearchState extends Equatable {
  final SquareSearchStatus status;
  final List<Post> searchResults;
  final String keyword;
  final bool hasReachedMax;
  final String errorMessage;
  final int currentPage;

  const SquareSearchState({
    this.status = SquareSearchStatus.initial,
    this.searchResults = const [],
    this.keyword = '',
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.currentPage = 1,
  });

  SquareSearchState copyWith({
    SquareSearchStatus? status,
    List<Post>? searchResults,
    String? keyword,
    bool? hasReachedMax,
    String? errorMessage,
    int? currentPage,
  }) {
    return SquareSearchState(
      status: status ?? this.status,
      searchResults: searchResults ?? this.searchResults,
      keyword: keyword ?? this.keyword,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    searchResults,
    keyword,
    hasReachedMax,
    errorMessage,
    currentPage,
  ];
}
