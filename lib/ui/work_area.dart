import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';
import '../widgets/container_widget.dart';
import '../ui/widget_panel.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  _WorkAreaState createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  final List<Widget> widgets = []; // 드롭된 위젯을 저장할 리스트

  @override
  void initState() {
    super.initState();

    // 초기 선택된 위젯 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialWidgetProperties = WidgetProperties(
        id: 'widget_page_01',  // 고유 ID
        label: 'Initial Widget',
        width: 1200,
        height: 600,
        color: Colors.white,
      );
      context.read<SelectedWidgetModel>().selectWidget(initialWidgetProperties);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.grey[200],
        child: Center(
          child: Consumer<SelectedWidgetModel>(
            builder: (context, selectedWidgetModel, child) {
              final widgetProperties = selectedWidgetModel.selectedWidgetProperties;
              if (widgetProperties == null) {
                return const Text('위젯이 선택되지 않았습니다.');
              }
              return DragTarget<WidgetItem>(
                onAccept: (WidgetItem item) {
                  setState(() {
                    widgets.add(item.widget!);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    key: ValueKey(widgetProperties.id),
                    width: widgetProperties.width,
                    height: widgetProperties.height,
                    decoration: BoxDecoration(
                      color: widgetProperties.color,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text('${widgetProperties.id}: ${widgetProperties.label}'),
                        ),
                        ...widgets, // 드롭된 위젯들을 이곳에 추가
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}