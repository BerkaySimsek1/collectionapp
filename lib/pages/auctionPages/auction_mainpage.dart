import 'package:collectionapp/countdown_timer.dart';
import 'package:collectionapp/pages/auctionPages/auction_detail.dart';
import 'package:collectionapp/pages/auctionPages/create_auction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/AuctionModel.dart';

class AuctionListScreen extends StatefulWidget {
  const AuctionListScreen({Key? key}) : super(key: key);

  @override
  _AuctionListScreenState createState() => _AuctionListScreenState();
}

class _AuctionListScreenState extends State<AuctionListScreen> {
  String _filter = 'all';

  Stream<QuerySnapshot> _getAuctionStream() {
    final collection = FirebaseFirestore.instance.collection('auctions');
    if (_filter == 'active') {
      return collection.where('isAuctionEnd', isEqualTo: false).snapshots();
    } else if (_filter == 'ended') {
      return collection.where('isAuctionEnd', isEqualTo: true).snapshots();
    } else {
      return collection.snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auctions"),
        leading: TextButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          child: const Text(
            "Log out",
            style: TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AuctionUploadScreen()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _filter = 'all'),
                child: const Text("All"),
              ),
              TextButton(
                onPressed: () => setState(() => _filter = 'active'),
                child: const Text("Active"),
              ),
              TextButton(
                onPressed: () => setState(() => _filter = 'ended'),
                child: const Text("Ended"),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getAuctionStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("There is no auction yet."));
                }

                final auctionDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: auctionDocs.length,
                  itemBuilder: (context, index) {
                    final auctionData =
                        auctionDocs[index].data() as Map<String, dynamic>;
                    final auction = AuctionModel.fromMap(auctionData);

                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AuctionDetail(auction: auction)),
                        );
                      },
                      leading: FutureBuilder(
                        future: precacheImage(
                            NetworkImage(auction.imageUrls.first), context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Icon(Icons.error);
                          } else {
                            return Image.network(
                              auction.imageUrls.first,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            );
                          }
                        },
                      ),
                      title: Text(auction.name),
                      subtitle: CountdownTimer(
                        endTime: auction.endTime,
                        auctionId: auction.id,
                      ),
                      trailing: Text(
                          "Current bid: ${auction.startingPrice.toInt()}\$ "),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
