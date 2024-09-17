import 'package:flutter/material.dart';
import './ui/theme.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/selected_widget_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedWidgetModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'uxzero',
      theme: AppTheme.lightTheme, // 라이트 테마 적용
      darkTheme: AppTheme.darkTheme, // 다크 테마 적용
      themeMode: ThemeMode.light, // 테마 모드 설정 (light, dark, system)
      home: const HomeScreen(),
    );
  }
}
