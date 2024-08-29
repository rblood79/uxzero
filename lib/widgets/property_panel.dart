import 'package:flutter/material.dart';

class PropertyPanel extends StatelessWidget {
  const PropertyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 228,
      child: Container(
        color: Colors.black12,
        child: const Center(child: Text('property')),
      ),
    );
  }
}
