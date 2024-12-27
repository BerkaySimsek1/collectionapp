import "package:collectionapp/design_elements.dart";
import 'package:collectionapp/viewModels/auction_viewmodel.dart';
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/models/AuctionModel.dart";
import "package:collectionapp/pages/auctionPages/auction_detail.dart";
import "package:collectionapp/pages/auctionPages/create_auction.dart";
import "package:collectionapp/countdown_timer.dart";
import 'package:provider/provider.dart';

class AuctionListScreen extends StatelessWidget {
  const AuctionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuctionViewModel(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: const ProjectAppbar(
          titleText: "Auctions",
        ),
        body: Consumer<AuctionViewModel>(
          builder: (context, auctionViewModel, child) {
            return Column(
              children: [
                // Filter and Sort UI
                FilterAndSortSection(viewModel: auctionViewModel),
                const SizedBox(height: 4),
                // Auction List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: auctionViewModel.getAuctionStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "There is no auction yet.",
                            style: ProjectTextStyles.subtitleTextStyle,
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
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AuctionUploadScreen()),
            );
          },
          style: ProjectDecorations.elevatedButtonStyle,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Create Auction",
            style: ProjectTextStyles.buttonTextStyle,
          ),
        ),
      ),
    );
  }
}

class FilterAndSortSection extends StatelessWidget {
  final AuctionViewModel viewModel;

  const FilterAndSortSection({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
              offset: Offset(0, 1),
              blurRadius: 1,
              spreadRadius: 0.5,
              color: Colors.grey),
        ],
        color: const Color(0xFFF7F2FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: viewModel.updateSort,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "newest",
                child: Text("Newest"),
              ),
              const PopupMenuItem(
                value: "oldest",
                child: Text("Oldest"),
              ),
              const PopupMenuItem(
                value: "name_az",
                child: Text("Name (A-Z)"),
              ),
              const PopupMenuItem(
                value: "name_za",
                child: Text("Name (Z-A)"),
              ),
            ],
          ),
          Container(
            height: 30,
            width: 1,
            color: Colors.black,
          ),
          FilterButton(
            label: "All",
            isSelected: viewModel.filter == "all",
            onTap: () => viewModel.updateFilter("all"),
          ),
          FilterButton(
            label: "Active",
            isSelected: viewModel.filter == "active",
            onTap: () => viewModel.updateFilter("active"),
          ),
          FilterButton(
            label: "Ended",
            isSelected: viewModel.filter == "ended",
            onTap: () => viewModel.updateFilter("ended"),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton(
      {super.key,
      required this.label,
      required this.isSelected,
      required this.onTap});

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

  const AuctionCard({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AuctionDetail(auction: auction)),
            );
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.network(
                auction.imageUrls.first,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
          title: Text(
            auction.name,
            style: ProjectTextStyles.cardHeaderTextStyle,
          ),
          subtitle: CountdownTimer(
            endTime: auction.endTime,
            auctionId: auction.id,
          ),
          trailing: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                const Text(
                  "Highest bid:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      "${auction.startingPrice.toInt()}\$",
                      style: ProjectTextStyles.buttonTextStyle,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
