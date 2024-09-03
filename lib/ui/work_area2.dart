import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';
import 'widget_panel.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  _WorkAreaState createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  final List<WidgetProperties> widgetPropertiesList = [];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Center(
      child: Consumer<SelectedWidgetModel>(
        builder: (context, selectedWidgetModel, child) {
          return Container(
            width: 1200,
            height: 600,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Stack(
              children: [
                ...widgetPropertiesList.map((widgetProps) {
                  return Positioned(
                    left: widgetProps.x,
                    top: widgetProps.y,
                    child: GestureDetector(
                      onTap: () {
                        // 드래그 앤 드롭으로 추가된 위젯 선택
                        context
                            .read<SelectedWidgetModel>()
                            .selectWidget(widgetProps);
                      },
                      child: _buildWidgetFromProperties(widgetProps),
                    ),
                  );
                }).toList(),
                DragTarget<WidgetItem>(
                  onWillAcceptWithDetails: (details) {
                    // Container 위젯만 드롭 허용
                    return details.data.label == 'Container';
                  },
                  onAcceptWithDetails: (details) {
                    setState(() {
                      final renderBox = context.findRenderObject() as RenderBox;
                      final localPosition =
                          renderBox.globalToLocal(details.offset);

                      final newWidgetProps = WidgetProperties(
                        id: 'widget_${widgetPropertiesList.length + 1}',
                        label: details.data.label,
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                        x: localPosition.dx,
                        y: localPosition.dy,
                      );
                      widgetPropertiesList.add(newWidgetProps);
                      // 새로 추가된 위젯 선택
                      context
                          .read<SelectedWidgetModel>()
                          .selectWidget(newWidgetProps);
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: screenSize.width,
                      height: screenSize.height,
                      color: Colors.transparent,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWidgetFromProperties(WidgetProperties props) {
    switch (props.layoutType) {
      case LayoutType.row:
        return Container(
          width: props.width,
          height: props.height,
          color: props.color,
          child: Row(
            children: [Text(props.label)],
          ),
        );
      case LayoutType.column:
        return Container(
          width: props.width,
          height: props.height,
          color: props.color,
          child: Column(
            children: [Text(props.label)],
          ),
        );
      case LayoutType.container:
      default:
        return Container(
          width: props.width,
          height: props.height,
          color: props.color,
          child: Center(child: Text(props.label)),
        );
    }
  }
}
