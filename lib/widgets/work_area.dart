import 'package:flutter/material.dart';

class WorkArea extends StatelessWidget {
  const WorkArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: const Center(child: Text('work')),
      ),
    );
  }
}
