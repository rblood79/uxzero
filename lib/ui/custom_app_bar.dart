import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(28.0), // 원하는 높이로 설정
      child: AppBar(
        leadingWidth: 300, // 왼쪽에 배치될 버튼의 넓이를 설정
        leading: Row(
          children: [
            TextButton(
              onPressed: () {
                // "파일" 버튼을 눌렀을 때의 동작
                print('파일 clicked');
              },
              child: const Text('파일', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                // "편집" 버튼을 눌렀을 때의 동작
                print('편집 clicked');
              },
              child: const Text('편집', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                // "전환" 버튼을 눌렀을 때의 동작
                print('전환 clicked');
              },
              child: const Text('전환', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                // "보기" 버튼을 눌렀을 때의 동작
                print('보기 clicked');
              },
              child: const Text('보기', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                // "도움말" 버튼을 눌렀을 때의 동작
                print('도움말 clicked');
              },
              child: const Text('도움말', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        title: const Text('UXZERO'),
        centerTitle: true, // 타이틀을 화면의 정중앙에 배치
        elevation: 4,
        backgroundColor: Colors.white, // AppBar 배경을 흰색으로 설정
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(28.0);
}
