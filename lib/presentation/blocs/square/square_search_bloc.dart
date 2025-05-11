import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../core/error/failures.dart';
import 'square_search_event.dart';
import 'square_search_state.dart';

class SquareSearchBloc extends Bloc<SquareSearchEvent, SquareSearchState> {
  final PostRepository _postRepository;

  SquareSearchBloc({required PostRepository postRepository})
    : _postRepository = postRepository,
      super(const SquareSearchState()) {
    on<SearchPosts>(_onSearchPosts);
    on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
    on<ClearSearchResults>(_onClearSearchResults);
    on<UpdateSearchKeyword>(_onUpdateSearchKeyword);
  }

  Future<void> _onSearchPosts(
    SearchPosts event,
    Emitter<SquareSearchState> emit,
  ) async {
    if (state.status == SquareSearchStatus.loading) return;
    if (event.keyword.trim().isEmpty) {
      emit(
        state.copyWith(
          searchResults: const [],
          status: SquareSearchStatus.success,
          currentPage: 1,
          hasReachedMax: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SquareSearchStatus.loading,
        keyword: event.keyword,
        currentPage: 1,
        hasReachedMax: false,
      ),
    );

    final result = await _postRepository.searchPosts(
      event.keyword,
      1,
      event.pageSize,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SquareSearchStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ),
      ),
      (posts) => emit(
        state.copyWith(
          status: SquareSearchStatus.success,
          searchResults: posts,
          hasReachedMax: posts.length < event.pageSize,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreSearchResults(
    LoadMoreSearchResults event,
    Emitter<SquareSearchState> emit,
  ) async {
    if (state.hasReachedMax || state.status == SquareSearchStatus.loadMore)
      return;
    if (event.keyword.trim().isEmpty) return;

    emit(state.copyWith(status: SquareSearchStatus.loadMore));

    final nextPage = state.currentPage + 1;
    final result = await _postRepository.searchPosts(
      event.keyword,
      nextPage,
      event.pageSize,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SquareSearchStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ),
      ),
      (posts) {
        if (posts.isEmpty) {
          emit(
            state.copyWith(
              status: SquareSearchStatus.success,
              hasReachedMax: true,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: SquareSearchStatus.success,
            searchResults: [...state.searchResults, ...posts],
            currentPage: nextPage,
            hasReachedMax: posts.length < event.pageSize,
          ),
        );
      },
    );
  }

  void _onClearSearchResults(
    ClearSearchResults event,
    Emitter<SquareSearchState> emit,
  ) {
    emit(
      state.copyWith(
        searchResults: const [],
        status: SquareSearchStatus.initial,
        currentPage: 1,
        hasReachedMax: false,
      ),
    );
  }

  void _onUpdateSearchKeyword(
    UpdateSearchKeyword event,
    Emitter<SquareSearchState> emit,
  ) {
    emit(state.copyWith(keyword: event.keyword));
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
