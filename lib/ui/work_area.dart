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
          selectedWidgetModel.selectWidget(rootContainer); // 부모 컨테이너 선택
        },
        child: Consumer<SelectedWidgetModel>(
          builder: (context, selectedWidgetModel, child) {
            return Container(
              width: rootContainer.width,
              height: rootContainer.height,
              decoration: BoxDecoration(
                color: rootContainer.color,
                border: Border.all(
                  color: Colors.red,
                  width: 0.0,
                ),
              ),
              child: _buildDragTargetForContainer(
                  rootContainer, selectedWidgetModel), // 최상위 컨테이너의 DragTarget
            );
          },
        ),
      ),
    );
  }

  // 드롭을 처리할 DragTarget을 컨테이너마다 생성하는 함수
  Widget _buildDragTargetForContainer(
      WidgetProperties properties, SelectedWidgetModel selectedWidgetModel) {
    return DragTarget<ContainerWidget>(
      onWillAcceptWithDetails: (data) {
        return true; // 언제나 드롭을 허용
      },
      onAcceptWithDetails: (details) {
        setState(() {
          // 현재 컨테이너의 자식 리스트에 드롭된 컨테이너 추가
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
      builder: (context, candidateData, rejectedData) {
        // 현재 컨테이너에 자식 컨테이너들을 재귀적으로 렌더링
        return Container(
          width: properties.width,
          height: properties.height,
          color: properties.color,
          child: _buildLayoutWidget(properties, selectedWidgetModel),
        );
      },
    );
  }

  // 레이아웃 타입에 맞게 자식 컨테이너를 배치하는 함수
  Widget _buildLayoutWidget(
      WidgetProperties properties, SelectedWidgetModel selectedWidgetModel) {
    switch (properties.layoutType) {
      case LayoutType.row:
        return Row(
          //mainAxisAlignment: MainAxisAlignment.start,
          mainAxisAlignment:
              properties.mainAxisAlignment, // mainAxisAlignment 적용
          children: _buildChildWidgets(properties, selectedWidgetModel),
        );
      case LayoutType.column:
        return Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          mainAxisAlignment:
              properties.mainAxisAlignment, // mainAxisAlignment 적용
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
  /*List<Widget> _buildChildWidgets(WidgetProperties parentProperties, SelectedWidgetModel selectedWidgetModel) {
    return parentProperties.children.map((childProperties) {
      return GestureDetector(
        onTap: () {
          selectedWidgetModel.selectWidget(childProperties); // 자식 컨테이너 선택
        },
        child: _buildDragTargetForContainer(childProperties, selectedWidgetModel), // 자식 컨테이너도 DragTarget으로 설정
      );
    }).toList();
  }*/
  List<Widget> _buildChildWidgets(WidgetProperties parentProperties,
      SelectedWidgetModel selectedWidgetModel) {
    return parentProperties.children.map((childProperties) {
      return Expanded(
        // Flexible, Expanded로 교체하여 flex 속성 적용
        flex: childProperties.flex, // 자식의 flex 속성 적용
        child: GestureDetector(
          onTap: () {
            selectedWidgetModel.selectWidget(childProperties); // 자식 컨테이너 선택
          },
          child: DragTarget<ContainerWidget>(
            onWillAcceptWithDetails: (data) {
              return true; // 언제나 드롭을 허용
            },
            onAcceptWithDetails: (details) {
              setState(() {
                // 자식 컨테이너에 드롭된 위젯을 자식 리스트에 추가
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
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: childProperties.width,
                height: childProperties.height,
                color: childProperties.color,
                child: _buildLayoutWidget(
                    childProperties, selectedWidgetModel), // 자식 컨테이너를 재귀적으로 렌더링
              );
            },
          ),
        ),
      );
    }).toList();
  }
}
