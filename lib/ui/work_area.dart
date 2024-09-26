import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../models/selected_widget_model.dart';
import '../models/keyboard_model.dart';
import '../widgets/container_widget.dart';
import '../widgets/text_widget.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  _WorkAreaState createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  final Map<String, GlobalKey<State<StatefulWidget>>> _globalKeys = {};
  final Map<String, ValueKey<String>> _valueKeys = {};

  Offset? _dragStartPosition;
  Offset? _dragEndPosition;
  bool _isDragging = false;

  // 리사이즈 관련 변수
  String? _resizingWidgetId;
  Offset? _resizeStartPosition;
  double? _initialWidth;
  double? _initialHeight;

  // 작업 영역의 위치를 저장하는 변수
  Offset _workAreaPosition = Offset.zero;
  Offset _workAreaGlobalOffset = Offset.zero; // WorkArea의 글로벌 오프셋

  @override
  Widget build(BuildContext context) {
    // KeyboardModel에서 스페이스 키 상태를 가져옴
    final keyboardModel = context.watch<KeyboardModel>();

    // WorkArea가 빌드된 후 _workAreaGlobalOffset 값을 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = context.findRenderObject() as RenderBox;
      setState(() {
        _workAreaGlobalOffset = renderBox.localToGlobal(Offset.zero);
      });
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            GestureDetector(
              onPanStart: (details) {
                if (keyboardModel.isSpacePressed) {
                  // 스페이스 키가 눌린 경우 작업 영역 이동 시작
                  setState(() {
                    _dragStartPosition = details.globalPosition;
                    _isDragging = true;
                  });
                } else {
                  // 스페이스 키가 눌리지 않은 경우 멀티 선택 시작
                  setState(() {
                    _dragStartPosition = details.globalPosition;
                    _dragEndPosition = _dragStartPosition;
                    _isDragging = true;
                  });
                }
              },
              onPanUpdate: (details) {
                if (_isDragging) {
                  if (keyboardModel.isSpacePressed) {
                    // 작업 영역을 스페이스 키가 눌린 상태에서만 이동
                    setState(() {
                      final delta = details.globalPosition - _dragStartPosition!;
                      _workAreaPosition += delta;
                      _dragStartPosition = details.globalPosition;
                    });
                  } else {
                    // 스페이스 키가 눌리지 않은 경우, 멀티 선택 박스 업데이트
                    setState(() {
                      _dragEndPosition = details.globalPosition;
                    });
                  }
                }
              },
              onPanEnd: (details) {
                if (_isDragging) {
                  if (keyboardModel.isSpacePressed) {
                    // 작업 영역 이동 끝
                    setState(() {
                      _isDragging = false;
                      _dragStartPosition = null;
                    });
                  } else {
                    // 멀티 선택 완료 후, 선택된 위젯 처리
                    setState(() {
                      _selectWidgetsInDragArea(context.read<SelectedWidgetModel>());
                      _isDragging = false;
                      _dragStartPosition = null;
                      _dragEndPosition = null;
                    });
                  }
                }
              },
              child: Transform.translate(
                offset: _workAreaPosition,
                child: Stack(
                  children: [
                    Center(
                      child: Consumer<SelectedWidgetModel>(
                        builder: (context, selectedWidgetModel, child) {
                          final rootContainer = selectedWidgetModel.rootContainer;

                          if (!_globalKeys.containsKey(rootContainer.id)) {
                            _globalKeys[rootContainer.id] = GlobalKey();
                          }

                          return GestureDetector(
                            onTap: () {
                              selectedWidgetModel.clearSelection();
                              selectedWidgetModel.selectWidget(rootContainer);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  key: _globalKeys[rootContainer.id],
                                  width: rootContainer.width,
                                  height: rootContainer.height,
                                  decoration: rootContainer.decoration,
                                  child: _buildDragTargetForContainer(rootContainer, selectedWidgetModel),
                                ),
                                if (_isDragging && _dragStartPosition != null && _dragEndPosition != null && !keyboardModel.isSpacePressed) _buildDragSelectionBox(context),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 가이드라인 및 리사이즈 오버레이 추가
            Consumer<SelectedWidgetModel>(
              builder: (context, selectedWidgetModel, child) {
                final selectedWidgets = selectedWidgetModel.selectedWidgetProperties;

                if (selectedWidgets.isEmpty) {
                  return const SizedBox.shrink();
                }

                List<_OverlayInfo> overlayInfoList = [];

                for (var selectedWidget in selectedWidgets) {
                  WidgetProperties? currentWidget = selectedWidget;
                  while (currentWidget != null) {
                    final key = _globalKeys[currentWidget.id];
                    if (key != null && key.currentContext != null) {
                      final renderBox = key.currentContext!.findRenderObject() as RenderBox?;
                      if (renderBox == null) continue;
                      final size = renderBox.size;
                      final offset = renderBox.localToGlobal(Offset.zero);

                      overlayInfoList.add(_OverlayInfo(
                        properties: currentWidget,
                        size: size,
                        offset: offset,
                      ));
                    }

                    currentWidget = currentWidget.parent;
                  }
                }

                // 중복 제거 및 최상위 부모 찾기
                List<_OverlayInfo> uniqueOverlayInfoList = [];
                for (var info in overlayInfoList) {
                  if (!uniqueOverlayInfoList.any((existing) => existing.properties.id == info.properties.id)) {
                    uniqueOverlayInfoList.add(info);
                  }
                }

                return Stack(
                  children: uniqueOverlayInfoList.asMap().entries.map((entry) {
                    final index = entry.key; // 인덱스를 가져옴
                    final overlayInfo = entry.value; // overlayInfo 가져오기
                    final isSelected = selectedWidgets.contains(overlayInfo.properties);
                    final isTopMostParent = overlayInfo.properties.parent == null || !selectedWidgets.contains(overlayInfo.properties.parent);

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

                    double overlayWidth = overlayInfo.size.width;
                    double overlayHeight = overlayInfo.size.height;
                    // WorkArea의 실제 글로벌 위치를 기준으로 가이드라인 위치 조정
                    double correctedDx = overlayInfo.offset.dx - _workAreaGlobalOffset.dx;
                    double correctedDy = overlayInfo.offset.dy - _workAreaGlobalOffset.dy;

                    return Stack(
                      children: [
                        // 가이드라인 박스
                        Positioned(
                          left: correctedDx, //overlayInfo.offset.dx,
                          top: correctedDy, //overlayInfo.offset.dy,
                          child: IgnorePointer(
                            child: Container(
                              width: overlayWidth.roundToDouble(),
                              height: overlayHeight.roundToDouble(),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: color, //Theme.of(context).colorScheme.primary,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 라벨
                        Positioned(
                          left: correctedDx,
                          top: correctedDy - 23,
                          height: 24,
                          child: GestureDetector(
                            onTap: () {
                              selectedWidgetModel.clearSelection();
                              selectedWidgetModel.selectWidget(overlayInfo.properties);
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                                decoration: BoxDecoration(
                                  color: color, //Theme.of(context).colorScheme.primary.withOpacity(1.0),
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    overlayInfo.properties.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        // 삭제 버튼
                          Positioned(
                            left: correctedDx - 23,
                            top: correctedDy - 23,
                            child: GestureDetector(
                              onTap: () {
                                selectedWidgetModel.selectWidget(overlayInfo.properties);
                                selectedWidgetModel.deleteSelectedWidget();
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.3),
                                    width: 1.0,
                                  ),
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                child: const Icon(
                                  Remix.close_line,
                                  size: 21,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        // 리사이즈 핸들
                        //if (isSelected && isTopMostParent)
                        if (isSelected) ...[
                          Positioned(
                            left: correctedDx + overlayWidth - 1,
                            top: correctedDy + overlayHeight - 1,
                            child: GestureDetector(
                              onPanStart: (details) {
                                setState(() {
                                  _resizingWidgetId = overlayInfo.properties.id;
                                  _resizeStartPosition = details.globalPosition;
                                  _initialWidth = overlayWidth;
                                  _initialHeight = overlayHeight;
                                });
                              },
                              onPanUpdate: (details) {
                                if (_resizingWidgetId == overlayInfo.properties.id) {
                                  setState(() {
                                    // 현재 드래그 위치에서 이전 드래그 위치를 뺀 값을 누적하여 크기를 계산
                                    double newWidth = (_initialWidth! + (details.globalPosition.dx - _resizeStartPosition!.dx)).clamp(48.0, double.infinity);
                                    double newHeight = (_initialHeight! + (details.globalPosition.dy - _resizeStartPosition!.dy)).clamp(48.0, double.infinity);
                                    // 변경된 크기를 properties에 반영
                                    overlayInfo.properties.width = newWidth;
                                    overlayInfo.properties.height = newHeight;
                                    // 상태 변화를 즉시 반영하여 UI 업데이트
                                    //selectedWidgetModel.updateWidgetSize(overlayInfo.properties.id, newWidth, newHeight);
                                  });
                                }
                              },
                              onPanEnd: (details) {
                                if (_resizingWidgetId == overlayInfo.properties.id) {
                                  setState(() {
                                    overlayInfo.properties.width = (_initialWidth! + (details.globalPosition.dx - _resizeStartPosition!.dx)).roundToDouble();
                                    overlayInfo.properties.height = (_initialHeight! + (details.globalPosition.dy - _resizeStartPosition!.dy)).roundToDouble();
                                    // 리사이즈 종료 시 상태 업데이트 및 초기화
                                    selectedWidgetModel.notifyListeners();
                                    _resizingWidgetId = null;
                                    _resizeStartPosition = null;
                                    _initialWidth = null;
                                    _initialHeight = null;
                                  });
                                }
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.3),
                                    width: 1.0,
                                  ),
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                child: Transform.rotate(
                                  angle: -45 * 3.1415927 / 180,
                                  child: const Icon(
                                    Remix.expand_up_down_line,
                                    size: 21,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          Positioned(
                            width: 64,
                            height: 24,
                            left: correctedDx + overlayWidth - 64,
                            top: correctedDy + overlayHeight - 1,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.3),
                                    width: 0.0,
                                  ),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${overlayWidth.round()} px',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                )),
                          ),
                          // 크기 표시
                          Positioned(
                            width: 64,
                            height: 24,
                            left: correctedDx + overlayWidth - 21,
                            top: correctedDy + overlayHeight - 44,
                            child: Transform.rotate(
                              angle: -90 * 3.1415927 / 180,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.3),
                                      width: 0.0,
                                    ),
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${overlayHeight.round()} px',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                        ]
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
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
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      final widgetRect = Rect.fromLTWH(
        position.dx,
        position.dy,
        size.width,
        size.height,
      );

      if (dragArea.contains(widgetRect.topLeft) && dragArea.contains(widgetRect.bottomRight)) {
        selectedWidgetModel.addToSelection(container);
      }
    }

    for (var child in container.children) {
      _selectWidgetsInContainer(child, dragArea, selectedWidgetModel);
    }
  }

  Widget _buildDragTargetForContainer(WidgetProperties properties, SelectedWidgetModel selectedWidgetModel) {
    return _buildDragTarget(
      properties: properties,
      selectedWidgetModel: selectedWidgetModel,
      onAccept: (details) {
        setState(() {
          if (details.data is TextWidget) {
            final textWidget = details.data as TextWidget;
            properties.children.add(
              WidgetProperties(
                id: UID.generate(),
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
                id: UID.generate(),
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

  Widget _buildLayoutWidget(WidgetProperties properties, SelectedWidgetModel selectedWidgetModel) {
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

  List<Widget> _buildChildWidgets(WidgetProperties parentProperties, SelectedWidgetModel selectedWidgetModel) {
    return parentProperties.children.map((childProperties) {
      //final isSelected = selectedWidgetModel.selectedWidgetProperties.contains(childProperties);

      if (!_globalKeys.containsKey(childProperties.id) && (childProperties.type == WidgetType.container || childProperties.type == WidgetType.text)) {
        _globalKeys[childProperties.id] = GlobalKey();
      }

      if (!_valueKeys.containsKey(childProperties.id) && childProperties.type != WidgetType.container && childProperties.type != WidgetType.text) {
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
            return Container(
              key: _globalKeys.containsKey(childProperties.id) ? _globalKeys[childProperties.id] : _valueKeys[childProperties.id],
              width: childProperties.width,
              height: childProperties.height,
              decoration: childProperties.decoration,
              child: childProperties.type == WidgetType.text
                  ? Align(
                      alignment: childProperties.alignment ?? Alignment.center,
                      child: Text(
                        childProperties.label,
                        textAlign: childProperties.textAlign ?? TextAlign.center,
                        style: TextStyle(
                          fontSize: childProperties.fontSize ?? 12.0,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : _buildDragTargetForContainer(childProperties, selectedWidgetModel),
            );
          },
        ),
      );

      if (parentProperties.layoutType == LayoutType.row || parentProperties.layoutType == LayoutType.column) {
        return Expanded(
          flex: childProperties.flex,
          child: childWidget,
        );
      }

      return childWidget;
    }).toList();
  }
}

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
