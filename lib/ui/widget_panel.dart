import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../widgets/container_widget.dart';
import '../widgets/text_widget.dart';

class WidgetPanel extends StatelessWidget {
  final List<WidgetItem> widgetItems = [
    WidgetItem(
      icon: Remix.add_box_line,
      label: 'Container',
      widget: const ContainerWidget(
        width: 100,
        height: 100,
        color: Colors.red,
        label: 'Container',
      ),
    ),
    WidgetItem(
      icon: Remix.text,
      label: 'Text',
      widget: const TextWidget(
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
            /*decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
            ),*/
            child: const Center(child: Text('Widget')),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1,
              ),
              itemCount: widgetItems.length,
              itemBuilder: (context, index) {
                final widgetItem = widgetItems[index];

                if (widgetItem.widget is ContainerWidget) {
                  final containerWidget = widgetItem.widget as ContainerWidget;

                  return Draggable<ContainerWidget>(
                    data: containerWidget,
                    feedback: Material(
                      color: Colors.transparent,
                      child: containerWidget,
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
                      child: textWidget,
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: buildWidgetItem(widgetItem),
                    ),
                    child: buildWidgetItem(widgetItem),
                  );
                }

                // 기본 처리 (widget이 null일 경우 빈 Container로 처리)
                return Draggable<WidgetItem>(
                  data: widgetItem,
                  feedback: Material(
                    color: Colors.transparent,
                    child: widgetItem.widget ?? Container(),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: buildWidgetItem(widgetItem),
                  ),
                  child: buildWidgetItem(widgetItem),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWidgetItem(WidgetItem item) {
  return Container(
    // color 속성 대신 BoxDecoration 내에서 color 설정
    decoration: BoxDecoration(
      color: Colors.transparent, // 원래 투명 색을 유지
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
