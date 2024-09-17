// lib/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // 라이트 테마 정의
  static ThemeData lightTheme = ThemeData(
    //primaryColor: Colors.teal,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.grey[100],
      onPrimary: Colors.red,
      onSecondary: Colors.orange,
      onSurface: Colors.blue,
    ),

    appBarTheme: const AppBarTheme(
      //backgroundColor: Colors.red,
      titleTextStyle: TextStyle(
          //color: Colors.white,
          //fontSize: 14.0,
          ),
      iconTheme: IconThemeData(
          //color: Colors.white,
          ),
    ),

// TextTheme을 사용해 입력 텍스트 색상을 정의
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.black87, // 기본 입력 텍스트 색상
        fontSize: 14.0,
      ),
    ),

    // 버튼 테마 정의
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // 모서리를 사각형으로
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.3); // ripple 효과 색상
            }
            return null; // 기본 색상
          },
        ),
        /*padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 패딩 설정
        ),
        minimumSize: WidgetStateProperty.all<Size>(
          const Size(150, 50), // 최소 크기 설정
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey; // 비활성화 시 배경색
            }
            return Colors.blue; // 기본 배경색
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white; // 눌렸을 때 텍스트 색상
            }
            return Colors.black; // 기본 텍스트 색상
          },
        ),*/
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // 사각형 모서리
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.3); // ripple 효과 색상 설정
            }
            return null;
          },
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // 사각형 모서리
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.3); // ripple 효과 색상 설정
            }
            return null;
          },
        ),
      ),
    ),

    // 텍스트 필드 스타일 정의
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0, // 가로 패딩
        vertical: 4.0, // 세로 패딩
      ),
      filled: true,
      fillColor: Colors.white, // 배경색 설정
      labelStyle: const TextStyle(
        color: Colors.black87, // 라벨 텍스트 색상
      ),
      hintStyle: const TextStyle(
        color: Colors.grey, // 힌트 텍스트 스타일
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0), // 모서리 둥글게
        borderSide: const BorderSide(
          color: Colors.black12, // 활성화된 테두리 색상
          width: 1.0,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        //borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
          color: Colors.blueAccent, // 포커스된 테두리 색상
          width: 1,
        ),
      ),
    ),

    // 슬라이드 테마 정의
    sliderTheme: SliderThemeData(
      activeTrackColor: Colors.blueAccent,
      inactiveTrackColor: Colors.grey[100],
      thumbColor: Colors.blueAccent,
    ),
  );

  // 다크 테마 정의
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    //primaryColor: Colors.blueGrey,
    //colorScheme: const ColorScheme.dark().copyWith(secondary: Colors.orange),
    appBarTheme: const AppBarTheme(
      //backgroundColor: Colors.blueGrey,
      titleTextStyle: TextStyle(
          //color: Colors.white,
          //fontSize: 20.0,
          ),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        color: Colors.white70,
      ),
    ),
    // 버튼 테마 정의
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // 모서리를 사각형으로
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.3); // ripple 효과 색상 설정
            }
            return null; // 기본 색상
          },
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // 사각형 모서리
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.3); // ripple 효과 색상 설정
            }
            return null;
          },
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // 사각형 모서리
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.3); // ripple 효과 색상 설정
            }
            return null;
          },
        ),
      ),
    ),
  );
}
