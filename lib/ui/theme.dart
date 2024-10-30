// lib/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // 라이트 테마 정의
  static ThemeData lightTheme = ThemeData(
    //primaryColor: Colors.teal,
    /*
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: 애플리케이션의 기본 색상으로, 앱의 많은 부분에서 주로 사용됩니다.
      onPrimary: primary 색상 위에 나타나는 텍스트나 아이콘의 색상.
      primaryContainer: primary 색상의 대조적인 버전으로, UI에서 컨테이너, 카드 등의 배경에 사용됩니다.
      onPrimaryContainer: primaryContainer 색상 위에 나타나는 텍스트나 아이콘의 색상.
      secondary: 보조 색상으로, 주요 UI 요소 외에 보조적인 요소들에 사용됩니다.
      onSecondary: secondary 색상 위에 나타나는 텍스트나 아이콘의 색상.
      secondaryContainer: secondary 색상의 대조적인 버전으로, UI에서 보조적인 컨테이너나 카드 배경 등에 사용됩니다.
      onSecondaryContainer: secondaryContainer 색상 위에 나타나는 텍스트나 아이콘의 색상.
      tertiary: 세 번째 주요 색상으로, 추가적인 강조를 위해 사용됩니다. 보통 색상의 대비를 위한 요소에서 활용됩니다.
      onTertiary: tertiary 색상 위에 나타나는 텍스트나 아이콘의 색상.
      tertiaryContainer: tertiary 색상의 대조적인 버전으로, UI에서 추가적인 배경에 사용됩니다.
      onTertiaryContainer: tertiaryContainer 색상 위에 나타나는 텍스트나 아이콘의 색상.
      error: 오류 상태를 나타내는 색상.
      onError: error 색상 위에 나타나는 텍스트나 아이콘의 색상.
      errorContainer: 오류 상태를 강조하는 배경색.
      onErrorContainer: errorContainer 색상 위에 나타나는 텍스트나 아이콘의 색상.
      surface: 표면 색상. 카드나 시트 같은 표면 요소의 배경색으로 사용됩니다.
      onSurface: surface 색상 위에 나타나는 텍스트나 아이콘의 색상.
      surfaceContainerHighest: surface 색상의 변형된 버전으로, 보다 다양한 색상 팔레트를 제공하여 디자인에 일관성을 줍니다.
      onSurfaceVariant: surfaceVariant 위에 나타나는 텍스트나 아이콘의 색상.
      outline: 버튼이나 카드의 테두리 등에서 사용되는 색상.
      shadow: 그림자 색상.
      inverseSurface: 밝은 테마에서 어두운 색상, 어두운 테마에서 밝은 색상으로 반전된 표면 색상.
      onInverseSurface: inverseSurface 색상 위에 나타나는 텍스트나 아이콘의 색상.
      inversePrimary: 반전된 primary 색상. 어두운 테마에서는 밝은 색상, 밝은 테마에서는 어두운 색상을 사용하여 대비를 줍니다.
      surfaceTint: surface 색상에 적용되는 색조.
    ),
    */

    /*colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.redAccent, // 여기에 seedColor 지정
      brightness: Brightness.light, // 라이트 테마 설정
    ),*/

    appBarTheme: const AppBarTheme(
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
      //activeTrackColor: Colors.blueAccent,
      inactiveTrackColor: Colors.grey[100],
      //thumbColor: Colors.blueAccent,
    ),
  );

  // 다크 테마 정의
  static ThemeData darkTheme = ThemeData(
    /*colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red, // 여기에 seedColor 지정
      brightness: Brightness.light, // 라이트 테마 설정
    ),*/
    
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
