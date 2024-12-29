import "dart:async";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/design_elements.dart";
import "package:flutter/material.dart";

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final String auctionId;

  const CountdownTimer(
      {super.key, required this.endTime, required this.auctionId});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _remainingDuration = const Duration();
  bool _isAuctionEnded = false;
  StreamSubscription<DocumentSnapshot>? _auctionSubscription;

  @override
  void initState() {
    super.initState();
    _listenAuctionStatus();
    _calculateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemainingTime();
    });
  }

  void _listenAuctionStatus() {
    _auctionSubscription = FirebaseFirestore.instance
        .collection("auctions")
        .doc(widget.auctionId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          _isAuctionEnded = data["isAuctionEnd"] ?? false;
        });
      }
    });
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final remaining = widget.endTime.difference(now);

    if (remaining.isNegative) {
      if (!_isAuctionEnded) {
        _endAuction();
      }
      _timer?.cancel();
      setState(() {
        _remainingDuration = Duration.zero;
        _isAuctionEnded = true;
      });
    } else {
      setState(() {
        _remainingDuration = remaining;
      });
    }
  }

  Future<void> _endAuction() async {
    try {
      await FirebaseFirestore.instance
          .collection("auctions")
          .doc(widget.auctionId)
          .update({"isAuctionEnd": true});
    } catch (e) {
      debugPrint("Failed to end auction: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _auctionSubscription?.cancel(); // Firestore dinleyicisini iptal et
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (_isAuctionEnded || duration.inSeconds <= 0) {
      return "This auction has ended.";
    } else if (days > 0) {
      return "$days days $hours hours";
    } else if (hours > 0) {
      return "$hours hours $minutes minutes";
    } else if (minutes > 0) {
      return "$minutes minutes $seconds seconds";
    } else {
      return "$seconds seconds";
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerText = _formatDuration(_remainingDuration);

    return Text(
      timerText,
      style: ProjectTextStyles.cardDescriptionTextStyle,
    );
  }
}
