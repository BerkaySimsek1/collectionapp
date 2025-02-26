import 'package:collectionapp/common_ui_methods.dart';
import 'package:collectionapp/pages/profilePages/user_profile_page.dart';
import 'package:collectionapp/viewModels/auction_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:collectionapp/countdown_timer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:google_fonts/google_fonts.dart';

class AuctionDetail extends StatelessWidget {
  final AuctionModel auction;

  const AuctionDetail({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuctionDetailViewModel(auction),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Consumer<AuctionDetailViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.currentUser.uid == auction.creatorId) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<String>(
                      color: Colors.white,
                      icon:
                          const Icon(Icons.more_vert, color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: "Edit",
                          child: Row(
                            children: [
                              const Icon(Icons.edit, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Text(
                                "Edit",
                                style: GoogleFonts.poppins(
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "Delete",
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                "Delete",
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == "Edit") {
                          _showEditDialog(context, viewModel);
                        } else if (value == "Delete") {
                          _showDeleteConfirmation(context, viewModel);
                        }
                      },
                    ),
                  );
                } else {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.flag_outlined, color: Colors.red),
                      onPressed: () => showReportDialog(
                          context, "auction", viewModel.creatorInfo!.uid,
                          auctionId: auction.id),
                      tooltip: "Report Auction",
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: Consumer<AuctionDetailViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Carousel
                  _buildImageCarousel(auction.imageUrls, context),

                  // Content Section
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  auction.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: auction.isAuctionEnd
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      auction.isAuctionEnd
                                          ? Icons.timer_off
                                          : Icons.timer,
                                      size: 16,
                                      color: auction.isAuctionEnd
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      auction.isAuctionEnd ? "Ended" : "Active",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: auction.isAuctionEnd
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Description
                          Text(
                            auction.description,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Price and Timer Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepPurple.shade50,
                                  Colors.deepPurple.shade100,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Current Bid",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.deepPurple.shade400,
                                                Colors.deepPurple.shade700,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.deepPurple
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            "\$${auction.startingPrice.toStringAsFixed(2)}",
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Time Remaining",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        CountdownTimer(
                                          endTime: auction.endTime,
                                          auctionId: auction.id,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Bidder Info
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfilePage(
                                            userId: viewModel.bidderInfo?.uid),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.white,
                                          backgroundImage:
                                              (viewModel.bidderInfo != null &&
                                                      viewModel
                                                          .bidderInfo!
                                                          .profileImageUrl
                                                          .isNotEmpty)
                                                  ? NetworkImage(viewModel
                                                      .bidderInfo!
                                                      .profileImageUrl)
                                                  : null,
                                          child:
                                              (viewModel.bidderInfo == null ||
                                                      viewModel
                                                          .bidderInfo!
                                                          .profileImageUrl
                                                          .isEmpty)
                                                  ? const Icon(
                                                      Icons.person,
                                                      size: 40,
                                                    )
                                                  : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                viewModel.bidderInfo != null
                                                    ? "Current Highest Bidder"
                                                    : "No bids yet",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              if (viewModel.bidderInfo != null)
                                                Text(
                                                  viewModel
                                                      .bidderInfo!.firstName,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Creator Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfilePage(
                                      userId: viewModel.creatorInfo?.uid),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage:
                                        (viewModel.creatorInfo != null &&
                                                viewModel.creatorInfo!
                                                    .profileImageUrl.isNotEmpty)
                                            ? NetworkImage(viewModel
                                                .creatorInfo!.profileImageUrl)
                                            : null,
                                    child: (viewModel.creatorInfo == null ||
                                            viewModel.creatorInfo!
                                                .profileImageUrl.isEmpty)
                                        ? const Icon(
                                            Icons.person,
                                            size: 40,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Seller",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          viewModel.creatorInfo?.firstName ??
                                              "Unknown",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.verified_outlined,
                                          size: 16,
                                          color: Colors.deepPurple,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Verified Seller",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: Consumer<AuctionDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.currentUser.uid != auction.creatorId &&
                !auction.isAuctionEnd) {
              return FloatingActionButton.extended(
                onPressed: () => _showBidDialog(context, viewModel, auction),
                backgroundColor: Colors.deepPurple,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                icon: const Icon(Icons.gavel_outlined, color: Colors.white),
                label: Text(
                  "Place Bid",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

Widget _buildImageCarousel(List<String> imageUrls, BuildContext context) {
  return _ImageCarousel(imageUrls: imageUrls);
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const _ImageCarousel({required this.imageUrls});

  @override
  __ImageCarouselState createState() => __ImageCarouselState();
}

class __ImageCarouselState extends State<_ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image Slider
        Container(
          height: 350,
          width: double.infinity,
          color: Colors.grey[200],
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showPhotoDialog(context, widget.imageUrls[index]),
                child: Hero(
                  tag: 'auction_image_$index',
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.deepPurple,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            "Failed to load image",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Navigation Arrows
        if (widget.imageUrls.length > 1)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavigationButton(
                  icon: Icons.chevron_left,
                  onTap: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
                _buildNavigationButton(
                  icon: Icons.chevron_right,
                  onTap: () {
                    if (_currentPage < widget.imageUrls.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

        // Page Indicator
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.imageUrls.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.deepPurple
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),

        // Zoom Hint
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  "Tap to zoom",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Future<void> _showPhotoDialog(BuildContext context, String initialImageUrl) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Photo View
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: PageView.builder(
                  itemCount: widget.imageUrls.length,
                  controller: PageController(
                    initialPage: widget.imageUrls.indexOf(initialImageUrl),
                  ),
                  itemBuilder: (context, index) {
                    return PhotoView(
                      imageProvider: NetworkImage(widget.imageUrls[index]),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                      backgroundDecoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple.shade400,
                            Colors.deepPurple.shade800,
                          ],
                        ),
                        color: Colors.deepPurple,
                        backgroundBlendMode: BlendMode.srcIn,
                      ),
                      loadingBuilder: (context, event) => Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded /
                                  (event.expectedTotalBytes ?? 1),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Close Button
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showBidDialog(BuildContext context,
    AuctionDetailViewModel viewModel, AuctionModel auction) async {
  double? newBid;
  double minIncrement = viewModel.calculateBidIncrement(auction.startingPrice);
  String? errorMessage;

  return showDialog(
    context: context,
    builder: (BuildContext context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
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
                          color: Colors.deepPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.gavel_outlined,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Place Your Bid",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Price Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Current Price",
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "\$${auction.startingPrice.toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                color: Colors.deepPurple,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Minimum Increment Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Minimum increment: \$${minIncrement.toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                color: Colors.deepPurple,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bid Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: errorMessage != null
                                ? Colors.red
                                : Colors.grey[300]!,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter your bid amount",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[400],
                            ),
                            prefixIcon: Icon(
                              Icons.attach_money,
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: (value) {
                            setState(() {
                              newBid = double.tryParse(value);
                              if (newBid != null &&
                                  newBid! <
                                      auction.startingPrice + minIncrement) {
                                errorMessage =
                                    "Bid must be at least \$${(auction.startingPrice + minIncrement).toStringAsFixed(2)}";
                              } else {
                                errorMessage = null;
                              }
                            });
                          },
                        ),
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            errorMessage!,
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (newBid != null &&
                                    newBid! >=
                                        auction.startingPrice + minIncrement) {
                                  bool success =
                                      await viewModel.placeBid(newBid!);
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor:
                                          success ? Colors.green : Colors.red,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      content: Row(
                                        children: [
                                          Icon(
                                            success
                                                ? Icons.check_circle_outline
                                                : Icons.error_outline,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            success
                                                ? "Bid placed successfully!"
                                                : "Failed to place bid",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Place Bid",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
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
        );
      },
    ),
  );
}

Future<void> _showEditDialog(
    BuildContext context, AuctionDetailViewModel viewModel) async {
  final TextEditingController nameController =
      TextEditingController(text: viewModel.auction.name);
  final TextEditingController descriptionController =
      TextEditingController(text: viewModel.auction.description);
  final TextEditingController priceController =
      TextEditingController(text: viewModel.auction.startingPrice.toString());
  final formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (BuildContext context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
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
                        color: Colors.deepPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Edit Auction",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEditField(
                      controller: nameController,
                      label: "Auction Name",
                      icon: Icons.title,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildEditField(
                      controller: descriptionController,
                      label: "Description",
                      icon: Icons.description,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Description cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildEditField(
                      controller: priceController,
                      label: "Starting Price",
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Price cannot be empty";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid price";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final success = await viewModel.editAuction(
                                  nameController.text,
                                  descriptionController.text,
                                  double.parse(priceController.text),
                                );

                                if (!context.mounted) return;
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor:
                                        success ? Colors.green : Colors.red,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: Row(
                                      children: [
                                        Icon(
                                          success
                                              ? Icons.check_circle_outline
                                              : Icons.error_outline,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          success
                                              ? "Auction updated successfully!"
                                              : "Failed to update auction",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Save Changes",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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
    ),
  );
}

Widget _buildEditField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  int? maxLines,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey[400],
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
    ),
  );
}

Future<void> _showDeleteConfirmation(
    BuildContext context, AuctionDetailViewModel viewModel) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              "Delete Auction",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Are you sure you want to delete this auction? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await viewModel.deleteAuction();
                        if (!context.mounted) return;
                        Navigator.pop(context);

                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Auction deleted successfully",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Delete",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
