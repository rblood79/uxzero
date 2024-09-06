import 'package:flutter/material.dart';

class SelectedWidgetModel extends ChangeNotifier {
  WidgetProperties? selectedWidgetProperties;

  void selectWidget(WidgetProperties properties) {
    selectedWidgetProperties = properties;
    notifyListeners(); // 상태 변경을 알림
  }

  void clearSelection() {
    selectedWidgetProperties = null;
    notifyListeners();
  }

  void updateLabel(String label) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.label = label;
      notifyListeners();
    }
  }

  void updateSize(double width, double height) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.width = width;
      selectedWidgetProperties!.height = height;
      notifyListeners();
    }
  }

  void updateColor(Color color) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.color = color;
      notifyListeners();
    }
  }

  void updateLayoutType(LayoutType layoutType) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.layoutType = layoutType;
      notifyListeners();
    }
  }

  // Flex 속성 업데이트 (수정)
  void updateFlex(int flex) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.flex = flex;
      notifyListeners();
    }
  }

  void updateMainAxisAlignment(MainAxisAlignment mainAxisAlignment) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.mainAxisAlignment = mainAxisAlignment;
      notifyListeners();
    }
  }

  void updateCrossAxisAlignment(CrossAxisAlignment alignment,
      [TextBaseline? baseline]) {
    if (selectedWidgetProperties != null) {
      selectedWidgetProperties!.crossAxisAlignment = alignment;
      if (alignment == CrossAxisAlignment.baseline) {
        selectedWidgetProperties!.textBaseline =
            baseline ?? TextBaseline.alphabetic;
      }
      notifyListeners();
    }
  }
}

enum LayoutType { container, row, column, stack }

enum WidgetType {
  container,
  text,
}

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
}
