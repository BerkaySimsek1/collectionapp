import 'package:collectionapp/pages/auctionPages/create_auction.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/AuctionModel.dart';

class AuctionListScreen extends StatelessWidget {
  const AuctionListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Auctions"),
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuctionUploadScreen()));
            },
            icon: const Icon(Icons.add)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('auctions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Henüz açık artırma yok"));
          }

          final auctionDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: auctionDocs.length,
            itemBuilder: (context, index) {
              final auctionData =
                  auctionDocs[index].data() as Map<String, dynamic>;

              // AuctionModel’den bir nesne oluşturun
              final auction = AuctionModel.fromMap(auctionData);

              // Kalan süreyi hesaplayın
              final remainingDuration =
                  auction.endTime.difference(DateTime.now());
              final hoursLeft = remainingDuration.inHours;
              final minutesLeft = remainingDuration.inMinutes % 60;

              return ListTile(
                leading: auction.imageUrl != null
                    ? Image.network(auction.imageUrl,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.image, size: 50),
                title: Text(auction.name ?? "İsim Yok"),
                subtitle:
                    Text("Kalan süre: $hoursLeft saat $minutesLeft dakika"),
              );
            },
          );
        },
      ),
    );
  }
}
