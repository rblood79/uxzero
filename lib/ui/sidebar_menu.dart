import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class SidebarMenu extends StatelessWidget {
  final List<MenuItem> menuItems = [
    MenuItem(icon: Remix.file_line, label: 'Site'),
    MenuItem(icon: Remix.square_line, label: 'Widget'),
    MenuItem(icon: Remix.node_tree, label: 'Node'),
    MenuItem(icon: Remix.database_2_line, label: 'Data'),
    MenuItem(icon: Remix.book_3_line, label: 'Library'),
    MenuItem(icon: Remix.account_circle_line, label: 'User'),
    MenuItem(icon: Remix.settings_line, label: 'Setting'),
  ];

  final Function(String) onMenuButtonPressed;
  final String selectedMenu;
  final bool isPanelVisible; // 현재 선택된 메뉴

  SidebarMenu({
    super.key,
    required this.onMenuButtonPressed,
    required this.selectedMenu,
    required this.isPanelVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, // 사이드바의 전체 너비
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: Colors.white, // 배경색
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(4, 0),
          ),
        ],
        border: const Border(
          right: BorderSide(
            // 오른쪽에만 테두리 적용
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // 아이템을 중앙 정렬
        children: [
          // 첫 번째 그룹: 상단에 배치될 메뉴 항목들
          ...menuItems.sublist(0, 5).map((item) => buildMenuItem(context, item)),

          // Flexible을 사용하여 남은 공간을 유연하게 차지하도록 함
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: menuItems.sublist(5).map((item) => buildMenuItem(context, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 항목을 빌드하는 헬퍼 메소드
  Widget buildMenuItem(BuildContext context, MenuItem item) {
    bool isSelected = item.label == selectedMenu; // 현재 선택된 메뉴인지 확인

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0.0), // 항목 간 간격 설정
      child: GestureDetector(
        onTap: () {
          onMenuButtonPressed(item.label); // 메뉴 이름을 전달
          //print('${item.label} clicked');
        },
        child: Container(
          width: 48, // 버튼의 너비
          height: 62, // 버튼의 높이
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
          decoration: BoxDecoration(
            color: isPanelVisible && isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary, // 선택된 경우 배경색 변경
            //borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
            /*
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
            */
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(item.icon, size: 21, color: isPanelVisible && isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary),
              //const SizedBox(height: 4.0),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  color: isPanelVisible && isSelected ? Theme.of(context).colorScheme.onPrimary : Colors.grey,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String label;

  MenuItem({required this.icon, required this.label});
}
