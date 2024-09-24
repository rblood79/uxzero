import 'dart:math';

class UID {
  static final _random = Random();

  /// 고유한 ID를 생성합니다.
  /// [length]는 생성할 ID의 길이를 지정합니다.
  static String generate({int length = 16}) {
    const availableChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 무작위로 문자열을 생성
    final randomString = List.generate(length, (index) {
      return availableChars[_random.nextInt(availableChars.length)];
    }).join('');

    // 타임스탬프와 랜덤 문자열을 결합하여 고유한 ID 생성
    return '$timestamp-$randomString';
  }
}
