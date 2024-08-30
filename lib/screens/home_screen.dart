import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/top_panel.dart';
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

  double _containerWidth = 1920;
  double _containerHeight = 1080;
  Color _containerColor = const Color(0xFFFFFFFF);
  double _fontSize = 24;

  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _colorController;
  late TextEditingController _fontSizeController;

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

    // 초기값을 기반으로 컨트롤러 설정
    _widthController = TextEditingController(text: _containerWidth.toString());
    _heightController = TextEditingController(text: _containerHeight.toString());
    _colorController = TextEditingController(text: '#${_containerColor.value.toRadixString(16).substring(2).toUpperCase()}');
    _fontSizeController = TextEditingController(text: _fontSize.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _colorController.dispose();
    _fontSizeController.dispose();
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

  void updateWorkArea(double width, double height, Color color, double fontSize) {
    setState(() {
      _containerWidth = width;
      _containerHeight = height;
      _containerColor = color;
      _fontSize = fontSize;

      // 컨트롤러의 값도 업데이트하여 입력 필드에 반영
      _widthController.text = _containerWidth.toString();
      _heightController.text = _containerHeight.toString();
      _colorController.text = '#${_containerColor.value.toRadixString(16).substring(2).toUpperCase()}';
      _fontSizeController.text = _fontSize.toString();
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
              const TopPanel(), // 분리된 TopPanel 위젯을 사용
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Work Area
                          WorkArea(
                            width: _containerWidth,
                            height: _containerHeight,
                            color: _containerColor,
                            fontSize: _fontSize,
                          ),
                          // Property Panel
                          PropertyPanel(
                            widthController: _widthController,
                            heightController: _heightController,
                            colorController: _colorController,
                            fontSizeController: _fontSizeController,
                            onSizeChanged: (double width, double height) {
                              updateWorkArea(width, height, _containerColor, _fontSize);
                            },
                            onColorChanged: (Color color) {
                              updateWorkArea(_containerWidth, _containerHeight, color, _fontSize);
                            },
                            onFontSizeChanged: (double fontSize) {
                              updateWorkArea(_containerWidth, _containerHeight, _containerColor, fontSize);
                            },
                          ),
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
