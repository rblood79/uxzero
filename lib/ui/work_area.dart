// lib/widgets/work_area.dart
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
  final GlobalKey _workAreaKey = GlobalKey(); // WorkArea의 GlobalKey 추가
  final Map<String, GlobalKey<State<StatefulWidget>>> _globalKeys = {};
  final Map<String, ValueKey<String>> _valueKeys = {};

  Offset? _dragStartPosition;
  Offset? _dragEndPosition;
  bool _isDragging = false;

  // 가이드라인 크기와 위치를 관리할 맵
  Map<String, Size> _guidelineSizes = {};
  Map<String, Offset> _resizeDeltas = {}; // 리사이즈 중 x, y 변화량을 저장

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Consumer<SelectedWidgetModel>(
            builder: (context, selectedWidgetModel, child) {
              final rootContainer = selectedWidgetModel.rootContainer;

              return GestureDetector(
                onTap: () {
                  selectedWidgetModel.clearSelection();
                  selectedWidgetModel.selectWidget(rootContainer);
                },
                onPanStart: (details) {
                  setState(() {
                    _dragStartPosition = details.globalPosition;
                    _dragEndPosition = _dragStartPosition;
                    _isDragging = true;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _dragEndPosition = details.globalPosition;
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _isDragging = false;
                    _selectWidgetsInDragArea(selectedWidgetModel);
                    _dragStartPosition = null;
                    _dragEndPosition = null;
                  });
                },
                child: Stack(
                  fit: StackFit.expand, // Stack의 크기를 부모에 맞춤
                  children: [
                    Positioned(
                      left: rootContainer.x,
                      top: rootContainer.y,
                      child: Container(
                        key: _workAreaKey, // WorkArea의 key 설정
                        width: rootContainer.width,
                        height: rootContainer.height,
                        decoration: rootContainer.decoration,
                        child: _buildDragTargetForContainer(
                            rootContainer, selectedWidgetModel),
                      ),
                    ),
                    // 드래그 중일 때 선택 박스 표시
                    if (_isDragging &&
                        _dragStartPosition != null &&
                        _dragEndPosition != null)
                      _buildDragSelectionBox(context),
                    // 선택된 위젯들의 가이드라인과 레이블 표시
                    ..._buildSelectionGuidelines(selectedWidgetModel),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDragSelectionBox(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localStart = renderBox.globalToLocal(_dragStartPosition!);
    final localEnd = renderBox.globalToLocal(_dragEndPosition!);

    return Positioned.fromRect(
      rect: Rect.fromPoints(localStart, localEnd),
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.lightBlue.withOpacity(0.3),
            border: Border.all(
              color: Colors.lightBlue,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  // 선택된 위젯들에 대한 가이드라인과 레이블을 생성
  List<Widget> _buildSelectionGuidelines(
      SelectedWidgetModel selectedWidgetModel) {
    List<Widget> guidelines = [];

    // WorkArea의 RenderBox 가져오기
    final workAreaContext = _workAreaKey.currentContext;
    if (workAreaContext == null) return guidelines;
    final workAreaRenderBox = workAreaContext.findRenderObject() as RenderBox;
    final workAreaPosition = workAreaRenderBox.localToGlobal(Offset.zero);

    for (var widgetProp in selectedWidgetModel.selectedWidgetProperties) {
      final key = _globalKeys[widgetProp.id];
      if (key != null && key.currentContext != null) {
        final renderBox = key.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final widgetPosition = renderBox.localToGlobal(Offset.zero);
          final size = renderBox.size;

          // WorkArea 내 상대적인 위치 계산
          final relativeLeft = widgetProp.x;
          final relativeTop = widgetProp.y;

          // 가이드라인 크기 초기화
          _guidelineSizes.putIfAbsent(widgetProp.id, () => size);

          guidelines.add(Positioned(
            left: relativeLeft,
            top: relativeTop,
            width: _guidelineSizes[widgetProp.id]!.width,
            height: _guidelineSizes[widgetProp.id]!.height,
            child: Stack(
              children: [
                // 가이드라인 경계에만 IgnorePointer 적용
                IgnorePointer(
                  child: SizedBox(
                    width: _guidelineSizes[widgetProp.id]!.width,
                    height: _guidelineSizes[widgetProp.id]!.height,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                ),
                // 리사이즈 버튼 추가 - 각 모서리에 위치
                _buildResizeHandle(
                    widgetId: widgetProp.id, position: ResizePosition.topLeft),
                _buildResizeHandle(
                    widgetId: widgetProp.id, position: ResizePosition.topRight),
                _buildResizeHandle(
                    widgetId: widgetProp.id,
                    position: ResizePosition.bottomLeft),
                _buildResizeHandle(
                    widgetId: widgetProp.id,
                    position: ResizePosition.bottomRight),
                // 레이블 표시 - IgnorePointer 밖에 배치
                Positioned(
                  left: 0,
                  top: 0, // 필요에 따라 조정 가능
                  child: Container(
                    width: _guidelineSizes[widgetProp.id]!.width,
                    height: 24,
                    color: Colors.blue.withOpacity(0.7),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      widgetProp.label,
                      overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 처리
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 2.0,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
        }
      }
    }

    return guidelines;
  }

  // 리사이즈 버튼을 생성하는 헬퍼 메서드
  Widget _buildResizeHandle(
      {required String widgetId, required ResizePosition position}) {
    double left = 0;
    double top = 0;

    switch (position) {
      case ResizePosition.topLeft:
        left = 0;
        top = 0;
        break;
      case ResizePosition.topRight:
        left = _guidelineSizes[widgetId]!.width - 12;
        top = 0;
        break;
      case ResizePosition.bottomLeft:
        left = 0;
        top = _guidelineSizes[widgetId]!.height - 12;
        break;
      case ResizePosition.bottomRight:
        left = _guidelineSizes[widgetId]!.width - 12;
        top = _guidelineSizes[widgetId]!.height - 12;
        break;
    }

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // 가이드라인의 크기만 변경
            Size currentSize = _guidelineSizes[widgetId]!;
            double newWidth = currentSize.width;
            double newHeight = currentSize.height;
            double deltaX = 0;
            double deltaY = 0;

            switch (position) {
              case ResizePosition.topLeft:
                newWidth -= details.delta.dx;
                newHeight -= details.delta.dy;
                deltaX += details.delta.dx;
                deltaY += details.delta.dy;
                break;
              case ResizePosition.topRight:
                newWidth += details.delta.dx;
                newHeight -= details.delta.dy;
                deltaY += details.delta.dy;
                break;
              case ResizePosition.bottomLeft:
                newWidth -= details.delta.dx;
                newHeight += details.delta.dy;
                deltaX += details.delta.dx;
                break;
              case ResizePosition.bottomRight:
                newWidth += details.delta.dx;
                newHeight += details.delta.dy;
                break;
            }

            // 최소 크기 설정
            if (newWidth < 50) {
              deltaX += newWidth < 50 ? (50 - newWidth) : 0;
              newWidth = 50;
            }
            if (newHeight < 50) {
              deltaY += newHeight < 50 ? (50 - newHeight) : 0;
              newHeight = 50;
            }

            // 가이드라인 크기 업데이트
            _guidelineSizes[widgetId] = Size(newWidth, newHeight);

            // 리사이즈 중인 위젯의 x, y 변화량 업데이트
            _resizeDeltas.update(widgetId, (existing) {
              return Offset(existing.dx + deltaX, existing.dy + deltaY);
            }, ifAbsent: () => Offset(deltaX, deltaY));
          });
        },
        onPanEnd: (details) {
          setState(() {
            // 리사이즈 종료 시, 가이드라인의 크기를 선택된 위젯의 크기로 업데이트
            Size newSize = _guidelineSizes[widgetId]!;
            Offset delta = _resizeDeltas[widgetId] ?? Offset.zero;

            // 선택된 위젯의 크기 및 위치 업데이트
            SelectedWidgetModel selectedWidgetModel =
                Provider.of<SelectedWidgetModel>(context, listen: false);
            WidgetProperties? widgetProp =
                selectedWidgetModel.selectedWidgetProperties.firstWhere(
              (element) => element.id == widgetId,
              orElse: () => selectedWidgetModel.rootContainer,
            );

            // x, y 업데이트
            widgetProp.x += delta.dx;
            widgetProp.y += delta.dy;

            // 크기 업데이트
            widgetProp.width = newSize.width;
            widgetProp.height = newSize.height;

            // 크기 변경 후, 가이드라인 크기를 위젯의 크기에 맞게 초기화
            _guidelineSizes[widgetId] =
                Size(widgetProp.width, widgetProp.height);

            // 리사이즈 델타 초기화
            _resizeDeltas.remove(widgetId);

            // 상태 업데이트 알림
            selectedWidgetModel.notifyListeners();
          });
        },
        onTap: () {
          // 리사이즈 버튼 탭 시 동작
          print('Resize handle tapped');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Resize 버튼이 탭되었습니다.')),
          );
        },
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _selectWidgetsInDragArea(SelectedWidgetModel selectedWidgetModel) {
    if (_dragStartPosition == null || _dragEndPosition == null) return;

    final dragArea = Rect.fromPoints(_dragStartPosition!, _dragEndPosition!);
    selectedWidgetModel.clearSelection();

    for (var child in selectedWidgetModel.rootContainer.children) {
      _selectWidgetsInContainer(child, dragArea, selectedWidgetModel);
    }
  }

  void _selectWidgetsInContainer(
    WidgetProperties container,
    Rect dragArea,
    SelectedWidgetModel selectedWidgetModel,
  ) {
    final key = _globalKeys[container.id];
    if (key != null && key.currentContext != null) {
      final renderBox = key.currentContext!.findRenderObject();
      if (renderBox == null || renderBox is! RenderBox) {
        return;
      }
      final position = container.x;
      //final size = container.size;
      final width = container.width;
      final height = container.height;

      final widgetRect = Rect.fromLTWH(
        container.x,
        container.y,
        container.width,
        container.height,
      );

      if (dragArea.contains(widgetRect.topLeft) &&
          dragArea.contains(widgetRect.bottomRight)) {
        selectedWidgetModel.addToSelection(container);
      }
    }

    for (var child in container.children) {
      _selectWidgetsInContainer(child, dragArea, selectedWidgetModel);
    }
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
                width: textWidget.width,
                height: textWidget.height,
                x: 0,
                y: 0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 0.0,
                  ),
                ),
                layoutType: LayoutType.column,
                type: WidgetType.text,
                alignment: Alignment.center,
                parent: properties,
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
                decoration: containerWidget.decoration,
                layoutType: LayoutType.stack,
                type: WidgetType.container,
                parent: properties,
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
          decoration: properties.decoration,
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
      bool isSelected = selectedWidgetModel.selectedWidgetProperties
          .contains(childProperties);

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
          selectedWidgetModel.clearSelection();
          selectedWidgetModel.selectWidget(childProperties);
        },
        onLongPress: () {
          selectedWidgetModel.selectWidget(childProperties);
          selectedWidgetModel.deleteSelectedWidget();
        },
        child: DragTarget<Object>(
          onWillAcceptWithDetails: (data) => true,
          onAcceptWithDetails: (data) {
            // Handle drag and drop
          },
          builder: (context, candidateData, rejectedData) {
            return Positioned(
              left: childProperties.x,
              top: childProperties.y,
              child: Container(
                key: _globalKeys.containsKey(childProperties.id)
                    ? _globalKeys[childProperties.id]
                    : _valueKeys[childProperties.id],
                width: childProperties.width,
                height: childProperties.height,
                decoration: childProperties.decoration,
                child: childProperties.type == WidgetType.text
                    ? Align(
                        alignment:
                            childProperties.alignment ?? Alignment.center,
                        child: Text(
                          childProperties.label,
                          overflow: TextOverflow.ellipsis, // 오버플로우 처리
                          textAlign:
                              childProperties.textAlign ?? TextAlign.center,
                          style: TextStyle(
                            fontSize: childProperties.fontSize ?? 12.0,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : _buildDragTargetForContainer(
                        childProperties, selectedWidgetModel),
              ),
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
}
