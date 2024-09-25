import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/selected_widget_model.dart';
import 'models/keyboard_model.dart';
import 'screens/home_screen.dart';
import './ui/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SelectedWidgetModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => KeyboardModel(),
        ),
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
