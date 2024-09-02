import 'package:flutter/material.dart';

class SelectedWidgetModel extends ChangeNotifier {
  WidgetProperties? selectedWidgetProperties;

  void selectWidget(WidgetProperties properties) {
    selectedWidgetProperties = properties;
    notifyListeners();
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
}

class WidgetProperties {
  String id;  // 고유 식별자
  String label;
  double width;
  double height;
  Color color;

  WidgetProperties({
    required this.id,
    required this.label,
    required this.width,
    required this.height,
    required this.color,
  });
}
