import 'package:collectionapp/countdown_timer.dart';
import 'package:collectionapp/pages/auctionPages/auction_detail.dart';
import 'package:collectionapp/pages/auctionPages/create_auction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:lottie/lottie.dart';

class AuctionListScreen extends StatelessWidget {
  const AuctionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Auctions"),
          leading: Row(
            children: [
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
          )),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('auctions').snapshots(),
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

              // AuctionModel’den bir nesne oluşturun
              final auction = AuctionModel.fromMap(auctionData);

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuctionDetail(
                              auction: auction,
                            )),
                  );
                },
                leading: FutureBuilder(
                  future:
                      precacheImage(NetworkImage(auction.imageUrl), context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Lottie.asset(
                        'assets/loading.json',
                        width: 50,
                        height: 50,
                      );
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error);
                    } else {
                      return Image.network(
                        auction.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      );
                    }
                  },
                ),
                title: Text(auction.name),
                subtitle: CountdownTimer(endTime: auction.endTime),
                trailing:
                    Text("Current bid: ${auction.startingPrice.toInt()}\$ "),
              );
            },
          );
        },
      ),
    );
  }
}
