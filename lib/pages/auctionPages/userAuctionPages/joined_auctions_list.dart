import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: unused_element
class JoinedAuctionsList extends StatelessWidget {
  final String userUid;
  const JoinedAuctionsList({Key? key, required this.userUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userDocRef =
        FirebaseFirestore.instance.collection("users").doc(userUid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDocRef.snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("Kullanıcı bulunamadı."));
        }

        final userData = userSnapshot.data!;
        final List<dynamic> joinedAuctions = userData["joinedAuctions"] ?? [];

        if (joinedAuctions.isEmpty) {
          return const Center(child: Text("Hiç katıldığın auction yok."));
        }

        // auctions koleksiyonundan ID’leri joinedAuctions listesinde olanları çekelim
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("auctions")
              .where(FieldPath.documentId, whereIn: joinedAuctions)
              .snapshots(),
          builder: (context, auctionsSnapshot) {
            if (auctionsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!auctionsSnapshot.hasData) {
              return const Center(child: Text("No data."));
            }

            final docs = auctionsSnapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text("No auctions found."));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final auctionDoc = docs[index];
                final auctionData = auctionDoc.data() as Map<String, dynamic>;
                final auctionName = auctionData["name"] ?? "";
                final auctionId = auctionDoc.id;
                final isAuctionEnd = auctionData["isAuctionEnd"] ?? false;
                final highestBidderId = auctionData["highestBidderId"] ?? "";

                // Kontrol: Auction bitmiş VE kullanıcı highest bidder değil ise => listeden sil
                if (isAuctionEnd && highestBidderId != userUid) {
                  _removeAuctionFromJoined(userUid, auctionId);
                }

                return ListTile(
                  title: Text(auctionName),
                  subtitle: Text("Auction ID: $auctionId"),
                  // Burada isterseniz "X gün kaldı" vs. gibi bilgiler de gösterebilirsiniz
                );
              },
            );
          },
        );
      },
    );
  }

  /// Auction bitmiş ve kullanıcı kaybetmişse, user dokümanındaki joinedAuctions'tan çıkar.
  Future<void> _removeAuctionFromJoined(
      String userUid, String auctionId) async {
    final userDocRef =
        FirebaseFirestore.instance.collection("users").doc(userUid);

    await userDocRef.update({
      "joinedAuctions": FieldValue.arrayRemove([auctionId]),
    });
  }
}
