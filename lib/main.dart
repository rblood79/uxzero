import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart'; // firebase_options.dart를 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 현재 플랫폼에 적합한 FirebaseOptions 사용
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const LoginScreen(),
      home: const HomeScreen(),
    );
  }
}
