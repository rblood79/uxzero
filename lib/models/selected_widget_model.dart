import 'package:flutter/material.dart';

// 모델 수정
class SelectedWidgetModel extends ChangeNotifier {
  List<WidgetProperties> selectedWidgetProperties = [];

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

  // 선택 상태를 변경할 때는 기존 선택을 초기화하고 새로운 선택을 설정
  void selectWidget(WidgetProperties? properties) {
    if (properties == null) return;

    // 선택된 위젯이 이미 리스트에 있으면 아무 작업도 하지 않음
    if (selectedWidgetProperties.contains(properties)) return;

    // 단일 선택 모드에서는 기존 선택을 지우고 새 선택 추가
    selectedWidgetProperties = [properties];
    notifyListeners();
  }

  // 여러 개의 위젯을 선택할 때 사용 (선택된 위젯 추가)
  void addToSelection(WidgetProperties properties) {
    if (!selectedWidgetProperties.contains(properties)) {
      selectedWidgetProperties.add(properties);
      notifyListeners();
    }
  }

  // 여러 개의 위젯을 선택 해제할 때 사용 (선택 해제)
  void removeFromSelection(WidgetProperties properties) {
    if (selectedWidgetProperties.contains(properties)) {
      selectedWidgetProperties.remove(properties);
      notifyListeners();
    }
  }

  // 모든 선택 해제
  void clearSelection() {
    selectedWidgetProperties.clear();
    notifyListeners();
  }

  // 선택된 위젯들이 부모이거나 자식인지 확인하는 함수
  bool isSelected(WidgetProperties widget) {
    return selectedWidgetProperties.contains(widget);
  }

  // 라벨 업데이트
  void updateLabel(String label) {
    if (selectedWidgetProperties.isNotEmpty) {
      for (var selectedWidget in selectedWidgetProperties) {
        selectedWidget.label = label;
      }
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // 크기 업데이트
  void updateSize(double width, double height) {
    if (selectedWidgetProperties.isNotEmpty) {
      for (var selectedWidget in selectedWidgetProperties) {
        selectedWidget.width = width;
        selectedWidget.height = height;
      }
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // 색상 업데이트
  void updateColor(Color color) {
    if (selectedWidgetProperties.isNotEmpty) {
      for (var selectedWidget in selectedWidgetProperties) {
        selectedWidget.color = color;
      }
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  void updateFontSize(double fontSize) {
    if (selectedWidgetProperties.isNotEmpty) {
      for (var selectedWidget in selectedWidgetProperties) {
        selectedWidget.fontSize = fontSize;
      }
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

// 레이아웃 타입 업데이트
  void updateLayoutType(LayoutType layoutType) {
    if (selectedWidgetProperties.isNotEmpty) {
      for (var selectedWidget in selectedWidgetProperties) {
        selectedWidget.layoutType = layoutType;
      }
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  void updateTextAlign(TextAlign textAlign) {
    if (selectedWidgetProperties.isNotEmpty) {
      for (var selectedWidget in selectedWidgetProperties) {
        print(selectedWidget.textAlign);
         selectedWidget.textAlign = textAlign;
      }
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners(); // 상태 변경 후 알림
    }
  }

  // Flex 속성 업데이트
  void updateFlex(int flex) {
    if (selectedWidgetProperties.isNotEmpty) {
      for (var selectedWidget in selectedWidgetProperties) {
        selectedWidget.flex = flex;
      }
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // MainAxisAlignment 업데이트
  void updateMainAxisAlignment(MainAxisAlignment mainAxisAlignment) {
    if (selectedWidgetProperties.isNotEmpty) {
      for (var selectedWidget in selectedWidgetProperties) {
        selectedWidget.mainAxisAlignment = mainAxisAlignment;
      }
      addToHistory(); // 상태 변경 시 이력에 추가
      notifyListeners();
    }
  }

  // CrossAxisAlignment 업데이트
  void updateCrossAxisAlignment(CrossAxisAlignment alignment,
      [TextBaseline? baseline]) {
    if (selectedWidgetProperties.isNotEmpty) {
      for (var selectedWidget in selectedWidgetProperties) {
        selectedWidget.crossAxisAlignment = alignment;
        if (alignment == CrossAxisAlignment.baseline) {
          selectedWidget.textBaseline = baseline ?? TextBaseline.alphabetic;
        }
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
    if (selectedWidgetProperties.isNotEmpty) {
      for (var selectedWidget in List.from(selectedWidgetProperties)) {
        _deleteWidgetRecursive(rootContainer, selectedWidget);
      }
      clearSelection(); // 삭제 후 선택된 위젯 초기화
      addToHistory(); // 이력 추가
      notifyListeners();
    }
  }

  // 재귀적으로 위젯을 삭제하는 함수
  bool _deleteWidgetRecursive(
      WidgetProperties parent, WidgetProperties target) {
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

  // 텍스트 위젯을 위한 추가 속성
  double? fontSize; // 폰트 크기
  TextAlign? textAlign; // 텍스트 정렬

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
    this.parent,
    this.fontSize, // 텍스트 위젯을 위한 폰트 크기
    this.textAlign, // 텍스트 위젯을 위한 텍스트 정렬
  }) : children = children ?? [];

  // copyWith 메서드에서 부모 참조 및 새로운 속성 처리
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
    double? fontSize, // 추가: 폰트 크기
    TextAlign? textAlign, // 추가: 텍스트 정렬
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
              children.map((child) => child.copyWith(parent: this)))
          : List<WidgetProperties>.from(
              this.children.map((child) => child.copyWith(parent: this))),
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      textBaseline: textBaseline ?? this.textBaseline,
      flex: flex ?? this.flex,
      type: type ?? this.type,
      parent: parent ?? this.parent, // 부모 참조 유지
      fontSize: fontSize ?? this.fontSize, // 추가: 폰트 크기 유지
      textAlign: textAlign ?? this.textAlign, // 추가: 텍스트 정렬 유지
    );
  }

  // JSON serialization 메서드 (추후 확장을 위해 존재)
  toJson() {
    return {
      'id': id,
      'label': label,
      'width': width,
      'height': height,
      'color': color.value,
      'border': border.toString(),
      'x': x,
      'y': y,
      'layoutType': layoutType.toString(),
      'children': children.map((child) => child.toJson()).toList(),
      'mainAxisAlignment': mainAxisAlignment.toString(),
      'crossAxisAlignment': crossAxisAlignment.toString(),
      'textBaseline': textBaseline?.toString(),
      'flex': flex,
      'type': type.toString(),
      'fontSize': fontSize,
      'textAlign': textAlign?.toString(),
    };
  }
}
