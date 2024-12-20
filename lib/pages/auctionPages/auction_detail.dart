import 'package:collectionapp/design_elements.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/countdown_timer.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:collectionapp/models/UserInfoModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';

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
      }
    } catch (e) {
      debugPrint("Hata oluştu: $e");
    }
  }

  Future<void> _showPhotoDialog(String imageUrl) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBidDialog() async {
    double? newBid;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Place Your Bid',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Minimum Bid: \$${widget.auction.startingPrice + 1}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                    const SnackBar(content: Text('Invalid bid!')),
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
      backgroundColor: Colors.grey[200],
      appBar: ProjectAppbar(
        titletext: widget.auction.name,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Horizontal image carousel
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: PageView.builder(
                itemCount: widget.auction.imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                        _showPhotoDialog(widget.auction.imageUrls[index]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.auction.imageUrls[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          return progress == null
                              ? child
                              : Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            //auction details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.auction.description,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        text: 'Price: ',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black87),
                        children: [
                          TextSpan(
                            text:
                                '\$${widget.auction.startingPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bidderInfo != null
                          ? "Last Bidder: ${bidderInfo!.firstName}"
                          : "No bids yet",
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      creatorInfo != null
                          ? "Created by: ${creatorInfo!.firstName}"
                          : "",
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.deepPurple),
                const SizedBox(width: 8),
                CountdownTimer(
                  endTime: widget.auction.endTime,
                  auctionId: widget.auction.id,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: (user.uid != widget.auction.creatorId)
          ? GestureDetector(
              onTap: _showBidDialog,
              child: const FinalFloatingDecoration(
                buttonText: "Place a Bid",
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
