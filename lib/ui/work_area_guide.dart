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

  final Map<String, GlobalKey<State<StatefulWidget>>> _globalKeys = {};
  final Map<String, ValueKey<String>> _valueKeys = {};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Consumer<SelectedWidgetModel>(
            builder: (context, selectedWidgetModel, child) {
              final rootContainer = selectedWidgetModel.rootContainer;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateGuidelineOverlay(selectedWidgetModel);
              });

              if (!_globalKeys.containsKey(rootContainer.id)) {
                _globalKeys[rootContainer.id] = GlobalKey();
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
                    Container(
                      key: _globalKeys[rootContainer.id],
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
                x: 0,
                y: 0,
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.red,
                ),
                layoutType: LayoutType.column,
                type: WidgetType.text,
                parent: properties, // 부모 참조 설정
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
                x: 0,
                y: 0,
                color: containerWidget.color,
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
                layoutType: LayoutType.stack,
                type: WidgetType.container,
                parent: properties, // 부모 참조 설정
              ),
            );
          }
          selectedWidgetModel.addToHistory();
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
        return const SizedBox();
    }
  }

  List<Widget> _buildChildWidgets(WidgetProperties parentProperties,
      SelectedWidgetModel selectedWidgetModel) {
    return parentProperties.children.map((childProperties) {
      bool isSelected =
          selectedWidgetModel.selectedWidgetProperties == childProperties;

      if (!_globalKeys.containsKey(childProperties.id) &&
          (childProperties.type == WidgetType.container ||
              childProperties.type == WidgetType.text)) {
        _globalKeys[childProperties.id] = GlobalKey();
      }

      if (!_valueKeys.containsKey(childProperties.id) &&
          childProperties.type != WidgetType.container &&
          childProperties.type != WidgetType.text) {
        _valueKeys[childProperties.id] = ValueKey(childProperties.id);
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
              key: _globalKeys.containsKey(childProperties.id)
                  ? _globalKeys[childProperties.id]
                  : _valueKeys[childProperties.id],
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

  // GUIDEIN 플래그를 추가하여 모든 계층을 표시할지 상위 부모까지만 표시할지 제어
  static const bool guideIn = true; // true: 모든 계층 부모 표시, false: 상위 부모까지만 표시

  // 가이드라인 Overlay 업데이트 함수
  void _updateGuidelineOverlay(SelectedWidgetModel selectedWidgetModel) {
    final selectedWidget = selectedWidgetModel.selectedWidgetProperties;

    // 기존 Overlay가 있으면 제거
    if (_guidelineOverlay != null) {
      _guidelineOverlay!.remove();
      _guidelineOverlay = null;
    }

    // 선택된 위젯이 있을 경우
    if (selectedWidget != null) {
      List<_OverlayInfo> overlayInfoList = [];

      // 선택된 객체부터 상위 부모까지 추적
      WidgetProperties? currentWidget = selectedWidget;
      int depth = 0; // 깊이를 추적하여 플래그에 따른 처리 수행
      while (currentWidget != null) {
        final key = _globalKeys[currentWidget.id];
        if (key != null && key.currentContext != null) {
          final RenderBox renderBox =
              key.currentContext!.findRenderObject() as RenderBox;
          final size = renderBox.size;
          final offset = renderBox.localToGlobal(Offset.zero);

          // 상위 객체 정보 저장 (위치, 크기)
          overlayInfoList.add(_OverlayInfo(
            properties: currentWidget,
            size: size,
            offset: offset,
          ));
        }

        // 플래그가 false일 경우, 선택된 객체와 부모만 추적 후 종료
        if (!guideIn && depth >= 1) {
          break;
        }

        currentWidget = currentWidget.parent; // 상위 객체로 이동
        depth++; // 깊이 증가
      }

      // 가이드라인 및 라벨 표시
      _guidelineOverlay =
          _buildMultipleOverlay(overlayInfoList, selectedWidgetModel);
      Overlay.of(context).insert(_guidelineOverlay!);
    }
  }

  OverlayEntry _buildMultipleOverlay(List<_OverlayInfo> overlayInfoList,
      SelectedWidgetModel selectedWidgetModel) {
    // 선택된 객체를 마지막에 그리기 위해 배열에서 선택된 객체를 제거하고 다시 추가
    final selectedOverlayInfo = overlayInfoList.removeAt(0); // 선택된 객체는 항상 첫 번째
    overlayInfoList.add(selectedOverlayInfo); // 선택된 객체를 마지막에 추가

    return OverlayEntry(
      builder: (context) => Stack(
        children: overlayInfoList.asMap().entries.map((entry) {
          final index = entry.key;
          final overlayInfo = entry.value;

          // 가이드라인 색상 리스트 (깊이에 따라 색상 변경)
          final colors = [
            Colors.red,
            Colors.orange,
            Colors.green,
            Colors.lightBlue,
            Colors.lightBlueAccent,
            Colors.blue,
            Colors.blueAccent,
            Colors.purple,
            
          ];
          final color = colors[index % colors.length]; // 계층 깊이에 따라 색상 순환

          return Stack(
            children: [
              // 가이드라인 표시
              Positioned(
                left: overlayInfo.offset.dx,
                top: overlayInfo.offset.dy,
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    width: overlayInfo.size.width,
                    height: overlayInfo.size.height,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: color,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              // 각 계층 객체의 레이블 표시 (현재는 나중에 처리 예정)
              Positioned(
                left: overlayInfo.offset.dx,
                top: overlayInfo.offset.dy - 30, // 레이블 위치 조정은 나중에 적용
                child: GestureDetector(
                  onTap: () {
                    selectedWidgetModel.clearSelection();
                    selectedWidgetModel.selectWidget(overlayInfo.properties);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: color.withOpacity(1.0), // 가이드라인 색상에 맞춘 배경
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    child: Text(
                      overlayInfo.properties.label,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _guidelineOverlay?.remove();
    super.dispose();
  }
}

// 상위 객체들의 정보를 담을 클래스
class _OverlayInfo {
  final WidgetProperties properties;
  final Size size;
  final Offset offset;

  _OverlayInfo({
    required this.properties,
    required this.size,
    required this.offset,
  });
}
