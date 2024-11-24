import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:collectionapp/pages/auctionPages/auction_detail.dart';
import 'package:collectionapp/pages/auctionPages/create_auction.dart';
import 'package:collectionapp/countdown_timer.dart';

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
        title: const Text(
          "Auctions",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
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
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[200],
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilterButton(
                    label: "All",
                    isSelected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  FilterButton(
                    label: "Active",
                    isSelected: _filter == 'active',
                    onTap: () => setState(() => _filter = 'active'),
                  ),
                  FilterButton(
                    label: "Ended",
                    isSelected: _filter == 'ended',
                    onTap: () => setState(() => _filter = 'ended'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getAuctionStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "There is no auction yet.",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }

                  final auctionDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: auctionDocs.length,
                    itemBuilder: (context, index) {
                      final auctionData =
                          auctionDocs[index].data() as Map<String, dynamic>;
                      final auction = AuctionModel.fromMap(auctionData);

                      return AuctionCard(auction: auction);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class AuctionCard extends StatelessWidget {
  final AuctionModel auction;

  const AuctionCard({Key? key, required this.auction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AuctionDetail(auction: auction)),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            auction.imageUrls.first,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red),
          ),
        ),
        title: Text(
          auction.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: CountdownTimer(
          endTime: auction.endTime,
          auctionId: auction.id,
        ),
        trailing: Text(
          "Highest bid: ${auction.startingPrice.toInt()}\$",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}
