import 'package:flutter/material.dart';

class ContainerWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final String label;
  
  final dynamic decoration;

  const ContainerWidget({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.label,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.red,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(0.0),
      ),
      
    );
  }
}
