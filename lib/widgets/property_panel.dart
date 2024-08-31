import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';

class PropertyPanel extends StatelessWidget {
  const PropertyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 228,
      child: Container(
        color: Colors.black12,
        padding: const EdgeInsets.all(8.0),
        child: Consumer<SelectedWidgetModel>(
          builder: (context, selectedWidgetModel, child) {
            final selectedWidget = selectedWidgetModel.selectedWidgetProperties;

            if (selectedWidget == null) {
              return const Text('위젯을 선택하세요');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Label',
                    hintText: selectedWidget.label,
                  ),
                  onChanged: (value) {
                    context.read<SelectedWidgetModel>().updateLabel(value);
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
                  decoration: InputDecoration(
                    labelText: 'Width',
                    hintText: selectedWidget.width.toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newWidth = double.tryParse(value) ?? selectedWidget.width;
                    context.read<SelectedWidgetModel>().updateSize(newWidth, selectedWidget.height);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Height',
                    hintText: selectedWidget.height.toString(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newHeight = double.tryParse(value) ?? selectedWidget.height;
                    context.read<SelectedWidgetModel>().updateSize(selectedWidget.width, newHeight);
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    context.read<SelectedWidgetModel>().clearSelection();
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
