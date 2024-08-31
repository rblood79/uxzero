import 'package:flutter/material.dart';

class WidgetProperties {
  String label;
  Color color;
  double width;
  double height;

  WidgetProperties({
    required this.label,
    required this.color,
    required this.width,
    required this.height,
  });
}

class SelectedWidgetModel extends ChangeNotifier {
  WidgetProperties? _selectedWidgetProperties;

  WidgetProperties? get selectedWidgetProperties => _selectedWidgetProperties;

  void selectWidget(WidgetProperties properties) {
    _selectedWidgetProperties = properties;
    notifyListeners();
  }

  void updateLabel(String label) {
    if (_selectedWidgetProperties != null) {
      _selectedWidgetProperties!.label = label;
      notifyListeners();
    }
  }

  void updateColor(Color color) {
    if (_selectedWidgetProperties != null) {
      _selectedWidgetProperties!.color = color;
      notifyListeners();
    }
  }

  void updateSize(double width, double height) {
    if (_selectedWidgetProperties != null) {
      _selectedWidgetProperties!.width = width;
      _selectedWidgetProperties!.height = height;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedWidgetProperties = null;
    notifyListeners();
  }
}
