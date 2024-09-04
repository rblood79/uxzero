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
    id: 'parent',
    label: 'Parent Container',
    width: 1200,
    height: 600,
    color: Colors.white,
    x: 0,
    y: 0,
    layoutType: LayoutType.container,
    children: [],
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          final selectedWidgetModel = Provider.of<SelectedWidgetModel>(context, listen: false);
          selectedWidgetModel.selectWidget(rootContainer); // 부모 컨테이너 선택
        },
        child: Consumer<SelectedWidgetModel>(
          builder: (context, selectedWidgetModel, child) {
            final selectedWidget = selectedWidgetModel.selectedWidgetProperties;

            return Container(
              width: rootContainer.width,
              height: rootContainer.height,
              decoration: BoxDecoration(
                color: rootContainer.color,
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
              child: DragTarget<ContainerWidget>(
                onWillAcceptWithDetails: (data) {
                  return true; // 언제나 드롭을 허용
                },
                onAcceptWithDetails: (details) {
                  setState(() {
                    rootContainer.children.add(
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
                builder: (context, candidateData, rejectedData) {
                  // 선택된 레이아웃에 맞게 자식 위젯 배치
                  return _buildLayoutWidget(rootContainer, selectedWidgetModel);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // 레이아웃 타입에 맞게 위젯을 배치하는 함수
  Widget _buildLayoutWidget(WidgetProperties properties, SelectedWidgetModel selectedWidgetModel) {
    switch (properties.layoutType) {
      case LayoutType.row:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
      case LayoutType.column:
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
      case LayoutType.stack:
      default:
        return Stack(
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
    }
  }

  // 자식 컨테이너를 재귀적으로 렌더링하는 함수
  List<Widget> _buildChildWidgets(WidgetProperties parentProperties, SelectedWidgetModel selectedWidgetModel) {
    return parentProperties.children.map((childProperties) {
      return GestureDetector(
        onTap: () {
          selectedWidgetModel.selectWidget(childProperties); // 자식 컨테이너 선택
        },
        child: Container(
          width: childProperties.width,
          height: childProperties.height,
          color: childProperties.color,
          child: _buildLayoutWidget(childProperties, selectedWidgetModel), // 재귀적으로 자식 렌더링
        ),
      );
    }).toList();
  }
}
