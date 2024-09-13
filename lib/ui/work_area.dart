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
  OverlayEntry? _guidelineOverlay;
  final Map<String, GlobalKey> _widgetKeys = {};

  @override
  Widget build(BuildContext context) {
    // MediaQuery를 사용해 현재 화면 크기 정보 가져오기
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Consumer<SelectedWidgetModel>(
            builder: (context, selectedWidgetModel, child) {
              final rootContainer = selectedWidgetModel.rootContainer;

              // 화면 크기가 변경되면 가이드라인 재계산
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateGuidelineOverlay(selectedWidgetModel);
              });

              // 부모 컨테이너에 GlobalKey 부여
              if (!_widgetKeys.containsKey(rootContainer.id)) {
                _widgetKeys[rootContainer.id] = GlobalKey();
              }

              return GestureDetector(
                onTap: () {
                  if (selectedWidgetModel.selectedWidgetProperties !=
                      rootContainer) {
                    selectedWidgetModel.clearSelection();
                    selectedWidgetModel.selectWidget(rootContainer);
                  }
                },
                child: Stack(
                  children: [
                    // 부모 컨테이너 레이아웃
                    Container(
                      key: _widgetKeys[
                          rootContainer.id], // 부모 컨테이너에 GlobalKey 적용
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
                  ],
                ),
              );
            },
          ),
        );
      },
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
      bool isSelected =
          selectedWidgetModel.selectedWidgetProperties == childProperties;

      // 각 자식 위젯에 대해 GlobalKey 할당
      if (!_widgetKeys.containsKey(childProperties.id)) {
        _widgetKeys[childProperties.id] = GlobalKey();
      }

      Widget childWidget = GestureDetector(
        onTap: () {
          if (!isSelected) {
            selectedWidgetModel.clearSelection();
            selectedWidgetModel.selectWidget(childProperties);
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
              key: _widgetKeys[childProperties.id], // 자식 위젯에 GlobalKey 부착
              width: childProperties.width,
              height: childProperties.height,
              color: childProperties.color,
              child: childProperties.type == WidgetType.text
                  ? Center(
                      child: Text(
                        childProperties.label,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    )
                  : _buildDragTargetForContainer(
                      childProperties, selectedWidgetModel),
            );
          },
        ),
      );

      // Flex 레이아웃일 경우
      if (parentProperties.layoutType == LayoutType.row ||
          parentProperties.layoutType == LayoutType.column) {
        return Expanded(
          flex: childProperties.flex,
          child: childWidget,
        );
      }

      return childWidget;
    }).toList();
  }

  // 가이드라인 Overlay 업데이트 함수
  void _updateGuidelineOverlay(SelectedWidgetModel selectedWidgetModel) {
    final selectedWidget = selectedWidgetModel.selectedWidgetProperties;

    if (_guidelineOverlay != null) {
      _guidelineOverlay!.remove();
      _guidelineOverlay = null;
    }

    if (selectedWidget != null) {
      // 선택된 위젯의 실제 렌더링 크기와 위치를 가져옴
      final key = _widgetKeys[selectedWidget.id];
      if (key != null && key.currentContext != null) {
        final RenderBox renderBox =
            key.currentContext!.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final offset = renderBox.localToGlobal(Offset.zero);

        // 실제 크기와 위치를 사용해 가이드라인을 그릴 OverlayEntry 생성
        _guidelineOverlay =
            _buildOverlay(selectedWidget, size, offset, selectedWidgetModel);
        Overlay.of(context).insert(_guidelineOverlay!);
      }
    }
  }

  // OverlayEntry로 가이드라인을 생성하는 함수
  OverlayEntry _buildOverlay(WidgetProperties properties, Size size,
      Offset offset, SelectedWidgetModel selectedWidgetModel) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 가이드라인 자체
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: IgnorePointer(
              ignoring: true, // 가이드라인은 이벤트를 무시하도록 설정
              
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.lightBlueAccent,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ),
          // 라벨을 가이드라인 위쪽에 배치
          Positioned(
            left: offset.dx,
            top: offset.dy - 30, // Y축으로 위로 이동 (가이드라인 위로)
            child: GestureDetector(
              onTap: () {
                // 라벨 클릭 시 해당 객체 선택
                selectedWidgetModel.clearSelection();
                selectedWidgetModel.selectWidget(properties);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: Text(
                  properties.label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none, // 밑줄 제거
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _guidelineOverlay?.remove();
    super.dispose();
  }
}
