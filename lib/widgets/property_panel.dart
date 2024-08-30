import 'package:flutter/material.dart';

class PropertyPanel extends StatelessWidget {
  final TextEditingController widthController;
  final TextEditingController heightController;
  final TextEditingController colorController;
  final TextEditingController fontSizeController;

  final Function(double, double) onSizeChanged;
  final Function(Color) onColorChanged;
  final Function(double) onFontSizeChanged;

  PropertyPanel({
    super.key,
    required this.widthController,
    required this.heightController,
    required this.colorController,
    required this.fontSizeController,
    required this.onSizeChanged,
    required this.onColorChanged,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 228,
      child: Container(
        color: Colors.black12,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Width and Height input
            TextField(
              controller: widthController,
              decoration: const InputDecoration(labelText: '넓이'),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                final width = double.tryParse(value) ?? 1920;
                final height = double.tryParse(heightController.text) ?? 1080;
                onSizeChanged(width, height);
              },
            ),
            TextField(
              controller: heightController,
              decoration: const InputDecoration(labelText: '높이'),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                final width = double.tryParse(widthController.text) ?? 1920;
                final height = double.tryParse(value) ?? 1080;
                onSizeChanged(width, height);
              },
            ),
            const SizedBox(height: 16.0),

            // Background color input
            TextField(
              controller: colorController,
              decoration: const InputDecoration(labelText: '배경색 (#ffffff)'),
              onSubmitted: (value) {
                final color = _hexToColor(value);
                onColorChanged(color);
              },
            ),
            const SizedBox(height: 16.0),

            // Font size input
            TextField(
              controller: fontSizeController,
              decoration: const InputDecoration(labelText: '텍스트사이즈'),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                final fontSize = double.tryParse(value) ?? 24;
                onFontSizeChanged(fontSize);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 16진수 색상 코드를 Color 객체로 변환하는 함수
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
