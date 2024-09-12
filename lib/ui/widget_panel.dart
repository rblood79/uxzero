/*
    WidgetItem(icon: Remix.input_field, label: 'Input'),
    WidgetItem(icon: Remix.checkbox_blank_line, label: 'Button'),
    WidgetItem(icon: Remix.dropdown_list, label: 'Select'),
    WidgetItem(icon: Remix.image_line, label: 'Image'),
    WidgetItem(icon: Remix.checkbox_line, label: 'Checkbox'),
    WidgetItem(icon: Remix.radio_button_line, label: 'Radio'),
    WidgetItem(icon: Remix.calendar_line, label: 'Calendar'),
    WidgetItem(icon: Remix.toggle_line, label: 'Toggle'),
    WidgetItem(icon: Remix.table_line, label: 'Table'),
    WidgetItem(icon: Remix.bar_chart_box_line, label: 'Chart'),
    */

import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../widgets/container_widget.dart';
import '../widgets/text_widget.dart';

class WidgetPanel extends StatelessWidget {
  final List<WidgetItem> widgetItems = [
    WidgetItem(
      icon: Remix.add_box_line,
      label: 'Container',
      widget: ContainerWidget(
        width: 100,
        height: 100,
        color: Colors.amber,
        label: 'Container',
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
        ),
      ),
    ),
    WidgetItem(
      icon: Remix.text,
      label: 'Text',
      widget: const TextWidget(
        width: 100,
        height: 20,
        color: Colors.amber,
        label: 'Text',
      ),
    ),
    WidgetItem(icon: Remix.input_field, label: 'Input'),
    WidgetItem(icon: Remix.checkbox_blank_line, label: 'Button'),
    WidgetItem(icon: Remix.dropdown_list, label: 'Select'),
    WidgetItem(icon: Remix.image_line, label: 'Image'),
    WidgetItem(icon: Remix.checkbox_line, label: 'Checkbox'),
    WidgetItem(icon: Remix.radio_button_line, label: 'Radio'),
    WidgetItem(icon: Remix.calendar_line, label: 'Calendar'),
    WidgetItem(icon: Remix.toggle_line, label: 'Toggle'),
    WidgetItem(icon: Remix.table_line, label: 'Table'),
    WidgetItem(icon: Remix.bar_chart_box_line, label: 'Chart'),
  ];

  WidgetPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: const Center(child: Text('Widget')),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 한 줄에 2개의 아이템
                crossAxisSpacing: 4.0, // 아이템 간격
                mainAxisSpacing: 4.0, // 아이템 간격
                childAspectRatio: 1, // 1:1 비율로 설정
              ),
              itemCount: widgetItems.length,
              itemBuilder: (context, index) {
                final widgetItem = widgetItems[index];

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // 아이템의 실제 크기 측정
                    final itemWidth = constraints.maxWidth;
                    final itemHeight = constraints.maxHeight;

                    if (widgetItem.widget is ContainerWidget) {
                      final containerWidget =
                          widgetItem.widget as ContainerWidget;

                      return Draggable<ContainerWidget>(
                        data: containerWidget,
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: itemWidth,
                            height: itemHeight,
                            child:
                                buildWidgetItem(widgetItem), // 그리드 아이템을 그대로 사용
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: buildWidgetItem(widgetItem),
                        ),
                        child: buildWidgetItem(widgetItem),
                      );
                    }

                    if (widgetItem.widget is TextWidget) {
                      final textWidget = widgetItem.widget as TextWidget;

                      return Draggable<TextWidget>(
                        data: textWidget,
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: itemWidth,
                            height: itemHeight,
                            child:
                                buildWidgetItem(widgetItem), // 그리드 아이템을 그대로 사용
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: buildWidgetItem(widgetItem),
                        ),
                        child: buildWidgetItem(widgetItem),
                      );
                    }

                    return Draggable<WidgetItem>(
                      data: widgetItem,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: itemWidth,
                          height: itemHeight,
                          child: buildWidgetItem(widgetItem), // 그리드 아이템을 그대로 사용
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: buildWidgetItem(widgetItem),
                      ),
                      child: buildWidgetItem(widgetItem),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 위젯 아이템 빌드
  Widget buildWidgetItem(WidgetItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(item.icon, color: Colors.black87),
          const SizedBox(height: 4.0),
          Text(
            item.label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WidgetItem {
  final IconData icon;
  final String label;
  final Widget? widget;

  WidgetItem({required this.icon, required this.label, this.widget});
}
