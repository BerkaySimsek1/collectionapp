import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:collectionapp/models/auction_model.dart';
import 'package:collectionapp/screens/auctionScreens/auction_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JoinedAuctionsList extends StatelessWidget {
  final String userUid;
  const JoinedAuctionsList({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    final userDocRef =
        FirebaseFirestore.instance.collection("users").doc(userUid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDocRef.snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.deepPurple.shade300,
            ),
          );
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return buildEmptyState(
            icon: Icons.person_off_outlined,
            title: "User not logged in",
            subtitle: "Information about the user is not available.",
          );
        }

        final userData = userSnapshot.data!;
        final List<dynamic> joinedAuctions = userData["joinedAuctions"] ?? [];

        if (joinedAuctions.isEmpty) {
          return buildEmptyState(
            icon: Icons.gavel_outlined,
            title: "There are no joined auctions",
            subtitle: "You have not joined any auctions yet.",
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("auctions")
              .where(FieldPath.documentId, whereIn: joinedAuctions)
              .snapshots(),
          builder: (context, auctionsSnapshot) {
            if (auctionsSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple.shade300,
                ),
              );
            }
            if (!auctionsSnapshot.hasData) {
              return const Center(child: Text("No data."));
            }

            final docs = auctionsSnapshot.data!.docs;
            if (docs.isEmpty) {
              return buildEmptyState(
                icon: Icons.gavel_outlined,
                title: "There are no joined auctions",
                subtitle: "You have not joined any auctions yet.",
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final auctionDoc = docs[index];
                final auctionData = auctionDoc.data() as Map<String, dynamic>;
                final auction = AuctionModel.fromMap(auctionData);
                final auctionId = auctionDoc.id;
                final isAuctionEnd = auctionData["isAuctionEnd"] ?? false;
                final highestBidderId = auctionData["highestBidderId"] ?? "";

                if (isAuctionEnd && highestBidderId != userUid) {
                  _removeAuctionFromJoined(userUid, auctionId);
                }

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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AuctionDetailScreen(auction: auction),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Auction Image
                          if (auction.imageUrls.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                auction.imageUrls.first,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          // Auction Info
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        auction.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
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
                                            ? Colors.red.withValues(alpha: 0.15)
                                            : Colors.green
                                                .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        auction.isAuctionEnd
                                            ? "Ended"
                                            : "Active",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: auction.isAuctionEnd
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.amber.shade400,
                                            Colors.amber.shade700,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.amber
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        "\$${auction.startingPrice.toStringAsFixed(2)}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          auction.isAuctionEnd
                                              ? "Ended"
                                              : "Ends ${auction.endTime.day}/${auction.endTime.month}/${auction.endTime.year}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
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
              },
            );
          },
        );
      },
    );
  }

  Future<void> _removeAuctionFromJoined(
      String userUid, String auctionId) async {
    final userDocRef =
        FirebaseFirestore.instance.collection("users").doc(userUid);

    await userDocRef.update({
      "joinedAuctions": FieldValue.arrayRemove([auctionId]),
    });
  }
}
