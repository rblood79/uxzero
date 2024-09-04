import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';
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
        x: 0,
        y: 0,
        layoutType: LayoutType.stack, // 기본 layoutType을 Stack으로 설정
      );
      widgetPropertiesList.add(initialWidgetProperties);
      context.read<SelectedWidgetModel>().selectWidget(initialWidgetProperties);
    });
  }

  Widget _buildWidgetFromProperties(WidgetProperties props) {
    return GestureDetector(
      onTap: () {
        context.read<SelectedWidgetModel>().selectWidget(props);
      },
      child: Container(
        width: props.width,
        height: props.height,
        color: props.color,
        child: Center(child: Text(props.label)),
      ),
    );
  }

  Widget _buildParentLayout(LayoutType layoutType, List<WidgetProperties> widgetPropertiesList) {
    switch (layoutType) {
      case LayoutType.row:
        return Row(
          children: widgetPropertiesList.map((widgetProps) {
            return Expanded(
              child: _buildWidgetFromProperties(widgetProps),
            );
          }).toList(),
        );
      case LayoutType.column:
        return Column(
          children: widgetPropertiesList.map((widgetProps) {
            return Expanded(
              child: _buildWidgetFromProperties(widgetProps),
            );
          }).toList(),
        );
      case LayoutType.stack:
      default:
        return Stack(
          children: widgetPropertiesList.map((widgetProps) {
            return Positioned(
              left: widgetProps.x,
              top: widgetProps.y,
              child: _buildWidgetFromProperties(widgetProps),
            );
          }).toList(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<SelectedWidgetModel>(
        builder: (context, selectedWidgetModel, child) {
          final WidgetProperties initialWidgetProperties = widgetPropertiesList.first;

          return Container(
            width: initialWidgetProperties.width,
            height: initialWidgetProperties.height,
            decoration: BoxDecoration(
              color: initialWidgetProperties.color,
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DragTarget<WidgetItem>(
              onWillAcceptWithDetails: (details) => details.data.label == 'Container',
              onAcceptWithDetails: (details) {
                setState(() {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.offset);

                  widgetPropertiesList.add(
                    WidgetProperties(
                      id: 'widget_${widgetPropertiesList.length + 1}',
                      label: details.data.label,
                      width: 100,
                      height: 100,
                      color: Colors.blue,
                      x: localPosition.dx.clamp(0.0, initialWidgetProperties.width - 100), // 부모 영역 내에서 제한
                      y: localPosition.dy.clamp(0.0, initialWidgetProperties.height - 100), // 부모 영역 내에서 제한
                      layoutType: LayoutType.stack,
                    ),
                  );
                });
              },
              builder: (context, candidateData, rejectedData) {
                return _buildParentLayout(initialWidgetProperties.layoutType, widgetPropertiesList);
              },
            ),
          );
        },
      ),
    );
  }
}
