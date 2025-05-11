import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_sphere_app/domain/entities/circle.dart';
import 'package:text_sphere_app/domain/repositories/circle_repository.dart';
import 'package:text_sphere_app/presentation/blocs/circle/circle_event.dart';
import 'package:text_sphere_app/presentation/blocs/circle/circle_state.dart';

/// 圈子Bloc，处理圈子相关的状态管理
class CircleBloc extends Bloc<CircleEvent, CircleState> {
  final CircleRepository repository;

  CircleBloc({required this.repository}) : super(const CircleState()) {
    on<LoadJoinedCircles>(_onLoadJoinedCircles);
    on<LoadRecommendedCircles>(_onLoadRecommendedCircles);
    on<LoadCategorizedCircles>(_onLoadCategorizedCircles);
    on<SearchCircles>(_onSearchCircles);
    on<JoinCircle>(_onJoinCircle);
    on<LeaveCircle>(_onLeaveCircle);
    on<CreateCircle>(_onCreateCircle);
  }

  void _onLoadJoinedCircles(
    LoadJoinedCircles event,
    Emitter<CircleState> emit,
  ) async {
    emit(state.copyWith(status: CircleStatus.loading));

    final result = await repository.getJoinedCircles();

    result.fold(
      (failure) => emit(
        state.copyWith(status: CircleStatus.failure, errorMessage: '加载失败'),
      ),
      (circles) => emit(
        state.copyWith(
          status: CircleStatus.success,
          circles: circles,
          activeTab: CircleTab.joined,
        ),
      ),
    );
  }

  void _onLoadRecommendedCircles(
    LoadRecommendedCircles event,
    Emitter<CircleState> emit,
  ) async {
    emit(state.copyWith(status: CircleStatus.loading));

    final result = await repository.getRecommendedCircles();

    result.fold(
      (failure) => emit(
        state.copyWith(status: CircleStatus.failure, errorMessage: '加载失败'),
      ),
      (circles) => emit(
        state.copyWith(
          status: CircleStatus.success,
          circles: circles,
          activeTab: CircleTab.recommended,
        ),
      ),
    );
  }

  void _onLoadCategorizedCircles(
    LoadCategorizedCircles event,
    Emitter<CircleState> emit,
  ) async {
    emit(state.copyWith(status: CircleStatus.loading));

    final result = await repository.getCategorizedCircles(event.category);

    result.fold(
      (failure) => emit(
        state.copyWith(status: CircleStatus.failure, errorMessage: '加载失败'),
      ),
      (circles) => emit(
        state.copyWith(
          status: CircleStatus.success,
          circles: circles,
          activeTab: CircleTab.category,
          category: event.category,
        ),
      ),
    );
  }

  void _onSearchCircles(SearchCircles event, Emitter<CircleState> emit) async {
    if (event.keyword.isEmpty) {
      // 如果搜索关键词为空，加载推荐圈子
      add(const LoadRecommendedCircles());
      return;
    }

    emit(state.copyWith(status: CircleStatus.loading));

    final result = await repository.searchCircles(event.keyword);

    result.fold(
      (failure) => emit(
        state.copyWith(status: CircleStatus.failure, errorMessage: '搜索失败'),
      ),
      (circles) => emit(
        state.copyWith(
          status: CircleStatus.success,
          circles: circles,
          activeTab: CircleTab.search,
          searchKeyword: event.keyword,
        ),
      ),
    );
  }

  void _onJoinCircle(JoinCircle event, Emitter<CircleState> emit) async {
    final result = await repository.joinCircle(event.circleId);

    result.fold(
      (failure) => emit(
        state.copyWith(status: CircleStatus.failure, errorMessage: '加入失败'),
      ),
      (success) {
        // 更新列表中的圈子
        final updatedCircles =
            state.circles.map((circle) {
              if (circle.id == event.circleId) {
                return circle.copyWith(isJoined: true);
              }
              return circle;
            }).toList();

        emit(state.copyWith(circles: updatedCircles));
      },
    );
  }

  void _onLeaveCircle(LeaveCircle event, Emitter<CircleState> emit) async {
    final result = await repository.leaveCircle(event.circleId);

    result.fold(
      (failure) => emit(
        state.copyWith(status: CircleStatus.failure, errorMessage: '退出失败'),
      ),
      (success) {
        // 更新列表中的圈子
        final updatedCircles =
            state.circles.map((circle) {
              if (circle.id == event.circleId) {
                return circle.copyWith(isJoined: false);
              }
              return circle;
            }).toList();

        // 如果当前是已加入的圈子页面，则应该移除该圈子
        final List<Circle> finalCircles =
            state.activeTab == CircleTab.joined
                ? updatedCircles.where((circle) => circle.isJoined).toList()
                : updatedCircles;

        emit(state.copyWith(circles: finalCircles));
      },
    );
  }

  void _onCreateCircle(CreateCircle event, Emitter<CircleState> emit) async {
    emit(state.copyWith(status: CircleStatus.loading));

    final result = await repository.createCircle(
      name: event.name,
      description: event.description,
      category: event.category,
      tags: event.tags,
      avatarUrl: event.avatarUrl,
      coverUrl: event.coverUrl,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: CircleStatus.failure, errorMessage: '创建圈子失败'),
      ),
      (newCircle) {
        // 如果当前在"我的圈子"选项卡，则添加新创建的圈子到列表中
        if (state.activeTab == CircleTab.joined) {
          final updatedCircles = List<Circle>.from(state.circles)
            ..add(newCircle);
          emit(
            state.copyWith(
              status: CircleStatus.success,
              circles: updatedCircles,
            ),
          );
        } else {
          // 切换到"我的圈子"选项卡并加载
          add(const LoadJoinedCircles());
        }
      },
    );
  }
}
