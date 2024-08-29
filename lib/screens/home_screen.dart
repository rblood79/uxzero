import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart'; // CustomAppBar import
import '../widgets/sidebar_menu.dart';  // SidebarMenu import
import '../widgets/widget_panel.dart'; // WidgetPanel import
import '../widgets/work_area.dart';    // WorkArea import
import '../widgets/property_panel.dart'; // PropertyPanel import

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // 분리된 CustomAppBar 위젯을 사용
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 48,
                child: Container(
                  color: Colors.blue,
                  child: const Center(child: Text('Top Area')),
                ),
              ),
              const Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Work Area
                          WorkArea(), // 분리된 WorkArea 위젯을 사용
                          // Property Panel
                          PropertyPanel(), // 분리된 PropertyPanel 위젯을 사용
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: Container(
                  color: Colors.red,
                  child: const Center(child: Text('Bottom Area')),
                ),
              ),
            ],
          ),
          // AnimatedPositioned를 사용하여 WidgetPanel의 위치를 제어
          Positioned(
            left: 48, // SidebarMenu가 위치하는 곳으로 설정
            top: 48,
            bottom: 48,
            child: SlideTransition(
              position: _offsetAnimation, // 애니메이션 설정
              child: WidgetPanel(), // WidgetPanel 위젯
            ),
          ),
          // SidebarMenu는 Stack의 마지막에 위치해 WidgetPanel 위에 렌더링됩니다.
          Positioned(
            top: 48,
            bottom: 48,
            left: 0,
            child: SidebarMenu(onMenuButtonPressed: handleMenuSelection), // 메뉴 버튼 클릭 시 호출
          ),
        ],
      ),
    );
  }
}
