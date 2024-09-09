import 'package:flutter/material.dart';

class SelectedWidgetModel extends ChangeNotifier {
  WidgetProperties? selectedWidgetProperties;

  // 상태 이력을 저장할 리스트 및 현재 이력 인덱스
  final List<WidgetProperties> _history = [];
  int _historyIndex = -1;

  // 위젯을 선택하고 상태 이력에 추가
  void selectWidget(WidgetProperties properties) {
    selectedWidgetProperties = properties;
    addToHistory(); // 선택 시 이력에 추가
    notifyListeners(); // 상태 변경을 알림
  }

  // 선택 취소
  void clearSelection() {
    selectedWidgetProperties = null;
    notifyListeners();
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
  void updateCrossAxisAlignment(CrossAxisAlignment alignment,
      [TextBaseline? baseline]) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.crossAxisAlignment = alignment;
      if (alignment == CrossAxisAlignment.baseline) {
        selectedWidgetProperties!.textBaseline =
            baseline ?? TextBaseline.alphabetic;
      }
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // 퍼블릭 메서드: 상태 변경 시 이력에 추가
  void addToHistory() {
    _addToHistory(); // 내부 프라이빗 메서드 호출
  }

  // 상태 변경 시 이력을 추가하는 프라이빗 메서드
  void _addToHistory() {
    // 현재 상태를 복사하여 이력에 추가
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(selectedWidgetProperties!.copyWith());
    _historyIndex++;
  }

  // Undo 기능: 이전 상태로 복원
  void undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      selectedWidgetProperties = _history[_historyIndex].copyWith();
      notifyListeners();
    }
  }

  // Redo 기능: 다음 상태로 복원
  void redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      selectedWidgetProperties = _history[_historyIndex].copyWith();
      notifyListeners();
    }
  }
}


enum LayoutType { container, row, column, stack }

enum WidgetType {
  container,
  text,
}

// WidgetProperties 클래스
class WidgetProperties {
  final String id; // 위젯을 구분할 고유 식별자
  String label; // 위젯 레이블
  double width; // 위젯 너비
  double height; // 위젯 높이
  Color color; // 위젯 색상
  Border border; // 테두리 설정
  double x; // 위젯의 X 좌표
  double y; // 위젯의 Y 좌표
  LayoutType layoutType;
  List<WidgetProperties> children; // 자식 컨테이너 리스트 추가
  MainAxisAlignment mainAxisAlignment; // MainAxisAlignment 추가
  CrossAxisAlignment crossAxisAlignment; //CrossAxisAlignment 추가
  TextBaseline? textBaseline; // 텍스트 기준선 속성 추가
  int flex; // Flex 속성 추가
  WidgetType type; // 위젯의 타입을 구분하는 속성 추가

  WidgetProperties({
    required this.id,
    required this.label,
    required this.width,
    required this.height,
    required this.color,
    required this.border, // 테두리 추가
    required this.x,
    required this.y,
    required this.layoutType,
    this.mainAxisAlignment = MainAxisAlignment.start, // 기본값
    this.crossAxisAlignment = CrossAxisAlignment.start, // 기본값
    this.textBaseline, // 선택적 기준선 속성
    this.flex = 0, // 기본값
    this.type = WidgetType.container, // 기본값은 container로 설정
    List<WidgetProperties>? children, // 선택적 매개변수로 설정
  }) : children = children ?? []; // children이 null일 경우 빈 리스트로 초기화

  // 객체 복사 메서드
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
      children: children ?? List.from(this.children), // 리스트 복사
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      textBaseline: textBaseline ?? this.textBaseline,
      flex: flex ?? this.flex,
      type: type ?? this.type,
    );
  }
}
