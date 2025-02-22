import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: unused_element
class WonAuctionsList extends StatelessWidget {
  final String userUid;
  const WonAuctionsList({Key? key, required this.userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Yalnızca "highestBidderId = userUid" ve "isAuctionEnd = true" olanları çekiyoruz
    final wonAuctionsQuery = FirebaseFirestore.instance
        .collection("auctions")
        .where("highestBidderId", isEqualTo: userUid)
        .where("isAuctionEnd", isEqualTo: true);

    return StreamBuilder<QuerySnapshot>(
      stream: wonAuctionsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No data."));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("Hiç kazandığın auction yok."));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final auctionData = docs[index].data() as Map<String, dynamic>;
            final auctionName = auctionData["name"] ?? "";
            final auctionId = docs[index].id;

            return ListTile(
              title: Text(auctionName),
              subtitle: Text("Auction ID: $auctionId (Kazandın!)"),
            );
          },
        );
      },
    );
  }
}
