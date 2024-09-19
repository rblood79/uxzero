import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/custom_app_bar.dart';
import '../ui/top_panel.dart';
import '../ui/sidebar_menu.dart';
import '../ui/widget_panel.dart';
import '../ui/work_area.dart';
import '../ui/property_panel.dart';
import '../ui/node_panel.dart';
import '../models/selected_widget_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String selectedMenu = ''; // 현재 선택된 메뉴 항목
  late Widget currentPanel; // 현재 표시 중인 패널 (WidgetPanel, NodePanel 등)
  bool isPanelVisible = false; // 패널 표시 여부
  double panelWidth = 0.0; // 패널의 동적 너비

  @override
  void initState() {
    super.initState();
    // 초기 패널 설정 (초기에는 비어있음)
    currentPanel = Container();
    panelWidth = 0.0; // 초기에는 패널이 없으므로 너비는 0
  }

  // 메뉴 선택 시 동작
  void handleMenuSelection(String menuLabel) {
    setState(() {
      if (menuLabel == 'Widget') {
        currentPanel = WidgetPanel(); // WidgetPanel로 변경
        panelWidth = WidgetPanel.getPanelWidth(); // WidgetPanel의 너비
        isPanelVisible = true; // 패널 보이기
      } else if (menuLabel == 'Node') {
        currentPanel = NodePanel(); // NodePanel로 변경
        panelWidth = NodePanel.getPanelWidth(); // NodePanel의 너비
        isPanelVisible = true; // 패널 보이기
      } else {
        isPanelVisible = false; // 패널 숨기기
        panelWidth = 0.0; // 패널이 없을 때는 너비 0
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectedWidgetModel(),
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: Stack(
          children: [
            const Column(
              children: [
                TopPanel(),
                Expanded(
                  child: WorkArea(),
                ),
              ],
            ),
            // 애니메이션 컨테이너
            Positioned(
              left: 48,
              top: 48,
              bottom: 0,
              child: AnimatedContainer(
                width: isPanelVisible ? panelWidth : 0.0, // 선택한 패널의 너비로 애니메이션
                duration: const Duration(milliseconds: 300), // 애니메이션 시간
                curve: Curves.easeInOut,
                color: Colors.white,
                child: currentPanel, // 현재 선택된 패널을 표시
              ),
            ),
            Positioned(
              top: 48,
              bottom: 0,
              left: 0,
              child: SidebarMenu(onMenuButtonPressed: handleMenuSelection),
            ),
            const Positioned(
              right: 0,
              top: 48,
              bottom: 0,
              child: PropertyPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

