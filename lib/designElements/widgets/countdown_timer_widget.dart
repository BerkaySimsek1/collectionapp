import "dart:async";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/models/auction_model.dart";
import "package:collectionapp/firebase_methods/notification_methods.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final String auctionId;

  const CountdownTimer(
      {super.key, required this.endTime, required this.auctionId});

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

class CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _remainingDuration = const Duration();
  bool _isAuctionEnded = false;
  StreamSubscription<DocumentSnapshot>? _auctionSubscription;
  final NotificationMethods _notificationMethods = NotificationMethods();

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
      // Önce auction'ın bitip bitmediğini kontrol et
      final auctionDoc = await FirebaseFirestore.instance
          .collection("auctions")
          .doc(widget.auctionId)
          .get();

      if (!auctionDoc.exists || auctionDoc.data()?["isAuctionEnd"] == true) {
        return; // Eğer auction zaten bitmişse işlemi durdur
      }

      // Auction'ı bitir
      await FirebaseFirestore.instance
          .collection("auctions")
          .doc(widget.auctionId)
          .update({"isAuctionEnd": true});

      // Auction bilgilerini al
      final auctionData = auctionDoc.data() as Map<String, dynamic>;
      final creatorId = auctionData['creator_id'] as String;
      final bidderId = auctionData['bidder_id'] as String;
      final auctionName = auctionData['name'] as String;
      final finalPrice = auctionData['starting_price'] as num;

      // Açık artırma sahibine bildirim
      await _notificationMethods.createNotification(
        userId: creatorId,
        auctionId: widget.auctionId,
        title: 'Auction Ended',
        message:
            'Your auction "$auctionName" has ended with final price \$${finalPrice.toStringAsFixed(2)}.',
        type: 'auction_end',
      );

      if (bidderId.isNotEmpty) {
        // En yüksek teklifi veren kişiye kazandı bildirimi
        await _notificationMethods.createNotification(
          userId: bidderId,
          auctionId: widget.auctionId,
          title: 'Congratulations! You Won the Auction',
          message:
              'You won the auction "$auctionName" with your bid of \$${finalPrice.toStringAsFixed(2)}',
          type: 'auction_won',
        );

        // Kaybeden teklif sahiplerine bildirim gönder
        final auctionModel = AuctionModel.fromMap(auctionData);
        final losingBidders = auctionModel.bidHistory
            .map((bid) => bid.userId)
            .toSet()
            .where((userId) => userId != bidderId)
            .toList();

        for (var loserId in losingBidders) {
          await _notificationMethods.createNotification(
            userId: loserId,
            auctionId: widget.auctionId,
            title: 'Auction Ended',
            message:
                'The auction "$auctionName" has ended. Final price was \$${finalPrice.toStringAsFixed(2)}',
            type: 'auction_end',
          );
        }
      }
    } catch (e) {
      debugPrint("Error ending auction: $e");
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
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: Colors.black,
      ),
    );
  }
}
