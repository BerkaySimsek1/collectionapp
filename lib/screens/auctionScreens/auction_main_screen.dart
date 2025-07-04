import "package:collectionapp/designElements/common_ui_methods.dart";
import 'package:collectionapp/viewModels/auction_viewmodel.dart';
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/models/auction_model.dart";
import "package:collectionapp/screens/auctionScreens/auction_detail_screen.dart";
import "package:collectionapp/screens/auctionScreens/create_auction_screen.dart";
import "package:collectionapp/designElements/widgets/countdown_timer_widget.dart";
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AuctionMainScreen extends StatefulWidget {
  const AuctionMainScreen({super.key});

  @override
  State<AuctionMainScreen> createState() => _AuctionMainScreenState();
}

class _AuctionMainScreenState extends State<AuctionMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = "newest"; // Default sort option
  String _selectedFilter = "all"; // Default filter option

  // Sort options için helper method
  String getSortLabel(String sortValue) {
    switch (sortValue) {
      case "newest":
        return "Newest";
      case "oldest":
        return "Oldest";
      case "name_az":
        return "A-Z";
      case "name_za":
        return "Z-A";
      default:
        return "Newest";
    }
  }

  // Filter options için helper method
  String getFilterLabel(String filterValue) {
    switch (filterValue) {
      case "all":
        return "All";
      case "active":
        return "Active";
      case "ended":
        return "Ended";
      default:
        return "All";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuctionViewModel(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Auctions",
            style: GoogleFonts.poppins(
              color: Colors.deepPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: const ProjectIconButton(),
        ),
        body: Consumer<AuctionViewModel>(
          builder: (context, auctionViewModel, child) {
            // ViewModel'den güncel değerleri al
            _selectedSort = auctionViewModel.sort;
            _selectedFilter = auctionViewModel.filter;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      buildSearchWidget(
                        controller: _searchController,
                        onChanged: (value) {
                          auctionViewModel.updateSearchQuery(value);
                        },
                        onClear: () {
                          _searchController.clear();
                          auctionViewModel.updateSearchQuery("");
                        },
                        hintText: "Search auctions...",
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),

                      // Filter and Sort Buttons
                      Row(
                        children: [
                          Expanded(
                            child: buildActionButton(
                              icon: Icons.sort,
                              label: getSortLabel(_selectedSort),
                              onTap: () =>
                                  _showSortDialog(context, auctionViewModel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: buildActionButton(
                              icon: Icons.filter_list,
                              label: getFilterLabel(_selectedFilter),
                              onTap: () =>
                                  _showFilterDialog(context, auctionViewModel),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ), // Auctions List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: auctionViewModel.getAuctionStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Loading auctions...",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.deepPurple.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.gavel_outlined,
                                  size: 64,
                                  color:
                                      Colors.deepPurple.withValues(alpha: 0.75),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No auctions found",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Create your first auction",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final List<DocumentSnapshot> auctionDocs =
                          snapshot.data!.docs;
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
                        padding: const EdgeInsets.all(16),
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
              ],
            );
          },
        ),
        floatingActionButton: ProjectFloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateAuctionScreen()),
            );
          },
          title: "Create Auction",
          icon: Icons.gavel_outlined,
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context, AuctionViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sort,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Sort By",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSortOption(context, viewModel, "newest", "Newest First"),
              _buildSortOption(context, viewModel, "oldest", "Oldest First"),
              _buildSortOption(context, viewModel, "name_az", "Name (A-Z)"),
              _buildSortOption(context, viewModel, "name_za", "Name (Z-A)"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    AuctionViewModel viewModel,
    String value,
    String label,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          viewModel.updateSort(value);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(
                viewModel.sort == value
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: viewModel.sort == value
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, AuctionViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Filter By",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildFilterButton(
                      label: "All",
                      isSelected: viewModel.filter == "all",
                      onTap: () {
                        viewModel.updateFilter("all");
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFilterButton(
                      label: "Active",
                      isSelected: viewModel.filter == "active",
                      onTap: () {
                        viewModel.updateFilter("active");
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFilterButton(
                      label: "Ended",
                      isSelected: viewModel.filter == "ended",
                      onTap: () {
                        viewModel.updateFilter("ended");
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
            ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            debugPrint(
                "${DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch}");

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuctionDetailScreen(auction: auction),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      auction.imageUrls.first,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.deepPurple,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Failed to load image",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: auction.isAuctionEnd
                            ? Colors.red.withValues(alpha: 0.9)
                            : Colors.green.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            auction.isAuctionEnd
                                ? Icons.timer_off
                                : Icons.timer,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            auction.isAuctionEnd ? "Ended" : "Active",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      auction.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      auction.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.deepPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          CountdownTimer(
                            endTime: auction.endTime,
                            auctionId: auction.id,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Bid",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: projectLinearGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                "\$${auction.startingPrice.toStringAsFixed(2)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
