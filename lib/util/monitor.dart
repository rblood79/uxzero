import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FrameRateMonitor extends StatefulWidget {
  const FrameRateMonitor({super.key});

  @override
  _FrameRateMonitorState createState() => _FrameRateMonitorState();
}

class _FrameRateMonitorState extends State<FrameRateMonitor>
    with WidgetsBindingObserver {
  Ticker? _ticker;
  int _frameCount = 0;
  int _lastFrameTime = 0;
  double _fps = 0.0;
  final List<double> _fpsHistory = [];
  final int _maxHistoryLength = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration duration) {
    int currentTime = duration.inMilliseconds;
    _frameCount++;

    int elapsed = currentTime - _lastFrameTime;
    // 더 자주 프레임을 계산하기 위해 500ms로 간격 변경
    if (elapsed >= 500) {
      setState(() {
        // FPS를 0.5초(500ms) 동안의 프레임 수로 계산
        _fps = (_frameCount / elapsed) * 1000;
        _frameCount = 0;
        _lastFrameTime = currentTime;

        // FPS 히스토리 업데이트
        if (_fpsHistory.length >= _maxHistoryLength) {
          _fpsHistory.removeAt(0);
        }
        _fpsHistory.add(_fps);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.black54,
        child: Column(
          children: [
            Text(
              '${_fps.toStringAsFixed(1)} FPS',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            
          ],
        ),
      ),
    );
  }
}
