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

              const SizedBox(height: 20),
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
