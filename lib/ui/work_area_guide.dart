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
              // 부모 컨테이너 선택 시 자식 선택 해제
              if (selectedWidgetModel.selectedWidgetProperties !=
                  rootContainer) {
                selectedWidgetModel.clearSelection(); // 선택된 자식을 해제
                selectedWidgetModel.selectWidget(rootContainer); // 부모 선택
              }
            },
            child: Stack(
              children: [
                // 부모 컨테이너 레이아웃
                Container(
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
                // 부모 컨테이너가 선택되거나 자식 중 하나가 선택된 경우 가이드라인 적용
                if (selectedWidgetModel.isSelected(rootContainer))
                  _buildGuideline(rootContainer),
              ],
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
                  color: Colors.red,
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
      default:
        return const SizedBox(); // 기본적으로 빈 위젯 반환
    }
  }

  List<Widget> _buildChildWidgets(WidgetProperties parentProperties,
      SelectedWidgetModel selectedWidgetModel) {
    return parentProperties.children.map((childProperties) {
      // 자식 위젯이 선택된 경우에만 가이드라인 적용
      bool isSelected =
          selectedWidgetModel.selectedWidgetProperties == childProperties;

      // 자식이 텍스트 위젯인 경우
      if (childProperties.type == WidgetType.text) {
        return Stack(
          children: [
            // 드래그 타겟 설정 (항상 상위 레이어에서 동작)
            GestureDetector(
              onTap: () {
                // 자식을 선택하면 부모 선택 해제
                if (!isSelected) {
                  selectedWidgetModel.clearSelection(); // 부모 선택 해제
                  selectedWidgetModel.selectWidget(childProperties); // 자식 선택
                }
              },
              onLongPress: () {
                selectedWidgetModel.selectWidget(childProperties);
                selectedWidgetModel.deleteSelectedWidget();
              },
              child: DragTarget<Object>(
                onWillAcceptWithDetails: (data) => true,
                onAcceptWithDetails: (data) {
                  // 드래그 드롭 처리
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: childProperties.width,
                    height: childProperties.height,
                    color: childProperties.color,
                    child: Center(
                      child: Text(
                        childProperties.label,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 선택된 경우 가이드라인 추가 (드래그 타겟 위에 겹쳐서 표시)
            if (isSelected) _buildGuideline(childProperties),
          ],
        );
      }

      // Flex 레이아웃인 경우 (Row 또는 Column)
      else if (parentProperties.layoutType == LayoutType.row ||
          parentProperties.layoutType == LayoutType.column) {
        return Expanded(
          flex: childProperties.flex,
          child: Stack(
            children: [
              // 드래그 타겟 설정 (항상 상위 레이어에서 동작)
              GestureDetector(
                onTap: () {
                  // 자식을 선택하면 부모 선택 해제
                  if (!isSelected) {
                    selectedWidgetModel.clearSelection(); // 부모 선택 해제
                    selectedWidgetModel.selectWidget(childProperties); // 자식 선택
                  }
                },
                onLongPress: () {
                  selectedWidgetModel.selectWidget(childProperties);
                  selectedWidgetModel.deleteSelectedWidget();
                },
                child: DragTarget<Object>(
                  onWillAcceptWithDetails: (data) => true,
                  onAcceptWithDetails: (data) {
                    // 드래그 드롭 처리
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: childProperties.width,
                      height: childProperties.height,
                      color: childProperties.color,
                      child: _buildDragTargetForContainer(
                          childProperties, selectedWidgetModel),
                    );
                  },
                ),
              ),
              // 선택된 경우 가이드라인 추가 (드래그 타겟 위에 겹쳐서 표시)
              if (isSelected) _buildGuideline(childProperties),
            ],
          ),
        );
      }

      // 다른 레이아웃의 경우
      else {
        return Stack(
          children: [
            // 드래그 타겟 설정 (항상 상위 레이어에서 동작)
            GestureDetector(
              onTap: () {
                // 자식을 선택하면 부모 선택 해제
                if (!isSelected) {
                  selectedWidgetModel.clearSelection(); // 부모 선택 해제
                  selectedWidgetModel.selectWidget(childProperties); // 자식 선택
                }
              },
              onLongPress: () {
                selectedWidgetModel.selectWidget(childProperties);
                selectedWidgetModel.deleteSelectedWidget();
              },
              child: DragTarget<Object>(
                onWillAcceptWithDetails: (data) => true,
                onAcceptWithDetails: (data) {
                  // 드래그 드롭 처리
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: childProperties.width,
                    height: childProperties.height,
                    color: childProperties.color,
                    child: _buildDragTargetForContainer(
                        childProperties, selectedWidgetModel),
                  );
                },
              ),
            ),
            // 선택된 경우 가이드라인 추가 (드래그 타겟 위에 겹쳐서 표시)
            if (isSelected) _buildGuideline(childProperties),
          ],
        );
      }
    }).toList();
  }

  // 가이드라인을 표시하는 함수
  Widget _buildGuideline(WidgetProperties properties) {
    return IgnorePointer(
      ignoring: true, // 가이드라인은 이벤트를 무시하도록 설정
      child: Container(
        width: properties.width, // 자식 위젯의 크기와 동일
        height: properties.height, // 자식 위젯의 크기와 동일
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue, // 가이드라인 색상
            width: 2.0,
          ),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.yellow, // 라벨의 배경색
                borderRadius: BorderRadius.circular(4.0), // 둥근 모서리
              ),
              child: Text(
                properties.label,
                style: const TextStyle(
                  color: Colors.black, // 텍스트 색상
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
