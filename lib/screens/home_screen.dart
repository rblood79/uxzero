import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/custom_app_bar.dart';
import '../ui/top_panel.dart';
import '../ui/sidebar_menu.dart';
import '../ui/widget_panel.dart';
import '../ui/node_panel.dart';
import '../ui/site_panel.dart';
import '../ui/data_panel.dart';
import '../ui/library_panel.dart';

import '../ui/work_area.dart';
import '../ui/property_panel.dart';

import '../models/selected_widget_model.dart';

// Enum을 사용하여 메뉴 옵션 정의
enum MenuOption {
  Site,
  Widget,
  Node,
  Data,
  Library,
  User,
  Setting,
}

// Tuple2 클래스 정의 (필요시 패키지 사용 가능)
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;
  Tuple2(this.item1, this.item2);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedMenu = 'Widget'; // 현재 선택된 메뉴 항목
  Widget currentPanel = WidgetPanel(); // 현재 표시 중인 패널
  double panelWidth = 160.0; // 패널의 현재 너비
  bool isPanelVisible = true; // 패널 표시 여부

  // 메뉴 라벨을 Enum으로 매핑
  final Map<String, MenuOption> labelToOptionMap = {
    'Site': MenuOption.Site,
    'Widget': MenuOption.Widget,
    'Node': MenuOption.Node,
    'Data': MenuOption.Data,
    'Library': MenuOption.Library,
    'User': MenuOption.User,
    'Setting': MenuOption.Setting,
  };

  // 패널 매핑
  final Map<MenuOption, Tuple2<Widget, double>> panelMap = {
    MenuOption.Site: Tuple2(const SitePanel(), 400.0),
    MenuOption.Widget: Tuple2(WidgetPanel(), 160.0),
    MenuOption.Node: Tuple2(const NodePanel(), 250.0),
    MenuOption.Data: Tuple2(const DataPanel(), 220.0),
    MenuOption.Library: Tuple2(const LibraryPanel(), 280.0),
    // 다른 패널을 추가할 경우 여기에 매핑 추가
  };

  // 메뉴 선택 시 호출되는 메소드
  void handleMenuSelection(String menuLabel) {
    MenuOption? selectedOption = labelToOptionMap[menuLabel];
    if (selectedOption == null) {
      // 선택된 메뉴에 해당하는 패널이 없는 경우,
      if (isPanelVisible) {
        setState(() {
          selectedMenu = '';
          isPanelVisible = false;
          currentPanel = Container();
        });
      }
      return;
    }

    // 동일한 메뉴 선택 시 패널 토글
    if (menuLabel == selectedMenu) {
      setState(() {
        if (isPanelVisible) {
          // 패널 숨기기 (슬라이드 아웃)
          isPanelVisible = false;
        } else {
          // 패널 표시 (슬라이드 인)
          panelWidth = panelMap[selectedOption]!.item2;
          isPanelVisible = true;
        }
      });
      return;
    }

    // 다른 메뉴 선택 시 패널 전환
    setState(() {
      selectedMenu = menuLabel;
      panelWidth = panelMap[selectedOption]!.item2;
      currentPanel = panelMap[selectedOption]!.item1;
      isPanelVisible = true;
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
            // 메인 콘텐츠
            const Column(
              children: [
                TopPanel(),
                Expanded(
                  child: WorkArea(),
                ),
              ],
            ),
            // 애니메이션 패널
            AnimatedPositioned(
              left: isPanelVisible ? 48.0 : -panelWidth, // 패널이 열리면 48, 닫히면 화면 밖으로 이동
              top: 48,
              bottom: 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: panelWidth,  // 패널 너비 설정
                curve: Curves.easeInOut,
                color: Colors.white,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: isPanelVisible
                      ? KeyedSubtree(
                          key: ValueKey<String>(selectedMenu),
                          child: currentPanel,
                        )
                      : Container(),
                ),
              ),
            ),
            // 오른쪽 프로퍼티 패널
            const Positioned(
              right: 0,
              top: 48,
              bottom: 0,
              child: PropertyPanel(),
            ),
            // 사이드바 메뉴 (패널보다 나중에 선언하여 최상위로)
            Positioned(
              top: 48,
              bottom: 0,
              left: 0,
              child: SidebarMenu(
                onMenuButtonPressed: handleMenuSelection,
                selectedMenu: selectedMenu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
