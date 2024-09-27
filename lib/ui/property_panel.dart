import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
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
      width: 224,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white, // 배경색
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(-4, 0),
          ),
        ],
        border: const Border(
          left: BorderSide(
            // 오른쪽에만 테두리 적용
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: Consumer<SelectedWidgetModel>(
        builder: (context, selectedWidgetModel, child) {
          final selectedWidgets = selectedWidgetModel.selectedWidgetProperties;

          // 선택된 위젯이 없는 경우
          if (selectedWidgets.isEmpty) {
            return const Text('위젯을 선택하세요');
          }

          final selectedWidget = selectedWidgets.first;
          updateControllers(selectedWidget);

          final bool hasText = _hasTextWidget(selectedWidget);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Undo 및 Redo 버튼 추가
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedWidget.label),
                    Text(
                      selectedWidget.id,
                      maxLines: 1, // 한 줄로 제한
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 라벨 수정
                TextField(
                  decoration: const InputDecoration(
                      //labelText: 'Label',
                      ),
                  controller: labelController,
                  onChanged: (value) {
                    if (value != selectedWidget.label) {
                      selectedWidgetModel.updateLabel(value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                            //labelText: 'Width',
                            ),
                        keyboardType: TextInputType.number,
                        controller: widthController,
                        onChanged: (value) {
                          final newWidth = double.tryParse(value) ?? selectedWidget.width;
                          if (newWidth != selectedWidget.width) {
                            selectedWidgetModel.updateSize(newWidth, selectedWidget.height);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                            //labelText: 'Height',
                            ),
                        keyboardType: TextInputType.number,
                        controller: heightController,
                        onChanged: (value) {
                          final newHeight = double.tryParse(value) ?? selectedWidget.height;
                          if (newHeight != selectedWidget.height) {
                            selectedWidgetModel.updateSize(selectedWidget.width, newHeight);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 색상 선택 (Background Color)
                const Text(
                  'Background Color',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                DropdownButton<Color>(
                  value: _getValidColor(selectedWidget.decoration.color),
                  items: _buildColorDropdownItems(),
                  onChanged: (Color? newColor) {
                    if (newColor != null) {
                      selectedWidgetModel.updateColor(newColor);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // 테두리 색상 선택 (Border Color)
                const Text(
                  'Border Color',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                DropdownButton<Color>(
                  value: _getValidColor(selectedWidget.decoration.border?.top.color),
                  items: _buildColorDropdownItems(),
                  onChanged: (Color? newColor) {
                    if (newColor != null) {
                      selectedWidgetModel.updateBorder(
                        Border.all(
                          color: newColor,
                          width: selectedWidget.decoration.border?.top.width ?? 1.0,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // 레이아웃 타입 변경
                const Text(
                  'Layout Type',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Container(
                  /*decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.16), width: 0.0),
                  ),*/
                  padding: const EdgeInsets.all(0.0),
                  width: 192, // GridView의 너비 설정
                  height: 96, // GridView의 높이 설정
                  child: GridView.count(
                    crossAxisCount: 4, // 3개의 열로 설정
                    crossAxisSpacing: 0.0, // 열 간격
                    mainAxisSpacing: 0.0, // 행 간격
                    children: [
                      buildWidgetItem(
                        context: context,
                        icon: Remix.layout_column_line,
                        value: LayoutType.row,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.layout_row_line,
                        value: LayoutType.column,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.stack_line,
                        value: LayoutType.stack,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.layout_grid_line,
                        value: LayoutType.grid,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.text_wrap,
                        value: LayoutType.wrap,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.list_check,
                        value: LayoutType.list,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 텍스트 위젯인 경우만 표시
                if (hasText) ...[
                  Text('Font Size: ${selectedWidget.fontSize?.toStringAsFixed(0) ?? '12'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Slider(
                    min: 8,
                    max: 64,
                    value: selectedWidget.fontSize ?? 12.0,
                    onChanged: (value) {
                      selectedWidgetModel.updateFontSize(value);
                    },
                  ),
                  /*const SizedBox(height: 16),
                  const Text('Text Align'),
                  DropdownButton<TextAlign>(
                    value: selectedWidget.textAlign ?? TextAlign.left,
                    items: TextAlign.values.map((TextAlign align) {
                      return DropdownMenuItem<TextAlign>(
                        value: align,
                        child: Text(align.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (TextAlign? newAlign) {
                      if (newAlign != null) {
                        selectedWidgetModel.updateTextAlign(newAlign);
                      }
                    },
                  ),*/
                  const SizedBox(height: 16),
                  const Text(
                    'Alignment',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.24), width: 0.5),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    width: 144, // GridView의 너비 설정
                    height: 144, // GridView의 높이 설정
                    child: GridView.count(
                      crossAxisCount: 3, // 3x3 그리드 설정
                      crossAxisSpacing: 8.0, // 열 간격
                      mainAxisSpacing: 8.0, // 행 간격
                      children: [
                        buildWidgetItem(
                          context: context,
                          icon: Remix.checkbox_blank_fill,
                          value: Alignment.topLeft,
                          selectedWidget: selectedWidget,
                          selectedWidgetModel: selectedWidgetModel,
                        ),
                        buildWidgetItem(
                          context: context,
                          icon: Remix.checkbox_blank_fill,
                          value: Alignment.topCenter,
                          selectedWidget: selectedWidget,
                          selectedWidgetModel: selectedWidgetModel,
                        ),
                        buildWidgetItem(
                          context: context,
                          icon: Remix.checkbox_blank_fill,
                          value: Alignment.topRight,
                          selectedWidget: selectedWidget,
                          selectedWidgetModel: selectedWidgetModel,
                        ),
                        buildWidgetItem(
                          context: context,
                          icon: Remix.checkbox_blank_fill,
                          value: Alignment.centerLeft,
                          selectedWidget: selectedWidget,
                          selectedWidgetModel: selectedWidgetModel,
                        ),
                        buildWidgetItem(
                          context: context,
                          icon: Remix.checkbox_blank_fill,
                          value: Alignment.center,
                          selectedWidget: selectedWidget,
                          selectedWidgetModel: selectedWidgetModel,
                        ),
                        buildWidgetItem(
                          context: context,
                          icon: Remix.checkbox_blank_fill,
                          value: Alignment.centerRight,
                          selectedWidget: selectedWidget,
                          selectedWidgetModel: selectedWidgetModel,
                        ),
                        buildWidgetItem(
                          context: context,
                          icon: Remix.checkbox_blank_fill,
                          value: Alignment.bottomLeft,
                          selectedWidget: selectedWidget,
                          selectedWidgetModel: selectedWidgetModel,
                        ),
                        buildWidgetItem(
                          context: context,
                          icon: Remix.checkbox_blank_fill,
                          value: Alignment.bottomCenter,
                          selectedWidget: selectedWidget,
                          selectedWidgetModel: selectedWidgetModel,
                        ),
                        buildWidgetItem(
                          context: context,
                          icon: Remix.checkbox_blank_fill,
                          value: Alignment.bottomRight,
                          selectedWidget: selectedWidget,
                          selectedWidgetModel: selectedWidgetModel,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // MainAxisAlignment 선택
                const Text(
                  'Main Axis Alignment',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Container(
                  /*decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12, width: 0.5),
                  ),*/
                  padding: const EdgeInsets.all(0.0),
                  width: 192, // GridView의 너비 설정
                  height: 96, // GridView의 높이 설정
                  child: GridView.count(
                    crossAxisCount: 4, // 3개의 열로 설정
                    crossAxisSpacing: 0.0, // 열 간격
                    mainAxisSpacing: 0.0, // 행 간격
                    children: [
                      buildWidgetItem(
                        context: context,
                        icon: Remix.align_item_left_line, // Start
                        value: MainAxisAlignment.start,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.align_item_vertical_center_line, // Center
                        value: MainAxisAlignment.center,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.align_item_right_line, // End
                        value: MainAxisAlignment.end,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.flip_horizontal_2_line, // Space Between
                        value: MainAxisAlignment.spaceBetween,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.space, // Space Around
                        value: MainAxisAlignment.spaceAround,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.space, // Space Evenly
                        value: MainAxisAlignment.spaceEvenly,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // CrossAxisAlignment 선택
                const Text(
                  'Cross Axis Alignment',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Container(
                  /*decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black12, width: 0.5),
                  ),*/
                  padding: const EdgeInsets.all(0.0),
                  width: 192, // GridView의 너비 설정
                  height: 48, // GridView의 높이 설정
                  child: GridView.count(
                    crossAxisCount: 4, // 2개의 열로 설정
                    crossAxisSpacing: 0.0, // 열 간격
                    mainAxisSpacing: 0.0, // 행 간격
                    children: [
                      buildWidgetItem(
                        context: context,
                        icon: Remix.align_item_top_line, // Start
                        value: CrossAxisAlignment.start,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.align_item_horizontal_center_line, // Center
                        value: CrossAxisAlignment.center,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.align_item_bottom_line, // End
                        value: CrossAxisAlignment.end,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                      buildWidgetItem(
                        context: context,
                        icon: Remix.flip_vertical_2_line, // Stretch
                        value: CrossAxisAlignment.stretch,
                        selectedWidget: selectedWidget,
                        selectedWidgetModel: selectedWidgetModel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Flex 속성 수정 (Slider 사용)
                Text("Flex: ${selectedWidget.flex}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

  // 색상 목록 생성 함수
  List<DropdownMenuItem<Color>> _buildColorDropdownItems() {
    return <Color>[Colors.white, Colors.transparent, Colors.red, Colors.green, Colors.blue, Colors.yellow].map((Color color) {
      return DropdownMenuItem<Color>(
        value: color,
        child: Container(
          width: 100,
          height: 20,
          color: color,
        ),
      );
    }).toList();
  }

  // 선택된 색상이 Dropdown에 포함되지 않을 경우 처리
  Color _getValidColor(Color? selectedColor) {
    final List<Color> availableColors = [
      Colors.white,
      Colors.transparent,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
    ];

    // 선택된 색상이 null이거나 목록에 없는 경우 기본값으로 Colors.red 반환
    if (selectedColor == null || !availableColors.contains(selectedColor)) {
      return Colors.white;
    }
    return selectedColor;
  }
}

Widget buildWidgetItem({
  required BuildContext context, // context를 파라미터로 받음
  required IconData icon,
  required dynamic value, // LayoutType 또는 Alignment, MainAxisAlignment 모두 받을 수 있도록 dynamic 사용
  required WidgetProperties selectedWidget,
  required SelectedWidgetModel selectedWidgetModel,
}) {
  bool isSelected;

  // value가 LayoutType인지 Alignment인지 MainAxisAlignment인지에 따라 선택 여부를 구분
  if (value is LayoutType) {
    isSelected = selectedWidget.layoutType == value;
  } else if (value is Alignment) {
    isSelected = selectedWidget.alignment == value;
  } else if (value is MainAxisAlignment) {
    isSelected = selectedWidget.mainAxisAlignment == value;
  } else if (value is CrossAxisAlignment) {
    isSelected = selectedWidget.crossAxisAlignment == value; // CrossAxisAlignment 체크 추가
  } else {
    isSelected = false;
  }

  return SizedBox(
    width: 48.0,
    height: 48.0,
    child: Container(
      decoration: BoxDecoration(
        color: value is Alignment ? Colors.transparent : Colors.white,
        border: Border.all(color: value is Alignment ? Colors.transparent : Theme.of(context).colorScheme.outline.withOpacity(0.16), width: 0.5),
      ),
      child: TextButton(
        onPressed: () {
          // value가 LayoutType, Alignment, MainAxisAlignment, CrossAxisAlignment인지에 따라 적절한 업데이트 호출
          if (value is LayoutType) {
            selectedWidgetModel.updateLayoutType(value);
          } else if (value is Alignment) {
            selectedWidgetModel.updateAlignment(value);
          } else if (value is MainAxisAlignment) {
            selectedWidgetModel.updateMainAxisAlignment(value);
          } else if (value is CrossAxisAlignment) {
            selectedWidgetModel.updateCrossAxisAlignment(value); // CrossAxisAlignment 업데이트 추가
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
        ),
        child: Icon(
          icon,
          size: value is Alignment ? 14.0 : 21.0,
          //color: isSelected ? Colors.black87 : Colors.grey,
        ),
      ),
    ),
  );
}
