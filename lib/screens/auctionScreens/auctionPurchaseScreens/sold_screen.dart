import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:collectionapp/models/auction_model.dart';
import 'package:collectionapp/screens/auctionScreens/auctionPurchaseScreens/shippingScreens/prepare_order_for_shipping_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SoldPage extends StatefulWidget {
  final String? userUid;
  const SoldPage({super.key, required this.userUid});

  @override
  State<SoldPage> createState() => _SoldPageState();
}

class _SoldPageState extends State<SoldPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.userUid == null) {
      return Center(
        child: Text(
          "User ID is null",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    final soldAuctionsQuery = FirebaseFirestore.instance
        .collection("auctions")
        .where("creator_id", isEqualTo: widget.userUid)
        .orderBy("end_time", descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: soldAuctionsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple.shade300,
            ),
          );
        }
        if (!snapshot.hasData) {
          return buildEmptyState(
            icon: Icons.error_outline,
            title: "Data has not loaded",
            subtitle: "Auction data could not be fetched",
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return buildEmptyState(
            icon: Icons.inventory_2_outlined,
            title: "There are no sold auctions",
            subtitle: "Auctions you sold will be listed here",
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final auctionData = docs[index].data() as Map<String, dynamic>;
            final auction = AuctionModel.fromMap(auctionData);
            return SoldItem(auction: auction);
          },
        );
      },
    );
  }
}

class SoldItem extends StatefulWidget {
  final AuctionModel auction;
  const SoldItem({super.key, required this.auction});

  @override
  State<SoldItem> createState() => _SoldItemState();
}

class _SoldItemState extends State<SoldItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.auction.status == "shipped") {
      _isExpanded = true;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auction = widget.auction;
    return Column(
      children: [
        Container(
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
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (auction.imageUrls.isNotEmpty)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
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
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.sell_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Sold",
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auction.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                "Sold at \$${auction.startingPrice.toStringAsFixed(2)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              "Ended ${auction.endTime.day}/${auction.endTime.month}/${auction.endTime.year}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (auction.status == null ||
                                  auction.status!.isEmpty) ...[
                                TextButton(
                                  onPressed: null,
                                  child: Text(
                                    "Prepare for shipping",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "(Waiting for payment)",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ] else if (auction.status == "Shipped") ...[
                                TextButton(
                                  onPressed: _toggleExpanded,
                                  child: Text(
                                    _isExpanded
                                        ? "Close status"
                                        : "Show status",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ),
                              ] else if (auction.status == "Completed") ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Completed!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ),
                              ] else ...[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PrepareOrderForShippingPage(
                                                auction: auction),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Prepare for shipping",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auction.status == null || auction.status!.isEmpty
                      ? "Waiting for payment"
                      : auction.status == "Order Placed"
                          ? "Order placed"
                          : auction.status!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (auction.status == "Order Placed") ...[
                  const SizedBox(height: 4),
                  Text(
                    "Waiting for shipping",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
