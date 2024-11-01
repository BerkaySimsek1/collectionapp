import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;

  const CountdownTimer({super.key, required this.endTime});

  @override
  // ignore: library_private_types_in_public_api
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer; // Timer'ı nullable yaptık
  Duration _remainingDuration = const Duration();

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemainingTime();
    });
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    setState(() {
      _remainingDuration = widget.endTime.difference(now);
      if (_remainingDuration.isNegative) {
        _timer?.cancel(); // Süre dolduğunda timer'ı durdur
        _remainingDuration = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Null kontrolü ile timer'ı iptal et
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remainingDuration.inHours;
    final minutes = _remainingDuration.inMinutes % 60;
    final seconds = _remainingDuration.inSeconds % 60;

    var timerText = "";
    if (hours == 0 && minutes == 0 && seconds == 0) {
      timerText = ("The auction has ended.");
    } else {
      if (hours != 1) {
        timerText =
            ("$hours:${minutes < 10 ? "0$minutes" : minutes}:${seconds < 10 ? "0$seconds" : seconds}");
      } else {
        timerText = ("$minutes:$seconds left");
      }
    }
    return Text(timerText);
  }
}
