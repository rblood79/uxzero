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
  final bool isPanelVisible;

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
          // 상단 메뉴 항목들
          ...menuItems.sublist(0, 5).map((item) => buildMenuItem(context, item)),
          // 하단 메뉴 항목들을 Flexible 영역에 배치
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

  // 개선된 메뉴 항목 빌더: 터치 영역 확대 및 머티리얼 효과를 제공하기 위해 InkWell 사용
  Widget buildMenuItem(BuildContext context, MenuItem item) {
    final bool isSelected = item.label == selectedMenu;
    final Color bgColor = isPanelVisible && isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.transparent; // 선택되지 않은 경우 투명 배경

    final Color iconColor = isPanelVisible && isSelected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.primary;

    final Color textColor = isPanelVisible && isSelected
        ? Theme.of(context).colorScheme.onPrimary
        : Colors.grey;

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: () => onMenuButtonPressed(item.label),
        splashColor: Colors.black12,
        child: Container(
          width: 48, // 버튼의 너비
          height: 62, // 버튼의 높이
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(item.icon, size: 21, color: iconColor),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  color: textColor,
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
