import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final String auctionId; // Auction ID'yi CountdownTimer'a ekledik

  const CountdownTimer(
      {super.key, required this.endTime, required this.auctionId});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
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
        _endAuction(); // Auction bittiğinde Firestore'da güncelleme yap
      }
    });
  }

  Future<void> _endAuction() async {
    try {
      await FirebaseFirestore.instance
          .collection('auctions')
          .doc(widget.auctionId)
          .update({'isAuctionEnd': true});
      debugPrint("Auction ended successfully!");
    } catch (e) {
      debugPrint("Failed to end auction: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Timer'ı iptal et
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remainingDuration.inHours;
    final minutes = _remainingDuration.inMinutes % 60;
    final seconds = _remainingDuration.inSeconds % 60;

    var timerText = "";
    if (hours == 0 && minutes == 0 && seconds == 0) {
      timerText = "This auction has ended.";
    } else {
      timerText =
          "$hours:${minutes < 10 ? "0$minutes" : minutes}:${seconds < 10 ? "0$seconds" : seconds}";
    }
    return Text(timerText);
  }
}
