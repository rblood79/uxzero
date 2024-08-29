import 'package:flutter/material.dart';
import '../widgets/widget_panel.dart';  // WidgetPanel import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(28.0), // 원하는 높이로 설정
        child: AppBar(
          title: const Text('UXZERO'),
          elevation: 4,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: Container(
              color: Colors.blue,
              child: const Center(child: Text('Top Area')),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // widget 부분
                WidgetPanel(), // 분리된 WidgetPanel을 사용
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: const Center(child: Text('work')),
                  ),
                ),
                SizedBox(
                  width: 228,
                  child: Container(
                    color: Colors.redAccent,
                    child: const Center(child: Text('property')),
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
    );
  }
}
