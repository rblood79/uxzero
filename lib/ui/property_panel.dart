import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';

class PropertyPanel extends StatefulWidget {
  const PropertyPanel({super.key});

  @override
  _PropertyPanelState createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  late TextEditingController labelController;
  late TextEditingController widthController;
  late TextEditingController heightController;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController();
    widthController = TextEditingController();
    heightController = TextEditingController();
  }

  @override
  void dispose() {
    labelController.dispose();
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }

  // 선택된 위젯의 속성이 변경될 때만 컨트롤러 업데이트
  void updateControllers(WidgetProperties selectedWidget) {
    if (labelController.text != selectedWidget.label) {
      labelController.text = selectedWidget.label;
    }
    if (widthController.text != selectedWidget.width.toString()) {
      widthController.text = selectedWidget.width.toString();
    }
    if (heightController.text != selectedWidget.height.toString()) {
      heightController.text = selectedWidget.height.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Consumer<SelectedWidgetModel>(
        builder: (context, selectedWidgetModel, child) {
          final selectedWidget = selectedWidgetModel.selectedWidgetProperties;
          if (selectedWidget == null) {
            return const Text('위젯을 선택하세요');
          }

          // 필요할 때만 컨트롤러 업데이트
          updateControllers(selectedWidget);

          final bool hasText = _hasTextWidget(selectedWidget);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Undo 및 Redo 버튼 추가
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: selectedWidgetModel.canUndo
                          ? () {
                              selectedWidgetModel.undo();
                            }
                          : null,
                      child: const Text('Undo'),
                    ),
                    ElevatedButton(
                      onPressed: selectedWidgetModel.canRedo
                          ? () {
                              selectedWidgetModel.redo();
                            }
                          : null,
                      child: const Text('Redo'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        selectedWidgetModel.deleteSelectedWidget();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 라벨 수정
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Label',
                  ),
                  controller: labelController,
                  onChanged: (value) {
                    if (value != selectedWidget.label) {
                      selectedWidgetModel.updateLabel(value);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // 너비 수정
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Width',
                  ),
                  keyboardType: TextInputType.number,
                  controller: widthController,
                  onChanged: (value) {
                    final newWidth =
                        double.tryParse(value) ?? selectedWidget.width;
                    if (newWidth != selectedWidget.width) {
                      selectedWidgetModel.updateSize(
                          newWidth, selectedWidget.height);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // 높이 수정
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Height',
                  ),
                  keyboardType: TextInputType.number,
                  controller: heightController,
                  onChanged: (value) {
                    final newHeight =
                        double.tryParse(value) ?? selectedWidget.height;
                    if (newHeight != selectedWidget.height) {
                      selectedWidgetModel.updateSize(
                          selectedWidget.width, newHeight);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // 색상 선택
                DropdownButton<Color>(
                  value: <Color>[
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                    Colors.yellow
                  ].contains(selectedWidget.color)
                      ? selectedWidget.color
                      : Colors.red, // 기본 색상 설정
                  items: <Color>[
                    Colors.red,
                    Colors.green,
                    Colors.blue,
                    Colors.yellow
                  ].map((Color color) {
                    return DropdownMenuItem<Color>(
                      value: color,
                      child: Container(
                        width: 100,
                        height: 20,
                        color: color,
                      ),
                    );
                  }).toList(),
                  onChanged: (Color? newColor) {
                    if (newColor != null) {
                      selectedWidgetModel.updateColor(newColor);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // LayoutType 선택 (ToggleButtons)
                const Text('Layout Type'),
                ToggleButtons(
                  isSelected: [
                    selectedWidget.layoutType == LayoutType.row,
                    selectedWidget.layoutType == LayoutType.column,
                    selectedWidget.layoutType == LayoutType.stack,
                    selectedWidget.layoutType == LayoutType.grid,
                    selectedWidget.layoutType == LayoutType.wrap,
                    selectedWidget.layoutType == LayoutType.list,
                  ],
                  onPressed: (int index) {
                    LayoutType newLayoutType;
                    if (index == 0) {
                      newLayoutType = LayoutType.row;
                    } else if (index == 1) {
                      newLayoutType = LayoutType.column;
                    } else if (index == 2) {
                      newLayoutType = LayoutType.stack;
                    } else if (index == 3) {
                      newLayoutType = LayoutType.grid;
                    } else if (index == 4) {
                      newLayoutType = LayoutType.wrap;
                    } else {
                      newLayoutType = LayoutType.list;
                    }
                    if (newLayoutType != selectedWidget.layoutType) {
                      selectedWidgetModel.updateLayoutType(newLayoutType);
                    }
                  },
                  children: const [
                    Icon(Remix.layout_row_line), // Row
                    Icon(Remix.layout_column_line), // Column
                    Icon(Remix.stack_line), // Stack
                    Icon(Remix.layout_grid_line), // Grid
                    Icon(Remix.text_wrap), // Wrap
                    Icon(Remix.list_check), // List
                  ],
                ),

                const SizedBox(height: 10),

                // MainAxisAlignment 선택 (ToggleButtons)
                const Text('Main Axis Alignment'),
                ToggleButtons(
                  isSelected: [
                    selectedWidget.mainAxisAlignment == MainAxisAlignment.start,
                    selectedWidget.mainAxisAlignment ==
                        MainAxisAlignment.center,
                    selectedWidget.mainAxisAlignment == MainAxisAlignment.end,
                    selectedWidget.mainAxisAlignment ==
                        MainAxisAlignment.spaceBetween,
                    selectedWidget.mainAxisAlignment ==
                        MainAxisAlignment.spaceAround,
                    selectedWidget.mainAxisAlignment ==
                        MainAxisAlignment.spaceEvenly,
                  ],
                  onPressed: (int index) {
                    MainAxisAlignment newAlignment;
                    if (index == 0) {
                      newAlignment = MainAxisAlignment.start;
                    } else if (index == 1) {
                      newAlignment = MainAxisAlignment.center;
                    } else if (index == 2) {
                      newAlignment = MainAxisAlignment.end;
                    } else if (index == 3) {
                      newAlignment = MainAxisAlignment.spaceBetween;
                    } else if (index == 4) {
                      newAlignment = MainAxisAlignment.spaceAround;
                    } else {
                      newAlignment = MainAxisAlignment.spaceEvenly;
                    }
                    selectedWidgetModel.updateMainAxisAlignment(newAlignment);
                  },
                  children: const [
                    Icon(Remix.align_item_left_line), // Start
                    Icon(Remix.align_item_vertical_center_line), // Center
                    Icon(Remix.align_item_right_line), // End
                    Icon(Remix.flip_horizontal_2_line), // Space Between
                    Icon(Remix.space), // Space Around
                    Icon(Remix.space), // Space Evenly
                  ],
                ),
                const SizedBox(height: 10),

                // CrossAxisAlignment 선택 (ToggleButtons)
                const Text('Cross Axis Alignment'),
                ToggleButtons(
                  isSelected: [
                    selectedWidget.crossAxisAlignment ==
                        CrossAxisAlignment.start,
                    selectedWidget.crossAxisAlignment ==
                        CrossAxisAlignment.center,
                    selectedWidget.crossAxisAlignment == CrossAxisAlignment.end,
                    selectedWidget.crossAxisAlignment ==
                        CrossAxisAlignment.stretch,
                    selectedWidget.crossAxisAlignment ==
                            CrossAxisAlignment.baseline &&
                        hasText, // Baseline 비활성화 조건 추가
                  ],
                  onPressed: (int index) {
                    CrossAxisAlignment newAlignment;
                    if (index == 0) {
                      newAlignment = CrossAxisAlignment.start;
                    } else if (index == 1) {
                      newAlignment = CrossAxisAlignment.center;
                    } else if (index == 2) {
                      newAlignment = CrossAxisAlignment.end;
                    } else if (index == 3) {
                      newAlignment = CrossAxisAlignment.stretch;
                    } else if (index == 4 && hasText) {
                      newAlignment = CrossAxisAlignment.baseline;
                    } else {
                      // 텍스트가 없으면 Baseline 선택 금지
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Baseline 정렬은 텍스트가 있는 경우에만 사용 가능합니다.')),
                      );
                      return;
                    }

                    selectedWidgetModel.updateCrossAxisAlignment(newAlignment);
                  },
                  children: const [
                    Icon(Remix.align_item_top_line), // Start
                    Icon(Remix.align_item_horizontal_center_line), // Center
                    Icon(Remix.align_item_bottom_line), // End
                    Icon(Remix.flip_vertical_2_line), // Stretch
                    Icon(Remix.t_box_line), // Baseline (조건에 따라 비활성화)
                  ],
                ),
                const SizedBox(height: 10),

                // Flex 속성 수정 (Slider 사용)
                Text("Flex: ${selectedWidget.flex}"),
                Slider(
                  min: 0,
                  max: 10,
                  value: selectedWidget.flex.toDouble(),
                  onChanged: (value) {
                    selectedWidgetModel.updateFlex(value.toInt());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 텍스트가 포함된 위젯인지 확인하는 헬퍼 함수
  bool _hasTextWidget(WidgetProperties widget) {
    if (widget.type == WidgetType.text) {
      return true;
    }
    return widget.children.any(_hasTextWidget); // 자식 위젯도 재귀적으로 확인
  }
}
