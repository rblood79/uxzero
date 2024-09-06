import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';

class PropertyPanel extends StatefulWidget {
  const PropertyPanel({super.key});

  @override
  _PropertyPanelState createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  late TextEditingController labelController;
  late TextEditingController widthController;
  late TextEditingController heightController;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController();
    widthController = TextEditingController();
    heightController = TextEditingController();
  }

  @override
  void dispose() {
    labelController.dispose();
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void updateControllers(WidgetProperties selectedWidget) {
    if (labelController.text != selectedWidget.label) {
      labelController.text = selectedWidget.label;
    }
    if (widthController.text != selectedWidget.width.toString()) {
      widthController.text = selectedWidget.width.toString();
    }
    if (heightController.text != selectedWidget.height.toString()) {
      heightController.text = selectedWidget.height.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Consumer<SelectedWidgetModel>(
        builder: (context, selectedWidgetModel, child) {
          final selectedWidget = selectedWidgetModel.selectedWidgetProperties;
          if (selectedWidget == null) {
            return const Text('위젯을 선택하세요');
          }

          // 컨트롤러 업데이트
          updateControllers(selectedWidget);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Label',
                ),
                controller: labelController,
                onChanged: (value) {
                  selectedWidgetModel.updateLabel(value);
                },
              ),
              const SizedBox(height: 10),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Width',
                ),
                keyboardType: TextInputType.number,
                controller: widthController,
                onChanged: (value) {
                  final newWidth =
                      double.tryParse(value) ?? selectedWidget.width;
                  selectedWidgetModel.updateSize(
                      newWidth, selectedWidget.height);
                },
              ),
              const SizedBox(height: 10),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Height',
                ),
                keyboardType: TextInputType.number,
                controller: heightController,
                onChanged: (value) {
                  final newHeight =
                      double.tryParse(value) ?? selectedWidget.height;
                  selectedWidgetModel.updateSize(
                      selectedWidget.width, newHeight);
                },
              ),
              const SizedBox(height: 10),

              DropdownButton<Color>(
                value: <Color>[
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow
                ].contains(selectedWidget.color)
                    ? selectedWidget.color
                    : Colors.red, // 기본값을 설정하거나 null 상태를 처리합니다.
                items: <Color>[
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow
                ].map((Color color) {
                  return DropdownMenuItem<Color>(
                    value: color,
                    child: Container(
                      width: 100,
                      height: 20,
                      color: color,
                    ),
                  );
                }).toList(),
                onChanged: (Color? newColor) {
                  if (newColor != null) {
                    selectedWidgetModel.updateColor(newColor);
                  }
                },
              ),
              const SizedBox(height: 10),

              DropdownButton<LayoutType>(
                value: selectedWidget.layoutType,
                items: LayoutType.values.map((layoutType) {
                  return DropdownMenuItem<LayoutType>(
                    value: layoutType,
                    child: Text(layoutType
                        .toString()
                        .split('.')
                        .last), // LayoutType 열거형을 문자열로 변환
                  );
                }).toList(),
                onChanged: (LayoutType? newLayoutType) {
                  if (newLayoutType != null) {
                    selectedWidgetModel.updateLayoutType(newLayoutType);
                  }
                },
              ),

              DropdownButton<MainAxisAlignment>(
                value: selectedWidget.mainAxisAlignment,
                items: MainAxisAlignment.values.map((alignment) {
                  return DropdownMenuItem(
                    value: alignment,
                    child: Text(alignment.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedWidgetModel.updateMainAxisAlignment(
                        value); // MainAxisAlignment 업데이트
                  }
                },
              ),

              DropdownButton<CrossAxisAlignment>(
                value: selectedWidget.crossAxisAlignment,
                items: CrossAxisAlignment.values.where((alignment) {
                  // 텍스트가 포함된 경우에만 baseline을 표시
                  if (alignment == CrossAxisAlignment.baseline &&
                      !_hasTextWidget(selectedWidget)) {
                    return false; // 텍스트가 없는 경우 baseline을 숨김
                  }
                  return true; // 나머지 정렬 옵션은 항상 표시
                }).map((alignment) {
                  return DropdownMenuItem(
                    value: alignment,
                    child: Text(alignment.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedWidgetModel.updateCrossAxisAlignment(
                        value,
                        value == CrossAxisAlignment.baseline
                            ? TextBaseline.alphabetic
                            : null);
                  }
                },
              ),

              const SizedBox(height: 10),
              // Flex 업데이트 (Slider 사용)
              Text("Flex: ${selectedWidget.flex}"),
              Slider(
                min: 0,
                max: 10,
                value: selectedWidget.flex.toDouble(),
                onChanged: (value) {
                  selectedWidgetModel.updateFlex(value.toInt()); // Flex 업데이트
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

bool _hasTextWidget(WidgetProperties widget) {
  // 현재 위젯이 텍스트를 포함하는지 확인
  if (widget.layoutType == LayoutType.container && widget.children.isNotEmpty) {
    for (var child in widget.children) {
      // 자식 중 텍스트가 포함된 위젯이 있는지 확인
      if (_hasTextWidget(child)) {
        return true;
      }
    }
  }

  // 텍스트 위젯이 있으면 true 반환, 없으면 false 반환
  return widget.label.contains('Text') || widget.label.contains('Label');
}
