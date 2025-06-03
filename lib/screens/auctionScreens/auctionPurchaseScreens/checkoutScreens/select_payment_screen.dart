import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/auction_model.dart';
import 'package:collectionapp/screens/auctionScreens/auctionPurchaseScreens/checkoutScreens/sum_and_proceed_screen.dart';
import 'package:collectionapp/designElements/layouts/project_single_layout.dart';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectPaymentScreen extends StatefulWidget {
  final AuctionModel auction;
  final String userUid;
  final String addressId;
  const SelectPaymentScreen({
    super.key,
    required this.auction,
    required this.userUid,
    required this.addressId,
  });

  @override
  State<SelectPaymentScreen> createState() => _SelectPaymentScreenState();
}

class _SelectPaymentScreenState extends State<SelectPaymentScreen> {
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    // No default selection since payment methods are loaded dynamically
  }

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: 'Select Payment Method',
      subtitle: 'Choose your preferred payment option',
      headerIcon: Icons.payment_outlined,
      headerHeight: 275,
      isLoading: false,
      onPressed: (_selectedPaymentMethod == null)
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SumAndProceedScreen(
                    auction: widget.auction,
                    userUid: widget.userUid,
                    addressId: widget.addressId,
                    paymentMethod: _selectedPaymentMethod!,
                  ),
                ),
              );
            },
      buttonText: 'Continue',
      buttonIcon: Icons.arrow_forward_outlined,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('paymentMethods')
            .where('userId', isEqualTo: widget.userUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple.shade300,
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return buildEmptyState(
              icon: Icons.credit_card_off,
              title: 'No saved payment methods found.',
              subtitle: 'Please add a payment method in your profile settings.',
            );
          }

          final docs = snapshot.data!.docs;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Display selected address info
              Container(
                margin: const EdgeInsets.only(bottom: 24),
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
                  padding: const EdgeInsets.all(20),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('adresses')
                        .doc(widget.addressId)
                        .snapshots(),
                    builder: (context, addressSnapshot) {
                      if (addressSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepPurple.shade300,
                          ),
                        );
                      }
                      if (!addressSnapshot.hasData ||
                          !addressSnapshot.data!.exists) {
                        return Text(
                          'Address not found.',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.grey[600]),
                        );
                      }
                      final data =
                          addressSnapshot.data!.data() as Map<String, dynamic>;
                      final title = data['title'] ?? '';
                      final detailedAddress = data['detailedAddress'] ?? '';
                      final city = data['city'] ?? '';
                      final country = data['country'] ?? '';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.deepPurple.withValues(alpha: 0.15),
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detailedAddress,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$city, $country',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              // Payment method selection header
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
                    'Saved Payment Methods',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // List of saved cards
              ...docs.map((doc) {
                final pmData = doc.data() as Map<String, dynamic>;
                final cardHolder = pmData['cardHolderName'] ?? '';
                final cardNumber = pmData['cardNumber'] ?? '';
                final cardLast4 = cardNumber.length >= 4
                    ? cardNumber.substring(cardNumber.length - 4)
                    : '****';
                final expiry = pmData['expiryDate'] ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: RadioListTile<String>(
                    value: doc.id,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                    title: Text(
                      cardHolder,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    subtitle: Text(
                      '**** **** **** $cardLast4  Exp: $expiry',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
