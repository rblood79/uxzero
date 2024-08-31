import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  _WorkAreaState createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.grey[200],
        child: Center(
          child: Consumer<SelectedWidgetModel>(
            builder: (context, selectedWidgetModel, child) {
              return Container(
                width: 1200,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildColorBox(
                        context,
                        WidgetProperties(
                          label: 'Red Box',
                          color: Colors.red,
                          width: 100,
                          height: 100,
                        ),
                        selectedWidgetModel.selectedWidgetProperties,
                      ),
                      const SizedBox(height: 10),
                      _buildColorBox(
                        context,
                        WidgetProperties(
                          label: 'Blue Box',
                          color: Colors.blue,
                          width: 100,
                          height: 100,
                        ),
                        selectedWidgetModel.selectedWidgetProperties,
                      ),
                      const SizedBox(height: 10),
                      _buildColorBox(
                        context,
                        WidgetProperties(
                          label: 'Yellow Box',
                          color: Colors.yellow,
                          width: 100,
                          height: 100,
                        ),
                        selectedWidgetModel.selectedWidgetProperties,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColorBox(BuildContext context, WidgetProperties properties, WidgetProperties? selectedProperties) {
    final isSelected = properties.label == selectedProperties?.label;
    return GestureDetector(
      onTap: () {
        context.read<SelectedWidgetModel>().selectWidget(properties);
      },
      child: Container(
        width: isSelected ? selectedProperties!.width : properties.width,
        height: isSelected ? selectedProperties!.height : properties.height,
        color: isSelected ? selectedProperties!.color : properties.color,
        child: Center(
          child: Text(
            isSelected ? selectedProperties!.label : properties.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
