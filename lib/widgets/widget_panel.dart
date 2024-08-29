import 'package:flutter/material.dart';

class WidgetPanel extends StatelessWidget {
  final List<WidgetItem> widgetItems = [
    WidgetItem(icon: Icons.widgets, label: 'Container'),
    WidgetItem(icon: Icons.text_fields_outlined, label: 'Text'),
    WidgetItem(icon: Icons.input, label: 'Input'),
    WidgetItem(icon: Icons.smart_button, label: 'Button'),
    WidgetItem(icon: Icons.select_all_outlined, label: 'Select'),
    WidgetItem(icon: Icons.radio_button_checked, label: 'Radio'),
    WidgetItem(icon: Icons.check_box, label: 'Checkbox'),
    WidgetItem(icon: Icons.image, label: 'Image'),
    WidgetItem(icon: Icons.calendar_today, label: 'Calendar'),
    WidgetItem(icon: Icons.table_chart, label: 'Table'),
    WidgetItem(icon: Icons.insert_chart, label: 'Chart'),
    // 필요에 따라 더 많은 항목 추가 가능
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // 패널의 너비를 설정
      color: Colors.grey[200], // 배경색 설정
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2열로 배치
          crossAxisSpacing: 4.0, // 열 간의 간격
          mainAxisSpacing: 4.0, // 행 간의 간격
          childAspectRatio: 1, // 각 아이템의 가로 세로 비율
        ),
        itemCount: widgetItems.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.red, // 항목의 배경색 설정
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widgetItems[index].icon, color: Colors.white),
                const SizedBox(height: 4.0),
                Text(
                  widgetItems[index].label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WidgetItem {
  final IconData icon;
  final String label;

  WidgetItem({required this.icon, required this.label});
}
