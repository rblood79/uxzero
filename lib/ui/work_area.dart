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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<SelectedWidgetModel>(
        builder: (context, selectedWidgetModel, child) {
          final rootContainer = selectedWidgetModel.rootContainer;

          return GestureDetector(
            onTap: () {
              selectedWidgetModel.selectWidget(rootContainer);
            },
            child: Container(
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
            ),
          );
        },
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
            final textWidget = details.data as TextWidget;
            properties.children.add(
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
                type: WidgetType.text,
              ),
            );
          } else if (details.data is ContainerWidget) {
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
                layoutType: LayoutType.stack,
                type: WidgetType.container,
              ),
            );
          }
          selectedWidgetModel.addToHistory(); // 변경 사항을 이력에 추가
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

  Widget _buildLayoutWidget(
      WidgetProperties properties, SelectedWidgetModel selectedWidgetModel) {
    // 선택된 LayoutType에 따른 레이아웃을 반환
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
        return Stack(
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
      case LayoutType.grid:
        return GridView.count(
          crossAxisCount: 2,
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
      case LayoutType.wrap:
        return Wrap(
          alignment: WrapAlignment.start,
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
      case LayoutType.list:
        return ListView(
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
      /*case LayoutType.container: // Container 추가 처리
      return Container(
        width: properties.width,
        height: properties.height,
        color: properties.color,
        child: properties.children.isNotEmpty
            ? _buildLayoutWidget(properties.children.first, selectedWidgetModel) // 자식이 있으면 첫 번째 자식만 렌더링
            : null,
      );*/
      default:
        return const SizedBox(); // 기본적으로 빈 위젯 반환
    }
  }

  List<Widget> _buildChildWidgets(WidgetProperties parentProperties,
      SelectedWidgetModel selectedWidgetModel) {
    return parentProperties.children.map((childProperties) {
      // Flex가 있는 경우 Expanded로 감싸기
      if (parentProperties.layoutType == LayoutType.row ||
          parentProperties.layoutType == LayoutType.column) {
        return Expanded(
          flex: childProperties.flex,
          child: GestureDetector(
            onTap: () {
              selectedWidgetModel.selectWidget(childProperties);
            },
            child: _buildDragTargetForContainer(
                childProperties, selectedWidgetModel),
          ),
        );
      } else {
        // Flex가 없는 경우 그냥 출력
        return GestureDetector(
          onTap: () {
            selectedWidgetModel.selectWidget(childProperties);
          },
          child: _buildDragTargetForContainer(
              childProperties, selectedWidgetModel),
        );
      }
    }).toList();
  }
  
}
