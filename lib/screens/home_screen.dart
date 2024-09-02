import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/custom_app_bar.dart';
import '../ui/top_panel.dart';
import '../ui/sidebar_menu.dart';
import '../ui/widget_panel.dart';
import '../ui/work_area.dart';
import '../ui/property_panel.dart';
import '../models/selected_widget_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String selectedMenu = ''; // 현재 선택된 메뉴 항목
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // 시작 위치 (왼쪽 화면 밖)
      end: Offset.zero, // 끝 위치 (원래 위치)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void handleMenuSelection(String menuLabel) {
    setState(() {
      if (menuLabel == 'Widget') {
        selectedMenu = 'Widget';
        _controller.forward(); // 슬라이드 인 애니메이션 실행
      } else {
        selectedMenu = '';
        _controller.reverse(); // 슬라이드 아웃 애니메이션 실행
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  child: Row(
                    children: [
                      Expanded(
                        flex: 10,
                        child: WorkArea(),
                      ),
                      Expanded(
                        flex: 1,
                        child: PropertyPanel(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: Center(
                    child: Text('Bottom Area'),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 48,
              top: 48,
              bottom: 48,
              child: SlideTransition(
                position: _offsetAnimation,
                child: WidgetPanel(),
              ),
            ),
            Positioned(
              top: 48,
              bottom: 48,
              left: 0,
              child: SidebarMenu(onMenuButtonPressed: handleMenuSelection),
            ),
          ],
        ),
      ),
    );
  }
}