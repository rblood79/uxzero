import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class NodePanel extends StatelessWidget {

  NodePanel({super.key});

  static double getPanelWidth() {
    return 320.0; // WidgetPanel의 너비
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: const Center(
              child: Text(
                'Node',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
