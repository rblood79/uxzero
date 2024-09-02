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

  void _updateControllers(WidgetProperties selectedWidget) {
    final currentLabel = labelController.text;
    final currentWidth = widthController.text;
    final currentHeight = heightController.text;

    if (currentLabel != selectedWidget.label) {
      labelController.text = selectedWidget.label;
      labelController.selection = TextSelection.fromPosition(
        TextPosition(offset: labelController.text.length),
      );
    }

    if (currentWidth != selectedWidget.width.toString()) {
      widthController.text = selectedWidget.width.toString();
      widthController.selection = TextSelection.fromPosition(
        TextPosition(offset: widthController.text.length),
      );
    }

    if (currentHeight != selectedWidget.height.toString()) {
      heightController.text = selectedWidget.height.toString();
      heightController.selection = TextSelection.fromPosition(
        TextPosition(offset: heightController.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 228,
      child: Container(
        color: Colors.red,
        padding: const EdgeInsets.all(8.0),
        child: Consumer<SelectedWidgetModel>(
          builder: (context, selectedWidgetModel, child) {
            final selectedWidget = selectedWidgetModel.selectedWidgetProperties;

            if (selectedWidget == null) {
              return const Text('위젯을 선택하세요');
            }

            _updateControllers(selectedWidget);  // 이곳에서 컨트롤러 업데이트

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                  ),
                  onChanged: (value) {
                    selectedWidgetModel.updateLabel(value);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Color:'),
                    const SizedBox(width: 10),
                    Container(
                      width: 50,
                      height: 50,
                      color: selectedWidget.color,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: widthController,
                  decoration: const InputDecoration(
                    labelText: 'Width',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newWidth = double.tryParse(value) ?? selectedWidget.width;
                    selectedWidgetModel.updateSize(newWidth, selectedWidget.height);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newHeight = double.tryParse(value) ?? selectedWidget.height;
                    selectedWidgetModel.updateSize(selectedWidget.width, newHeight);
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    selectedWidgetModel.clearSelection();
                  },
                  child: const Text('Clear Selection'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
