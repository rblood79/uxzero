import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/selected_widget_model.dart';
import '../widgets/container_widget.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  _WorkAreaState createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  List<Widget> widgetsInWorkArea = []; // WorkArea에 드롭된 자식 위젯들 저장

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // 선택된 위젯이 이미 존재하는지 확인
          final selectedWidgetModel = Provider.of<SelectedWidgetModel>(context, listen: false);
          if (selectedWidgetModel.selectedWidgetProperties == null) {
            // 처음 선택한 경우만 초기 속성 설정
            selectedWidgetModel.selectWidget(
              WidgetProperties(
                id: 'page_01',
                label: 'Container',
                width: 1200,
                height: 600,
                color: Colors.white,
                x: 0,
                y: 0,
                layoutType: LayoutType.container, // 기본값 container
              ),
            );
          }
        },
        child: Consumer<SelectedWidgetModel>(
          builder: (context, selectedWidgetModel, child) {
            final selectedWidget = selectedWidgetModel.selectedWidgetProperties;

            // 너비와 높이 값이 유효한지 확인
            final width = selectedWidget?.width ?? 1200;
            final height = selectedWidget?.height ?? 600;
            final color = selectedWidget?.color ?? Colors.white;

            // Assertion 오류 방지를 위한 유효성 검사
            assert(width >= 0 && height >= 0, 'Width and height must be non-negative.');

            // layoutType에 따라 다른 레이아웃 위젯을 반환
            Widget layoutWidget;
            switch (selectedWidget?.layoutType) {
              case LayoutType.row:
                layoutWidget = Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: widgetsInWorkArea, // Row 내에서 자식 위젯 배치
                );
                break;
              case LayoutType.column:
                layoutWidget = Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: widgetsInWorkArea, // Column 내에서 자식 위젯 배치
                );
                break;
              case LayoutType.stack:
                layoutWidget = Stack(
                  children: widgetsInWorkArea, // Stack 내에서 자식 위젯 배치
                );
                break;
              case LayoutType.container:
              default:
                layoutWidget = Stack(children: widgetsInWorkArea); // 기본적으로 Stack 사용
            }

            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
              child: DragTarget<ContainerWidget>(
                onAcceptWithDetails: (DragTargetDetails<ContainerWidget> details) {
                  setState(() {
                    // 드롭된 위젯을 리스트에 추가
                    widgetsInWorkArea.add(details.data);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return layoutWidget; // 선택된 레이아웃으로 자식 위젯 배치
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
