import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: unused_element
class CreatedAuctionsList extends StatelessWidget {
  final String userUid;
  const CreatedAuctionsList({Key? key, required this.userUid})
      : super(key: key);

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
        // createdAuctions listemizi alıyoruz
        final List<dynamic> createdAuctions = userData["createdAuctions"] ?? [];

        // eğer hiç yoksa basit bir mesaj
        if (createdAuctions.isEmpty) {
          return const Center(child: Text("No auctions found."));
        }

        // auctions koleksiyonundan ID’leri createdAuctions listesinde olanları çekelim
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("auctions")
              .where(FieldPath.documentId, whereIn: createdAuctions)
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
                final auctionData = docs[index].data() as Map<String, dynamic>;
                // AuctionModel.fromMap(auctionData) yapabilirsiniz
                final auctionName = auctionData["name"] ?? "";
                final auctionId = docs[index].id;

                return ListTile(
                  title: Text(auctionName),
                  subtitle: Text("Auction ID: $auctionId"),
                );
              },
            );
          },
        );
      },
    );
  }
}
