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
  final Map<String, GlobalKey<State<StatefulWidget>>> _globalKeys = {};
  Offset? _dragStartPosition;
  Offset? _dragEndPosition;
  bool _isDragging = true;
  Size? _guidelineSize;
  Offset? _guidelineOffset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
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
                    _guidelineOffset = null; // Reset guideline offset on drag end
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
                    if (_isDragging && _dragStartPosition != null && _dragEndPosition != null)
                      _buildDragSelectionBox(context),
                    if (_guidelineSize != null && _guidelineOffset != null)
                      _buildGuideline(),
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

    // Create guideline size and offset
    if (selectedWidgetModel.selectedWidgetProperties.isNotEmpty) {
      final selectedWidgets = selectedWidgetModel.selectedWidgetProperties;
      final firstWidget = selectedWidgets.first;

      final key = _globalKeys[firstWidget.id];
      if (key != null && key.currentContext != null) {
        final renderBox = key.currentContext!.findRenderObject() as RenderBox;
        _guidelineSize = Size(renderBox.size.width, renderBox.size.height);
        _guidelineOffset = renderBox.localToGlobal(Offset.zero);
      }
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

      Widget childWidget = GestureDetector(
        onTap: () {
          selectedWidgetModel.clearSelection();
          selectedWidgetModel.selectWidget(childProperties);
        },
        onLongPress: () {
          selectedWidgetModel.selectWidget(childProperties);
          selectedWidgetModel.deleteSelectedWidget();
        },
        child: Container(
          key:

 _globalKeys[childProperties.id],
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
              : _buildDragTargetForContainer(
                  childProperties, selectedWidgetModel),
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

  Widget _buildGuideline() {
    return Positioned(
      left: _guidelineOffset!.dx,
      top: _guidelineOffset!.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _guidelineSize = Size(
              _guidelineSize!.width + details.delta.dx,
              _guidelineSize!.height + details.delta.dy,
            );
          });
        },
        onPanEnd: (details) {
          // On resize end, apply the new size to the selected widgets
          Provider.of<SelectedWidgetModel>(context, listen: false)
              .resizeSelectedWidgets(_guidelineSize!);
        },
        child: Container(
          width: _guidelineSize!.width,
          height: _guidelineSize!.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                child: Icon(Icons.drag_handle, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}