import 'package:flutter/material.dart';

class ContainerWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final String label;

  const ContainerWidget({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black,
          width: 0.0,
        ),
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
