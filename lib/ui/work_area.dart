import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';
import '../widgets/container_widget.dart';
import '../ui/widget_panel.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  _WorkAreaState createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  final List<WidgetProperties> widgetPropertiesList = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialWidgetProperties = WidgetProperties(
        id: 'widget_page_01',
        label: 'Initial Widget',
        width: 1200,
        height: 600,
        color: Colors.white,
      );
      widgetPropertiesList.add(initialWidgetProperties);
      context.read<SelectedWidgetModel>().selectWidget(initialWidgetProperties);
    });
  }

  Widget _buildWidgetFromProperties(WidgetProperties props) {
    return Container(
      width: props.width,
      height: props.height,
      color: props.color,
      child: Center(child: Text(props.label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<SelectedWidgetModel>(
        builder: (context, selectedWidgetModel, child) {
          final parentWidgetProperties = selectedWidgetModel.selectedWidgetProperties;
          if (parentWidgetProperties == null) {
            return const Text('위젯이 선택되지 않았습니다.');
          }
          return Container(
            width: parentWidgetProperties.width,
            height: parentWidgetProperties.height,
            decoration: BoxDecoration(
              color: parentWidgetProperties.color,
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text('${parentWidgetProperties.id}: ${parentWidgetProperties.label}'),
                ),
                ...widgetPropertiesList.map((widgetProps) {
                  return Positioned(
                    left: widgetPropertiesList.indexOf(widgetProps) * 110.0,
                    top: widgetPropertiesList.indexOf(widgetProps) * 110.0,
                    child: DragTarget<WidgetItem>(
                      onWillAcceptWithDetails: (details) {
                        return details.data?.label == 'Container';
                      },
                      onAcceptWithDetails: (details) {
                        setState(() {
                          widgetPropertiesList.add(
                            WidgetProperties(
                              id: 'widget_${widgetPropertiesList.length + 1}',
                              label: details.data.label,
                              width: 100,
                              height: 100,
                              color: Colors.blue,
                            ),
                          );
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return GestureDetector(
                          onTap: () {
                            context.read<SelectedWidgetModel>().selectWidget(widgetProps);
                          },
                          child: _buildWidgetFromProperties(widgetProps),
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
