import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';
import '../widgets/container_widget.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  _WorkAreaState createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  WidgetProperties rootContainer = WidgetProperties(
    id: 'page_01',
    label: 'Container_01',
    width: 1200,
    height: 600,
    color: Colors.white,
    x: 0,
    y: 0,
    layoutType: LayoutType.column,
    children: [],
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          final selectedWidgetModel =
              Provider.of<SelectedWidgetModel>(context, listen: false);
          selectedWidgetModel.selectWidget(rootContainer);
        },
        child: Consumer<SelectedWidgetModel>(
          builder: (context, selectedWidgetModel, child) {
            return Container(
              width: rootContainer.width,
              height: rootContainer.height,
              decoration: BoxDecoration(
                color: rootContainer.color,
                border: Border.all(
                  color: Colors.grey,
                  width: 0.0,
                ),
              ),
              child: _buildDragTargetForContainer(
                  rootContainer, selectedWidgetModel),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDragTargetForContainer(
      WidgetProperties properties, SelectedWidgetModel selectedWidgetModel) {
    return _buildDragTarget(
      properties: properties,
      selectedWidgetModel: selectedWidgetModel,
      onAccept: (details) {
        setState(() {
          properties.children.add(
            WidgetProperties(
              id: DateTime.now().toString(),
              label: details.data.label,
              width: details.data.width,
              height: details.data.height,
              color: details.data.color,
              x: 0,
              y: 0,
              layoutType: LayoutType.container,
            ),
          );
        });
      },
    );
  }

  Widget _buildDragTarget({
    required WidgetProperties properties,
    required SelectedWidgetModel selectedWidgetModel,
    required Function(DragTargetDetails<ContainerWidget>) onAccept,
  }) {
    return DragTarget<ContainerWidget>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: onAccept,
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: properties.width,
          height: properties.height,
          color: properties.color,
          child: _buildLayoutWidget(properties, selectedWidgetModel),
        );
      },
    );
  }

  Widget _buildLayoutWidget(
      WidgetProperties properties, SelectedWidgetModel selectedWidgetModel) {
    switch (properties.layoutType) {
      case LayoutType.row:
        return Row(
          mainAxisAlignment: properties.mainAxisAlignment,
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
      case LayoutType.column:
        return Column(
          mainAxisAlignment: properties.mainAxisAlignment,
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
      case LayoutType.stack:
      default:
        return Stack(
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
    }
  }

  List<Widget> _buildChildWidgets(WidgetProperties parentProperties,
      SelectedWidgetModel selectedWidgetModel) {
    return parentProperties.children.map((childProperties) {
      return Expanded(
        flex: childProperties.flex,
        child: GestureDetector(
          onTap: () {
            selectedWidgetModel.selectWidget(childProperties);
          },
          child: _buildDragTarget(
            properties: childProperties,
            selectedWidgetModel: selectedWidgetModel,
            onAccept: (details) {
              setState(() {
                childProperties.children.add(
                  WidgetProperties(
                    id: DateTime.now().toString(),
                    label: details.data.label,
                    width: details.data.width,
                    height: details.data.height,
                    color: details.data.color,
                    x: 0,
                    y: 0,
                    layoutType: LayoutType.container,
                  ),
                );
              });
            },
          ),
        ),
      );
    }).toList();
  }
}
