import 'package:flutter/material.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.fontSize,
  });

  final double width;
  final double height;
  final Color color;
  final double fontSize;

  @override
  _WorkAreaState createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  late double _width;
  late double _height;
  late Color _backgroundColor;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _width = widget.width;
    _height = widget.height;
    _backgroundColor = widget.color;
    _fontSize = widget.fontSize;
  }

  @override
  void didUpdateWidget(covariant WorkArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      setState(() {
        _width = widget.width;
        _height = widget.height;
      });
    }
    if (oldWidget.color != widget.color) {
      setState(() {
        _backgroundColor = widget.color;
      });
    }
    if (oldWidget.fontSize != widget.fontSize) {
      setState(() {
        _fontSize = widget.fontSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.grey[200], // WorkArea의 전체 배경을 회색으로 설정
        child: Center(
          child: Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              color: _backgroundColor,
              border: Border.all(
                color: Colors.black, // 테두리 색상
                width: 2.0, // 테두리 두께
              ),
              borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게 처리
            ),
            child: Center(
              child: Text(
                'Work Area',
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
