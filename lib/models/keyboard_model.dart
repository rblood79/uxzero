import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KeyboardModel extends ChangeNotifier {
  bool _isSpacePressed = false;

  bool get isSpacePressed => _isSpacePressed;

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.space) {
      _isSpacePressed = true;
      notifyListeners();
    } else if (event is KeyUpEvent &&
        event.logicalKey == LogicalKeyboardKey.space) {
      _isSpacePressed = false;
      notifyListeners();
    }
  }
}
