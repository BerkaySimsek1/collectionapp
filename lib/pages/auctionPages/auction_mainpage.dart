import 'package:collectionapp/design_elements.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:collectionapp/pages/auctionPages/auction_detail.dart';
import 'package:collectionapp/pages/auctionPages/create_auction.dart';
import 'package:collectionapp/countdown_timer.dart';

class AuctionListScreen extends StatefulWidget {
  const AuctionListScreen({super.key});

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
        backgroundColor: Colors.grey[200],
        appBar: const ProjectAppbar(
          titletext: "Auctions",
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5),
                  color: const Color(0xFFF7F2FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.filter_alt_outlined),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.black,
                    ),
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

        // create auction button
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AuctionUploadScreen()),
            );
          },
          child: const AddFloatingDecoration(
            buttonText: "Create Auction",
          ),
        ));
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(8),
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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
          borderRadius: BorderRadius.circular(8),
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
