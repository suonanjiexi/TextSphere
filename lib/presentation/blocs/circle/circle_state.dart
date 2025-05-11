import 'package:equatable/equatable.dart';
import 'package:text_sphere_app/domain/entities/circle.dart';

/// 圈子状态枚举
enum CircleStatus { initial, loading, success, failure }

/// 圈子选项卡枚举
enum CircleTab { joined, recommended, category, search }

/// 圈子状态类
class CircleState extends Equatable {
  final CircleStatus status;
  final List<Circle> circles;
  final CircleTab activeTab;
  final String category;
  final String searchKeyword;
  final String errorMessage;

  const CircleState({
    this.status = CircleStatus.initial,
    this.circles = const [],
    this.activeTab = CircleTab.recommended,
    this.category = '',
    this.searchKeyword = '',
    this.errorMessage = '',
  });

  CircleState copyWith({
    CircleStatus? status,
    List<Circle>? circles,
    CircleTab? activeTab,
    String? category,
    String? searchKeyword,
    String? errorMessage,
  }) {
    return CircleState(
      status: status ?? this.status,
      circles: circles ?? this.circles,
      activeTab: activeTab ?? this.activeTab,
      category: category ?? this.category,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
    status,
    circles,
    activeTab,
    category,
    searchKeyword,
    errorMessage,
  ];
}
