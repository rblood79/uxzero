import 'package:flutter/material.dart';

class SelectedWidgetModel extends ChangeNotifier {
  WidgetProperties? selectedWidgetProperties;

  // rootContainer를 상태로 관리
  WidgetProperties rootContainer = WidgetProperties(
    id: 'page_01',
    label: 'Container_01',
    width: 1200,
    height: 600,
    color: Colors.white,
    x: 0,
    y: 0,
    border: Border.all(
      color: Colors.black,
      width: 1.0,
    ),
    layoutType: LayoutType.row,
    children: [],
  );

  // 상태 이력을 저장할 리스트 및 현재 이력 인덱스
  final List<WidgetProperties> _history = [];
  int _historyIndex = -1;

  // 선택 상태를 변경할 때는 항상 기존 선택을 초기화하고 새로운 선택을 설정
  void selectWidget(WidgetProperties? properties) {
    // 이미 선택된 상태에서 동일한 위젯이 선택되면 아무 작업도 하지 않음
    if (selectedWidgetProperties == properties) return;

    // 선택된 위젯 초기화
    selectedWidgetProperties = properties;
    notifyListeners();
  }

  // 선택된 위젯을 초기화 (선택 해제)
  void clearSelection() {
    selectedWidgetProperties = null;
    notifyListeners();
  }

  // 선택된 위젯이 부모이거나 자식인지 확인하는 함수
  bool isSelected(WidgetProperties widget) {
    return selectedWidgetProperties == widget;
  }
  
  // 라벨 업데이트
  void updateLabel(String label) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.label = label;
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // 크기 업데이트
  void updateSize(double width, double height) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.width = width;
      selectedWidgetProperties!.height = height;
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // 색상 업데이트
  void updateColor(Color color) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.color = color;
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // 레이아웃 타입 업데이트
  void updateLayoutType(LayoutType layoutType) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.layoutType = layoutType;
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // Flex 속성 업데이트
  void updateFlex(int flex) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.flex = flex;
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // MainAxisAlignment 업데이트
  void updateMainAxisAlignment(MainAxisAlignment mainAxisAlignment) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.mainAxisAlignment = mainAxisAlignment;
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // CrossAxisAlignment 업데이트
  void updateCrossAxisAlignment(CrossAxisAlignment alignment, [TextBaseline? baseline]) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.crossAxisAlignment = alignment;
      if (alignment == CrossAxisAlignment.baseline) {
        selectedWidgetProperties!.textBaseline = baseline ?? TextBaseline.alphabetic;
      }
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // 이력 추가 및 깊은 복사 보장
  void addToHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(rootContainer.copyWith()); // 현재 상태를 복사하여 이력에 추가
    _historyIndex++;
    notifyListeners(); // 상태 변경 알림
  }

  // Undo 가능한지 여부
  bool get canUndo => _historyIndex > 0;

  // Redo 가능한지 여부
  bool get canRedo => _historyIndex < _history.length - 1;

  // Undo 기능
  void undo() {
    if (canUndo) {
      _historyIndex--;
      rootContainer = _history[_historyIndex].copyWith();
      notifyListeners();
    }
  }

  // Redo 기능
  void redo() {
    if (canRedo) {
      _historyIndex++;
      rootContainer = _history[_historyIndex].copyWith();
      notifyListeners();
    }
  }

  // 선택된 위젯 삭제
  void deleteSelectedWidget() {
    if (selectedWidgetProperties != null) {
      _deleteWidgetRecursive(rootContainer, selectedWidgetProperties!);
      selectedWidgetProperties = null; // 삭제 후 선택된 위젯 초기화
      addToHistory(); // 이력 추가
      notifyListeners();
    }
  }

  // 재귀적으로 위젯을 삭제하는 함수
  bool _deleteWidgetRecursive(WidgetProperties parent, WidgetProperties target) {
    if (parent.children.contains(target)) {
      parent.children.remove(target);
      return true;
    } else {
      for (var child in parent.children) {
        if (_deleteWidgetRecursive(child, target)) {
          return true;
        }
      }
    }
    return false;
  }
}

// LayoutType 열거형
enum LayoutType {
  container,
  row,
  column,
  stack,
  grid,
  wrap,
  list,
}

// WidgetType 열거형
enum WidgetType {
  container,
  text,
}

// WidgetProperties 클래스
class WidgetProperties {
  final String id;
  String label;
  double width;
  double height;
  Color color;
  Border border;
  double x;
  double y;
  LayoutType layoutType;
  List<WidgetProperties> children;
  MainAxisAlignment mainAxisAlignment;
  CrossAxisAlignment crossAxisAlignment;
  TextBaseline? textBaseline;
  int flex;
  WidgetType type;
  WidgetProperties? parent; // 부모 참조 필드 추가

  WidgetProperties({
    required this.id,
    required this.label,
    required this.width,
    required this.height,
    required this.color,
    required this.border,
    required this.x,
    required this.y,
    required this.layoutType,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textBaseline,
    this.flex = 0,
    this.type = WidgetType.container,
    List<WidgetProperties>? children,
    this.parent, // 부모 초기화
  }) : children = children ?? [];

  // copyWith 메서드에서 부모 참조 처리
  WidgetProperties copyWith({
    String? id,
    String? label,
    double? width,
    double? height,
    Color? color,
    Border? border,
    double? x,
    double? y,
    LayoutType? layoutType,
    List<WidgetProperties>? children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    TextBaseline? textBaseline,
    int? flex,
    WidgetType? type,
    WidgetProperties? parent, // 부모 참조 copyWith에 추가
  }) {
    return WidgetProperties(
      id: id ?? this.id,
      label: label ?? this.label,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      border: border ?? this.border,
      x: x ?? this.x,
      y: y ?? this.y,
      layoutType: layoutType ?? this.layoutType,
      children: children != null
          ? List<WidgetProperties>.from(
              children.map((child) => child.copyWith(parent: this))) // 자식에게 부모 참조 설정
          : List<WidgetProperties>.from(
              this.children.map((child) => child.copyWith(parent: this))), // 자식에게 부모 참조 유지
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      textBaseline: textBaseline ?? this.textBaseline,
      flex: flex ?? this.flex,
      type: type ?? this.type,
      parent: parent ?? this.parent, // 부모 참조 유지
    );
  }

  // JSON serialization 메서드 (추후 확장을 위해 존재)
  toJson() {}
}

