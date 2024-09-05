import 'package:flutter/material.dart';
import '../widgets/container_widget.dart';

class WidgetPanel extends StatelessWidget {
  final List<WidgetItem> widgetItems = [
    WidgetItem(
      icon: Icons.widgets,
      label: 'Container',
      widget: const ContainerWidget(
        width: 100,
        height: 100,
        color: Colors.grey,
        label: 'Container',
      ),
    ),
    WidgetItem(icon: Icons.text_fields_outlined, label: 'Text'),
    WidgetItem(icon: Icons.input, label: 'Input'),
    WidgetItem(icon: Icons.smart_button, label: 'Button'),
    WidgetItem(icon: Icons.select_all_outlined, label: 'Select'),
    WidgetItem(icon: Icons.image, label: 'Image'),
    WidgetItem(icon: Icons.check_box, label: 'Checkbox'),
    WidgetItem(icon: Icons.radio_button_checked, label: 'Radio'),
    WidgetItem(icon: Icons.calendar_today, label: 'Calendar'),
    WidgetItem(icon: Icons.toggle_on_rounded, label: 'Toggle'),
    WidgetItem(icon: Icons.table_chart, label: 'Table'),
    WidgetItem(icon: Icons.insert_chart, label: 'Chart'),
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
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1,
              ),
              itemCount: widgetItems.length,
              itemBuilder: (context, index) {
                final widgetItem = widgetItems[index];
                
                // ContainerWidget일 때만 특별 처리
                if (widgetItem.widget is ContainerWidget) {
                  final containerWidget = widgetItem.widget as ContainerWidget;

                  return Draggable<ContainerWidget>(
                    data: containerWidget, // 드래그 시 ContainerWidget을 넘김
                    feedback: Material(
                      color: Colors.transparent,
                      child: containerWidget, // 드래그 중에 ContainerWidget 표시
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: buildWidgetItem(widgetItem),
                    ),
                    child: buildWidgetItem(widgetItem),
                  );
                }

                // 나머지 위젯들은 기본 처리
                return Draggable<WidgetItem>(
                  data: widgetItem, // 나머지는 WidgetItem으로 드래그 처리
                  feedback: Material(
                    color: Colors.transparent,
                    child: widgetItem.widget ?? Container(), // widget이 없으면 빈 Container 반환
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
      color: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: Colors.white),
          const SizedBox(height: 4.0),
          Text(
            item.label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
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
