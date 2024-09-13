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

  // GlobalKey는 크기와 위치를 추적해야 하는 위젯에만 사용
  final Map<String, GlobalKey<State<StatefulWidget>>> _globalKeys = {};

  // 나머지 위젯은 ValueKey로 관리
  final Map<String, ValueKey<String>> _valueKeys = {};

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Consumer<SelectedWidgetModel>(
            builder: (context, selectedWidgetModel, child) {
              final rootContainer = selectedWidgetModel.rootContainer;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateGuidelineOverlay(selectedWidgetModel);
              });

              // 부모 컨테이너에 GlobalKey 또는 ValueKey 부여
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
                      key: _globalKeys[rootContainer.id], // GlobalKey 사용
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

      // GlobalKey와 ValueKey의 구분: 크기 및 위치 추적이 필요한 위젯에만 GlobalKey 사용
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
                  ? _globalKeys[childProperties.id] // GlobalKey 사용
                  : _valueKeys[childProperties.id], // ValueKey 사용
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

  // 가이드라인 Overlay 업데이트 함수
  void _updateGuidelineOverlay(SelectedWidgetModel selectedWidgetModel) {
    final selectedWidget = selectedWidgetModel.selectedWidgetProperties;

    if (_guidelineOverlay != null) {
      _guidelineOverlay!.remove();
      _guidelineOverlay = null;
    }

    if (selectedWidget != null) {
      final key = _globalKeys[selectedWidget.id];
      if (key != null && key.currentContext != null) {
        final RenderBox renderBox =
            key.currentContext!.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final offset = renderBox.localToGlobal(Offset.zero);

        _guidelineOverlay =
            _buildOverlay(selectedWidget, size, offset, selectedWidgetModel);
        Overlay.of(context).insert(_guidelineOverlay!);
      }
    }
  }

  OverlayEntry _buildOverlay(WidgetProperties properties, Size size,
      Offset offset, SelectedWidgetModel selectedWidgetModel) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: IgnorePointer(
              ignoring: true,
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
          Positioned(
            left: offset.dx,
            top: offset.dy - 30,
            child: GestureDetector(
              onTap: () {
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
                    decoration: TextDecoration.none,
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
