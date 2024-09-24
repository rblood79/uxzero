import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
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

  Offset? _dragStartPosition;
  Offset? _dragEndPosition;
  bool _isDragging = true;

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
                  children: [
                    Container(
                      key: _globalKeys[rootContainer.id],
                      width: rootContainer.width,
                      height: rootContainer.height,
                      decoration: rootContainer.decoration,
                      child: _buildDragTargetForContainer(
                          rootContainer, selectedWidgetModel),
                    ),
                    if (_isDragging &&
                        _dragStartPosition != null &&
                        _dragEndPosition != null)
                      _buildDragSelectionBox(context),
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
            return Container(
              key: _globalKeys.containsKey(childProperties.id)
                  ? _globalKeys[childProperties.id]
                  : _valueKeys[childProperties.id],
              width: childProperties.width,
              height: childProperties.height,
              decoration: childProperties.decoration,
              child: childProperties.type == WidgetType.text
                  ? Align(
                      alignment: childProperties.alignment ?? Alignment.center,
                      child: Text(
                        childProperties.label,
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
              return;
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

  OverlayEntry _buildMultipleOverlay(List<_OverlayInfo> overlayInfoList,
      SelectedWidgetModel selectedWidgetModel) {
    final selectedOverlayInfo = overlayInfoList.removeAt(0);
    overlayInfoList.add(selectedOverlayInfo);

    List<WidgetProperties> findTopMostParents(
        List<WidgetProperties> selectedWidgets) {
      List<WidgetProperties> topMostParents = [];
      for (var widget in selectedWidgets) {
        var currentWidget = widget;
        while (currentWidget.parent != null &&
            selectedWidgets.contains(currentWidget.parent)) {
          currentWidget = currentWidget.parent!;
        }
        if (!topMostParents.contains(currentWidget)) {
          topMostParents.add(currentWidget);
        }
      }
      return topMostParents;
    }

    final topMostParents =
        findTopMostParents(selectedWidgetModel.selectedWidgetProperties);

    return OverlayEntry(
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) {
          final maxParentWidth = constraints.maxWidth;
          final maxParentHeight = constraints.maxHeight;

          return Stack(
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

              final isSelected = selectedWidgetModel.selectedWidgetProperties
                  .contains(overlayInfo.properties);
              final isTopMostParent =
                  topMostParents.contains(overlayInfo.properties);

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
                            width: overlayWidth.roundToDouble(),
                            height: overlayHeight.roundToDouble(),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: color,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        height: 24,
                        left: overlayInfo.offset.dx,
                        top: overlayInfo.offset.dy - 23,
                        child: GestureDetector(
                          onTap: () {
                            selectedWidgetModel.clearSelection();
                            selectedWidgetModel
                                .selectWidget(overlayInfo.properties);
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 0.0),
                              decoration: BoxDecoration(
                                color: color.withOpacity(1.0),
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
                      if (isSelected) ...[
                        Positioned(
                          width: 64,
                          height: 24,
                          left: overlayInfo.offset.dx + overlayWidth - 64,
                          top: overlayInfo.offset.dy + overlayHeight - 1,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.3),
                                  width: 0.0,
                                ),
                                color: color,
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
                        Positioned(
                          width: 64,
                          height: 24,
                          left: overlayInfo.offset.dx + overlayWidth - 21,
                          top: overlayInfo.offset.dy + overlayHeight - 44,
                          child: Transform.rotate(
                            angle: -90 * 3.1415927 / 180,
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 0.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.3),
                                    width: 0.0,
                                  ),
                                  color: color,
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
                        Positioned(
                          left: overlayInfo.offset.dx - 23,
                          top: overlayInfo.offset.dy - 23,
                          child: GestureDetector(
                            onTap: () {
                              // 해당 위젯 삭제
                              selectedWidgetModel
                                  .selectWidget(overlayInfo.properties);
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
                                color: color,
                              ),
                              child: const Icon(
                                Remix.close_line,
                                size: 21,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (isTopMostParent)
                          Positioned(
                            left: overlayInfo.offset.dx + overlayWidth - 1,
                            top: overlayInfo.offset.dy + overlayHeight - 1,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  overlayWidth += details.delta.dx;
                                  overlayHeight += details.delta.dy;

                                  if (overlayWidth < 48) overlayWidth = 48;
                                  if (overlayHeight < 48) overlayHeight = 48;

                                  if (overlayInfo.offset.dx + overlayWidth >
                                      maxParentWidth) {
                                    overlayWidth =
                                        maxParentWidth - overlayInfo.offset.dx;
                                  }
                                  if (overlayInfo.offset.dy + overlayHeight >
                                      maxParentHeight) {
                                    overlayHeight =
                                        maxParentHeight - overlayInfo.offset.dy;
                                  }
                                });
                              },
                              onPanEnd: (details) {
                                setState(() {
                                  overlayInfo.properties.width =
                                      overlayWidth.roundToDouble();
                                  overlayInfo.properties.height =
                                      overlayHeight.roundToDouble();
                                  selectedWidgetModel.notifyListeners();
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.3),
                                    width: 1.0,
                                  ),
                                  color: color,
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
                      ]
                    ],
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _guidelineOverlay?.remove();
    super.dispose();
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
