// ignore_for_file: use_build_context_synchronously

import 'package:collectionapp/viewModels/auction_detail_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:collectionapp/design_elements.dart';
import 'package:collectionapp/countdown_timer.dart';
import 'package:photo_view/photo_view.dart';

class AuctionDetail extends StatelessWidget {
  final AuctionModel auction;

  const AuctionDetail({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuctionDetailViewModel(auction),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: ProjectAppbar(
          titleText: "Auction Details",
          actions: [
            Consumer<AuctionDetailViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.currentUser.uid == auction.creatorId) {
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "Edit") {
                        _showEditDialog(context, viewModel);
                      } else if (value == "Delete") {
                        _showDeleteConfirmation(context, viewModel);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: "Edit",
                        child: Text("Edit"),
                      ),
                      const PopupMenuItem<String>(
                        value: "Delete",
                        child: Text("Delete"),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
        body: Consumer<AuctionDetailViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Carousel
                    _buildImageCarousel(auction.imageUrls, context),
                    const SizedBox(height: 16),
                    // Auction Details
                    _buildAuctionDetails(viewModel),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        CountdownTimer(
                          endTime: auction.endTime,
                          auctionId: auction.id,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: Consumer<AuctionDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.currentUser.uid != auction.creatorId) {
              return GestureDetector(
                onTap: () => _showBidDialog(context, viewModel),
                child: auction.isAuctionEnd
                    ? const SizedBox()
                    : const FinalFloatingDecoration(
                        buttonText: "Place a Bid",
                      ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls, BuildContext context) {
    return _ImageCarousel(imageUrls: imageUrls);
  }

  Widget _buildAuctionDetails(AuctionDetailViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              auction.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: "Price: ",
                style: ProjectTextStyles.cardHeaderTextStyle,
                children: [
                  TextSpan(
                    text: "\$${auction.startingPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.bidderInfo != null
                  ? "Last Bidder: ${viewModel.bidderInfo!.firstName}"
                  : "No bids yet",
              style: ProjectTextStyles.cardDescriptionTextStyle,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.creatorInfo != null
                  ? "Created by: ${viewModel.creatorInfo!.firstName}"
                  : "",
              style: ProjectTextStyles.cardHeaderTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBidDialog(
      BuildContext context, AuctionDetailViewModel viewModel) async {
    double? newBid;
    double minIncrement =
        viewModel.calculateBidIncrement(auction.startingPrice);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            "Place Your Bid",
            style: ProjectTextStyles.appBarTextStyle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Minimum Increment: \$${minIncrement.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText:
                      "Minimum Bid: \$${(auction.startingPrice + minIncrement).toStringAsFixed(2)}",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  newBid = double.tryParse(value);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: ProjectTextStyles.appBarTextStyle.copyWith(
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newBid != null) {
                  bool success = await viewModel.placeBid(newBid!);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      content: Text(
                          success
                              ? "Bid placed successfully!"
                              : "Invalid bid amount.",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          )),
                    ),
                  );
                }
              },
              style: ProjectDecorations.elevatedButtonStyle,
              child: const Text(
                "Submit Bid",
                style: ProjectTextStyles.buttonTextStyle,
              ),
            ),
          ],
        );
      },
    );
  }
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
    return Column(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 6,
              ),
            ],
          ),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.imageUrls.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.deepPurple : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _showPhotoDialog(BuildContext context, String initialImageUrl) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          insetPadding: EdgeInsets.zero,
          child: GestureDetector(
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
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> _showEditDialog(
    BuildContext context, AuctionDetailViewModel viewModel) async {
  final TextEditingController nameController =
      TextEditingController(text: viewModel.auction.name);
  final TextEditingController descriptionController =
      TextEditingController(text: viewModel.auction.description);
  final TextEditingController priceController =
      TextEditingController(text: viewModel.auction.startingPrice.toString());

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text("Edit Auction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Auction Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Starting Price"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await viewModel.editAuction(
                nameController.text,
                descriptionController.text,
                double.tryParse(priceController.text) ??
                    viewModel.auction.startingPrice,
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      content: Text("Auction updated successfully!",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ))),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      content: Text("Error updating auction.",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ))),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

Future<void> _showDeleteConfirmation(
    BuildContext context, AuctionDetailViewModel viewModel) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text("Delete Auction"),
        content: const Text("Are you sure you want to delete this auction?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool success = await viewModel.deleteAuction();

              Navigator.of(context).pop();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      content: Text("Auction deleted successfully!",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ))),
                );
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      content: Text("Error deleting auction.",
                          style: ProjectTextStyles.appBarTextStyle.copyWith(
                            fontSize: 16,
                          ))),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );
}
