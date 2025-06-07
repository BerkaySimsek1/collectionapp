import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/auction_model.dart';
import 'package:collectionapp/designElements/layouts/project_single_layout.dart';
import 'package:collectionapp/screens/paymentScreens/successful_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SumAndProceedScreen extends StatefulWidget {
  final AuctionModel auction;
  final String userUid;
  final String addressId;
  final String paymentMethod; // This is the payment method document ID

  const SumAndProceedScreen({
    super.key,
    required this.auction,
    required this.userUid,
    required this.addressId,
    required this.paymentMethod,
    required Map<String, dynamic> paymentData,
  });

  @override
  State<SumAndProceedScreen> createState() => _SumAndProceedScreenState();
}

class _SumAndProceedScreenState extends State<SumAndProceedScreen> {
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: 'Order Summary',
      subtitle: 'Review your order before proceeding',
      headerIcon: Icons.receipt_long_outlined,
      isLoading: false,
      onPressed: _termsAccepted
          ? () async {
              // Fetch order details
              final rawData = await _loadOrderDetails();
              final orderData = Map<String, dynamic>.from(rawData);
              final addressData =
                  Map<String, dynamic>.from(orderData['address']);
              final paymentData =
                  Map<String, dynamic>.from(orderData['payment']);

              // Determine price
              final double price = widget.auction.startingPrice.toDouble();

              // Handle wallet deduction if needed
              if (widget.paymentMethod == 'wallet' ||
                  widget.paymentMethod == 'composite') {
                // Get current balance
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userUid)
                    .get();
                final userData = userDoc.exists
                    ? userDoc.data() as Map<String, dynamic>
                    : {};
                final rawBalance = userData['balance'];
                final double balance =
                    (rawBalance != null) ? (rawBalance as num).toDouble() : 0.0;

                double newBalance;
                if (widget.paymentMethod == 'wallet') {
                  // Deduct full price from balance
                  newBalance = balance - price;
                } else {
                  // Composite: deduct entire balance
                  newBalance = 0.0;
                }

                // Update user's balance in Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userUid)
                    .update({'balance': newBalance});
              }

              // Update auction status in Firestore before navigating
              await FirebaseFirestore.instance
                  .collection('auctions')
                  .doc(widget.auction.id)
                  .update({'status': 'Order Placed'});
              widget.auction.status =
                  'Order Placed'; // Optional: update local model

              // Navigate to order successful screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SuccessfulScreen(
                    successType: SuccessType.order,
                    auction: widget.auction,
                    addressData: addressData,
                    paymentData: paymentData,
                  ),
                ),
              );
            }
          : null,
      buttonText: 'Place Order',
      buttonIcon: Icons.shopping_cart_checkout_outlined,
      body: FutureBuilder(
        future: _loadOrderDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple.shade300,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'An error occurred. Please try again.',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          final rawData = snapshot.data;
          if (rawData == null) {
            return Center(
              child: Text(
                'Order data not available.',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }
          final orderData = Map<String, dynamic>.from(rawData as Map);
          final addressData =
              Map<String, dynamic>.from(orderData['address'] as Map);
          final paymentData =
              Map<String, dynamic>.from(orderData['payment'] as Map);

          final cardNumber = paymentData['cardNumber'] ?? '';
          final cardLast4 = cardNumber.length >= 4
              ? cardNumber.substring(cardNumber.length - 4)
              : '****';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Auction product summary
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Product',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.auction.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(
                            widget.auction.imageUrls.first,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.auction.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Price: \$${widget.auction.startingPrice.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Address summary
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Shipping Address',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          addressData['title'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          addressData['detailedAddress'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${addressData['city'] ?? ''}, ${addressData['country'] ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Payment summary
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.credit_card_outlined,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Payment Method',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paymentData['cardHolderName'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '**** **** **** ${cardLast4 ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Expires: ${paymentData['expiryDate'] ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Terms and Conditions
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                          activeColor: Colors.deepPurple,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _termsAccepted = !_termsAccepted;
                              });
                            },
                            child: Text(
                              'I have read and agree to the Terms and Conditions.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
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
    );
  }

  Future<Map<String, dynamic>> _loadOrderDetails() async {
    // Fetch address document
    final addressSnap = await FirebaseFirestore.instance
        .collection('adresses')
        .doc(widget.addressId)
        .get();
    final paymentSnap = await FirebaseFirestore.instance
        .collection('paymentMethods')
        .doc(widget.paymentMethod)
        .get();

    final addressData =
        addressSnap.exists ? (addressSnap.data() as Map<String, dynamic>) : {};
    final paymentData =
        paymentSnap.exists ? (paymentSnap.data() as Map<String, dynamic>) : {};

    return {
      'address': addressData,
      'payment': paymentData,
    };
  }
}
