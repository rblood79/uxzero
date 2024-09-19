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
        color: Colors.black,
        label: 'Container',
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 0.0,
          ),
        ),
      ),
    ),
    WidgetItem(
      icon: Remix.text,
      label: 'Text',
      widget: const TextWidget(
        width: 100,
        height: 40,
        color: Colors.black,
        label: 'Text',
        textAlign: TextAlign.left,
        alignment: Alignment.center,
      ),
    ),
    WidgetItem(icon: Remix.input_field, label: 'Input'),
    WidgetItem(icon: Remix.checkbox_blank_line, label: 'Button'),
    WidgetItem(icon: Remix.dropdown_list, label: 'Select'),
    WidgetItem(icon: Remix.image_line, label: 'Image'),
    WidgetItem(icon: Remix.checkbox_line, label: 'Check'),
    WidgetItem(icon: Remix.radio_button_line, label: 'Radio'),
    WidgetItem(icon: Remix.calendar_line, label: 'Calendar'),
    WidgetItem(icon: Remix.toggle_line, label: 'Toggle'),
    WidgetItem(icon: Remix.table_line, label: 'Table'),
    WidgetItem(icon: Remix.bar_chart_box_line, label: 'Chart'),
  ];

  WidgetPanel({super.key});

  static double getPanelWidth() {
    return 160.0; // WidgetPanel의 너비
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getPanelWidth(),
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), //EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(
              height: 62,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Widget',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                ),
              )),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 한 줄에 2개의 아이템
              crossAxisSpacing: 0.0, // 아이템 간격
              mainAxisSpacing: 0.0, // 아이템 간격
              //childAspectRatio: 48 / 64, // 원하는 비율로 조정
              childAspectRatio: 1,
              children: widgetItems.map((widgetItem) {
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
                            child: buildWidgetItem(
                                widgetItem, context), // 그리드 아이템을 그대로 사용
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: buildWidgetItem(widgetItem, context),
                        ),
                        child: buildWidgetItem(widgetItem, context),
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
                            child: buildWidgetItem(
                                widgetItem, context), // 그리드 아이템을 그대로 사용
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: buildWidgetItem(widgetItem, context),
                        ),
                        child: buildWidgetItem(widgetItem, context),
                      );
                    }

                    return Draggable<WidgetItem>(
                      data: widgetItem,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: itemWidth,
                          height: itemHeight,
                          child: buildWidgetItem(
                              widgetItem, context), // 그리드 아이템을 그대로 사용
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: buildWidgetItem(widgetItem, context),
                      ),
                      child: buildWidgetItem(widgetItem, context),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 위젯 아이템 빌드
  Widget buildWidgetItem(WidgetItem item, BuildContext context) {
    return Container(
      //padding: const EdgeInsets.all(8),
      width: 62, // 고정된 너비
      height: 62, // 고정된 높이
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            color: Theme.of(context).colorScheme.primary, // 테마의 아이콘 색상 사용
            size: 21,
          ),
          const SizedBox(height: 4.0),
          Text(
            item.label,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
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
