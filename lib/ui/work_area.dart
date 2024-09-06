import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';
import '../widgets/container_widget.dart';
import '../widgets/text_widget.dart';

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
    border: Border.all(
      color: Colors.black,
      width: 1.0,
    ),
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
                  width: 1.0,
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
          if (details.data is TextWidget) {
            // TextWidget이 드롭된 경우 텍스트로 처리
            final textWidget = details.data as TextWidget;
            properties.children.add(
              WidgetProperties(
                id: DateTime.now().toString(),
                label: textWidget.label,
                width: 100,
                height: 40,
                color: Colors.transparent, // 텍스트 배경 투명
                x: 0,
                y: 0,
                border: Border.all(
                  color: Colors.transparent,
                ),
                layoutType: LayoutType.column,
                type: WidgetType.text, // 텍스트 타입으로 설정
              ),
            );
          } else if (details.data is ContainerWidget) {
            // ContainerWidget이 드롭된 경우 컨테이너로 처리
            final containerWidget = details.data as ContainerWidget;
            properties.children.add(
              WidgetProperties(
                id: DateTime.now().toString(),
                label: containerWidget.label,
                width: containerWidget.width,
                height: containerWidget.height,
                color: containerWidget.color,
                x: 0,
                y: 0,
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
                layoutType: LayoutType.container,
                type: WidgetType.container, // 컨테이너 타입으로 설정
              ),
            );
          }
        });
      },
    );
  }

  Widget _buildDragTarget({
    required WidgetProperties properties,
    required SelectedWidgetModel selectedWidgetModel,
    required Function(DragTargetDetails<dynamic>) onAccept,
  }) {
    return DragTarget<Object>(
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

  /*Widget _buildLayoutWidget(
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
  }*/
  Widget _buildLayoutWidget(
      WidgetProperties properties, SelectedWidgetModel selectedWidgetModel) {
    // 위젯 타입에 따라 컨테이너와 텍스트 구분
    if (properties.type == WidgetType.text) {
      return SizedBox(
        width: properties.width,
        height: properties.height,
        child: Center(
          child: Text(
            properties.label,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
      /*return Text(
        properties.label,
        style: const TextStyle(color: Colors.black),
      );*/
    } else {
      // 컨테이너로 처리
      switch (properties.layoutType) {
        case LayoutType.row:
          return Row(
            mainAxisAlignment: properties.mainAxisAlignment,
            crossAxisAlignment: properties.crossAxisAlignment,
            children: _buildChildWidgets(properties, selectedWidgetModel),
          );
        case LayoutType.column:
          return Column(
            mainAxisAlignment: properties.mainAxisAlignment,
            crossAxisAlignment: properties.crossAxisAlignment,
            children: _buildChildWidgets(properties, selectedWidgetModel),
          );
        case LayoutType.stack:
        default:
          return Stack(
            children: _buildChildWidgets(properties, selectedWidgetModel),
          );
      }
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
                // 드래그 된 데이터가 TextWidget일 경우
                if (details.data is TextWidget) {
                  final textWidget = details.data as TextWidget;
                  childProperties.children.add(
                    WidgetProperties(
                      id: DateTime.now().toString(),
                      label: textWidget.label,
                      width: 100,
                      height: 40,
                      color: Colors.transparent,
                      x: 0,
                      y: 0,
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      layoutType: LayoutType.column,
                      type: WidgetType.text, // 텍스트 타입 설정
                    ),
                  );
                } else if (details.data is ContainerWidget) {
                  // ContainerWidget 처리
                  final containerWidget = details.data as ContainerWidget;
                  childProperties.children.add(
                    WidgetProperties(
                      id: DateTime.now().toString(),
                      label: containerWidget.label,
                      width: containerWidget.width,
                      height: containerWidget.height,
                      color: containerWidget.color,
                      x: 0,
                      y: 0,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      layoutType: LayoutType.container,
                      type: WidgetType.container, // 컨테이너 타입 설정
                    ),
                  );
                }
              });
            },
          ),
        ),
      );
    }).toList();
  }
}
