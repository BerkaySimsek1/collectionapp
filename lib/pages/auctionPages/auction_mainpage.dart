import "package:collectionapp/design_elements.dart";
import 'package:collectionapp/viewModels/auction_viewmodel.dart';
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/models/AuctionModel.dart";
import "package:collectionapp/pages/auctionPages/auction_detail.dart";
import "package:collectionapp/pages/auctionPages/create_auction.dart";
import "package:collectionapp/countdown_timer.dart";
import 'package:provider/provider.dart';

class AuctionListScreen extends StatefulWidget {
  const AuctionListScreen({super.key});

  @override
  State<AuctionListScreen> createState() => _AuctionListScreenState();
}

class _AuctionListScreenState extends State<AuctionListScreen> {
  // arama kısmı sonradan düzenlenecek
  final TextEditingController _searchController = TextEditingController();

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
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 25,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          height: 48,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              auctionViewModel.updateSearchQuery(value);
                            },
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                  width: 0.2,
                                ),
                              ),
                              prefixIconColor: Colors.deepPurple,
                              hintText: "Search auctions",
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: const Icon(
                                Icons.search,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color: Colors.grey[600]),
                                      onPressed: () {
                                        _searchController.clear();
                                        auctionViewModel.updateSearchQuery("");
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: PopupMenuButton<String>(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              icon: const Icon(
                                Icons.sort,
                                color: Colors.deepPurple,
                              ),
                              onSelected: auctionViewModel.updateSort,
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: "newest",
                                  child: Text(
                                    "Newest",
                                    style: ProjectTextStyles.appBarTextStyle
                                        .copyWith(fontSize: 16),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "oldest",
                                  child: Text(
                                    "Oldest",
                                    style: ProjectTextStyles.appBarTextStyle
                                        .copyWith(fontSize: 16),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "name_az",
                                  child: Text(
                                    "Name (A-Z)",
                                    style: ProjectTextStyles.appBarTextStyle
                                        .copyWith(fontSize: 16),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "name_za",
                                  child: Text(
                                    "Name (Z-A)",
                                    style: ProjectTextStyles.appBarTextStyle
                                        .copyWith(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            title: const Text("Filter by",
                                                style: ProjectTextStyles
                                                    .appBarTextStyle),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                FilterButton(
                                                  label: "All",
                                                  isSelected:
                                                      auctionViewModel.filter ==
                                                          "all",
                                                  onTap: () {
                                                    setState(() {
                                                      auctionViewModel
                                                          .updateFilter("all");
                                                    });
                                                  },
                                                ),
                                                const SizedBox(height: 8),
                                                FilterButton(
                                                  label: "Active",
                                                  isSelected:
                                                      auctionViewModel.filter ==
                                                          "active",
                                                  onTap: () {
                                                    setState(() {
                                                      auctionViewModel
                                                          .updateFilter(
                                                              "active");
                                                    });
                                                  },
                                                ),
                                                const SizedBox(height: 8),
                                                FilterButton(
                                                  label: "Ended",
                                                  isSelected:
                                                      auctionViewModel.filter ==
                                                          "ended",
                                                  onTap: () {
                                                    setState(() {
                                                      auctionViewModel
                                                          .updateFilter(
                                                              "ended");
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    });
                              },
                              icon: const Icon(Icons.filter_list,
                                  color: Colors.deepPurple),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // auctions List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: auctionViewModel.getAuctionStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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

                        // Firestore'dan gelen veriler
                        final List<DocumentSnapshot> auctionDocs =
                            snapshot.data!.docs;

                        // Filtreleme ve sıralama
                        final filteredDocs =
                            auctionViewModel.filterAuctions(auctionDocs);

                        filteredDocs.sort((a, b) {
                          final nameA = a['name'].toString().toLowerCase();
                          final nameB = b['name'].toString().toLowerCase();

                          switch (auctionViewModel.sort) {
                            case "newest":
                              return b['created_at'].compareTo(a['created_at']);
                            case "oldest":
                              return a['created_at'].compareTo(b['created_at']);
                            case "name_az":
                              return nameA.compareTo(nameB);
                            case "name_za":
                              return nameB.compareTo(nameA);
                            default:
                              return 0;
                          }
                        });

                        return ListView.builder(
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            final auctionData = filteredDocs[index].data()
                                as Map<String, dynamic>;
                            final auction = AuctionModel.fromMap(auctionData);
                            return AuctionCard(auction: auction);
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AuctionUploadScreen()),
            );
          },
          backgroundColor: Colors.deepPurple,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.network(
                auction.imageUrls.first,
                height: 150,
                width: double.infinity,
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
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AuctionDetail(auction: auction)),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction.name,
                      style: ProjectTextStyles.cardHeaderTextStyle,
                    ),
                    const SizedBox(height: 8),
                    CountdownTimer(
                      endTime: auction.endTime,
                      auctionId: auction.id,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Highest bid:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              "${auction.startingPrice.toInt()}\$",
                              style: ProjectTextStyles.buttonTextStyle
                                  .copyWith(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
