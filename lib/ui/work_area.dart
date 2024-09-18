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

  Offset? _dragStartPosition; // 드래그 시작점 (Global)
  Offset? _dragEndPosition; // 드래그 종료점 (Global)
  bool _isDragging = false; // 드래그 상태 플래그

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
                  // 단일 선택 시 rootContainer 선택 가능하게 설정
                  selectedWidgetModel.clearSelection(); // 기존 선택 초기화
                  selectedWidgetModel
                      .selectWidget(rootContainer); // rootContainer 선택
                },
                onPanStart: (details) {
                  setState(() {
                    _dragStartPosition = details.globalPosition; // 변경
                    _dragEndPosition = _dragStartPosition; // 동일하게 설정
                    _isDragging = true;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _dragEndPosition = details.globalPosition; // 유지
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _isDragging = false;
                    _selectWidgetsInDragArea(selectedWidgetModel);
                    _dragStartPosition = null; // 드래그 끝나면 null로
                    _dragEndPosition = null;
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      key: _globalKeys[rootContainer.id],
                      width: rootContainer.width,
                      height: rootContainer.height,
                      decoration:
                          rootContainer.decoration, // 변경: decoration을 사용
                      child: _buildDragTargetForContainer(
                          rootContainer, selectedWidgetModel),
                    ),
                    if (_isDragging &&
                        _dragStartPosition != null &&
                        _dragEndPosition != null)
                      _buildDragSelectionBox(context), // 로컬 좌표를 사용하여 수정
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 드래그 영역을 로컬 좌표로 변환한 후 그리기
  Widget _buildDragSelectionBox(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localStart = renderBox.globalToLocal(_dragStartPosition!);
    final localEnd = renderBox.globalToLocal(_dragEndPosition!);

    return Positioned.fromRect(
      rect: Rect.fromPoints(localStart, localEnd), // 로컬 좌표로 변경된 좌표 사용
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

  // 드래그 영역 내의 위젯 선택 처리
  void _selectWidgetsInDragArea(SelectedWidgetModel selectedWidgetModel) {
    if (_dragStartPosition == null || _dragEndPosition == null) return;

    final dragArea = Rect.fromPoints(_dragStartPosition!, _dragEndPosition!);

    selectedWidgetModel.clearSelection(); // 기존 선택 초기화

    for (var child in selectedWidgetModel.rootContainer.children) {
      _selectWidgetsInContainer(child, dragArea, selectedWidgetModel);
    }
  }

  void _selectWidgetsInContainer(WidgetProperties container, Rect dragArea,
      SelectedWidgetModel selectedWidgetModel) {
    final key = _globalKeys[container.id];
    if (key != null && key.currentContext != null) {
      final renderBox = key.currentContext!.findRenderObject();
      if (renderBox == null || renderBox is! RenderBox) {
        return;
      }
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      final widgetRect = Rect.fromLTWH(
        position.dx,
        position.dy,
        size.width,
        size.height,
      );

      if (dragArea.overlaps(widgetRect)) {
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
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
                layoutType: LayoutType.column,
                type: WidgetType.text,
                alignment: Alignment.center, // 기본값 설정
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
          decoration: properties.decoration, // 변경: decoration 사용
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
          .contains(childProperties); // 다중 선택 여부

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
          // 기존 선택 상태 초기화 후 클릭한 객체만 선택
          selectedWidgetModel.clearSelection(); // 기존 선택 해제
          selectedWidgetModel.selectWidget(childProperties); // 클릭한 객체만 선택
        },
        onLongPress: () {
          selectedWidgetModel.selectWidget(childProperties); // 선택된 위젯을 삭제
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
              decoration: childProperties.decoration, // 수정: BoxDecoration 사용
              child: childProperties.type == WidgetType.text
                  ? Align(
                      alignment: childProperties.alignment ?? Alignment.center, // 기본 정렬 설정
                      child: Text(
                        childProperties.label,
                        textAlign: childProperties.textAlign ?? TextAlign.center, // 텍스트 정렬
                        style: TextStyle(fontSize: childProperties.fontSize ?? 12.0,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : _buildDragTargetForContainer(childProperties, selectedWidgetModel),
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

  void _updateGuidelineOverlay(SelectedWidgetModel selectedWidgetModel) {
    final selectedWidgets = selectedWidgetModel.selectedWidgetProperties;

    if (_guidelineOverlay != null) {
      _guidelineOverlay!.remove();
      _guidelineOverlay = null;
    }

    if (selectedWidgets.isNotEmpty) {
      List<_OverlayInfo> overlayInfoList = [];

      for (var selectedWidget in selectedWidgets) {
        WidgetProperties? currentWidget = selectedWidget;
        int depth = 0;
        while (currentWidget != null) {
          final key = _globalKeys[currentWidget.id];
          if (key != null && key.currentContext != null) {
            final renderBox = key.currentContext!.findRenderObject();
            if (renderBox == null || renderBox is! RenderBox) {
              return; // RenderBox가 null이거나 잘못된 타입일 때 처리
            }
            final size = renderBox.size;
            final offset = renderBox.localToGlobal(Offset.zero);

            overlayInfoList.add(_OverlayInfo(
              properties: currentWidget,
              size: size,
              offset: offset,
            ));
          }

          currentWidget = currentWidget.parent;
          depth++;
        }
      }

      _guidelineOverlay =
          _buildMultipleOverlay(overlayInfoList, selectedWidgetModel);
      Overlay.of(context).insert(_guidelineOverlay!);
    }
  }
///////////////////////////////////////////////////
OverlayEntry _buildMultipleOverlay(List<_OverlayInfo> overlayInfoList, SelectedWidgetModel selectedWidgetModel) {
  final selectedOverlayInfo = overlayInfoList.removeAt(0);
  overlayInfoList.add(selectedOverlayInfo);

  return OverlayEntry(
    builder: (context) => Stack(
      children: overlayInfoList.asMap().entries.map((entry) {
        final index = entry.key;
        final overlayInfo = entry.value;
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
        final color = colors[index % colors.length];

        // 크기 조정을 위한 변수
        double overlayWidth = overlayInfo.size.width;
        double overlayHeight = overlayInfo.size.height;

        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                Positioned(
                  left: overlayInfo.offset.dx,
                  top: overlayInfo.offset.dy,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      width: overlayWidth.roundToDouble(),  // 최종 그릴 때는 반올림
                      height: overlayHeight.roundToDouble(), // 최종 그릴 때는 반올림
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: color,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: overlayInfo.offset.dx,
                  top: overlayInfo.offset.dy - 30,
                  child: GestureDetector(
                    onTap: () {
                      selectedWidgetModel.clearSelection();
                      selectedWidgetModel.selectWidget(overlayInfo.properties);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: color.withOpacity(1.0),
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
                // 우측 하단에 리사이즈 포인트 추가
                Positioned(
                  left: overlayInfo.offset.dx + overlayWidth - 24, // 우측 하단 위치
                  top: overlayInfo.offset.dy + overlayHeight - 24, // 우측 하단 위치
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        // 오버레이 크기만 변경, 소수점 유지
                        overlayWidth += details.delta.dx;
                        overlayHeight += details.delta.dy;

                        // 최소 크기 제한 (소수점은 유지)
                        if (overlayWidth < 48) overlayWidth = 48;
                        if (overlayHeight < 48) overlayHeight = 48;
                      });
                    },
                    onPanEnd: (details) {
                      // 리사이즈가 끝난 후 실제 위젯의 크기를 업데이트, 소수점 제거 후 반올림 적용
                      setState(() {
                        overlayInfo.properties.width = overlayWidth.roundToDouble();
                        overlayInfo.properties.height = overlayHeight.roundToDouble();
                        selectedWidgetModel.notifyListeners(); // 모델에 변경 사항 알림
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: color,
                          width: 2.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.crop_square, // 리사이즈 아이콘
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }).toList(),
    ),
  );
}


/////////////////////////////////////////////////////////////

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
