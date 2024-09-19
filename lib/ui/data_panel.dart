import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class DataPanel extends StatelessWidget {
  DataPanel({super.key});

  static double getPanelWidth() {
    return 220.0; // WidgetPanel의 너비
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getPanelWidth(),
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), //EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(
              height: 62,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Data',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                ),
              )
          ),
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black12,
                width: 1.0,
              ),
              color: Colors.grey.shade200,
            ),
          ))
        ],
      ),
    );
  }
}
