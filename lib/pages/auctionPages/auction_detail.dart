import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/countdown_timer.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:collectionapp/models/UserInfoModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuctionDetail extends StatefulWidget {
  final AuctionModel auction;

  const AuctionDetail({super.key, required this.auction});

  @override
  _AuctionDetailState createState() => _AuctionDetailState();
}

class _AuctionDetailState extends State<AuctionDetail> {
  final user = FirebaseAuth.instance.currentUser!;
  UserInfoModel? currentUser;
  UserInfoModel? creatorInfo;
  UserInfoModel? bidderInfo;

  @override
  void initState() {
    super.initState();
    // creator ve bidder bilgilerini al
    getUserInfo(user.uid, (info) => currentUser = info);
    getUserInfo(widget.auction.creatorId, (info) => creatorInfo = info);
    if (widget.auction.bidderId.isNotEmpty) {
      getUserInfo(widget.auction.bidderId, (info) => bidderInfo = info);
    }
  }

  void getUserInfo(String userId, Function(UserInfoModel) onSuccess) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        setState(() {
          onSuccess(UserInfoModel.fromJson(doc.data() as Map<String, dynamic>));
        });
      } else {
        print("Kullanıcı bulunamadı: $userId");
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  Future<void> _showBidDialog() async {
    double? newBid;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Your Bid'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Current Price: \$${widget.auction.startingPrice + 1}',
            ),
            onChanged: (value) {
              newBid = double.tryParse(value);
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newBid != null && newBid! > widget.auction.startingPrice) {
                  await FirebaseFirestore.instance
                      .collection('auctions')
                      .doc(widget.auction.id)
                      .update({
                    'starting_price': newBid,
                    'bidder_id': user.uid,
                  });
                  setState(() {
                    widget.auction.startingPrice = newBid!;
                    widget.auction.bidderId = user.uid;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid bid!')),
                  );
                }
              },
              child: const Text('Submit Bid'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.auction.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.auction.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.auction.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Price: \$${widget.auction.startingPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            bidderInfo != null
                ? Text("Last bidder: ${bidderInfo!.firstName}")
                : const Text("No one bidded yet"),
            const SizedBox(height: 8),
            creatorInfo != null
                ? Text("Auction created by: ${creatorInfo!.firstName}")
                : const Text(""),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Time Left: ',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                CountdownTimer(endTime: widget.auction.endTime),
              ],
            ),
            const Spacer(),
            (user.uid != widget.auction.creatorId)
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showBidDialog,
                      child: const Text("Make Bid"),
                    ),
                  )
                : const Text(""),
          ],
        ),
      ),
    );
  }
}
