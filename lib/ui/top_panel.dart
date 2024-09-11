import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
class TopPanel extends StatelessWidget {
  const TopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Container(
        color: Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 4.0), // 좌우 패딩 설정
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽 끝에 배치
          children: [
            // 왼쪽에 홈 아이콘
            IconButton(
              icon: const Icon(Remix.home_5_fill, color: Colors.black),
              onPressed: () {
                // 홈 아이콘 클릭 시 동작
                print('Home icon clicked');
              },
            ),
            // 오른쪽에 콤보 박스
            
          ],
        ),
      ),
    );
  }
}
