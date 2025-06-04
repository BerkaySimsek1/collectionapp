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
      subtitle: 'Choose your payment option',
      headerIcon: Icons.payment_outlined,
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userUid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple.shade300,
              ),
            );
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(
              child: Text(
                'User data not found.',
                style:
                    GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final rawBalance = userData['balance'];
          final double balance =
              (rawBalance != null) ? (rawBalance as num).toDouble() : 0.0;
          final double price = widget.auction.startingPrice.toDouble();

          if (balance < price && balance == 0.0) {
            // No funds at all
            return Center(
              child: Text(
                'Not enough money in your wallet',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (balance < price && balance > 0.0) {
            // Partial funds
            final double needed = price - balance;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your wallet has \$${balance.toStringAsFixed(2)}.\n'
                    'You need \$${needed.toStringAsFixed(2)} more.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPaymentMethod = 'composite';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Use \$${balance.toStringAsFixed(2)} from wallet and \$${needed.toStringAsFixed(2)} from card',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // balance >= price: show wallet or card choice + saved cards
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Wallet option
                RadioListTile<String>(
                  value: 'wallet',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                  title: Text(
                    'Use \$${balance.toStringAsFixed(2)} from wallet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  subtitle: Text(
                    'Pay \$${price.toStringAsFixed(2)} using wallet balance',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 16),
                // Or pay by card header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.15),
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
                      'Or pay with card',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // StreamBuilder for saved cards (existing code)
                StreamBuilder<QuerySnapshot>(
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
                        subtitle:
                            'Please add a payment method in your profile settings.',
                      );
                    }

                    final docs = snapshot.data!.docs;
                    return Column(
                      children: docs.map((doc) {
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
                                color: Colors.black.withOpacity(0.1),
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
                      }).toList(),
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
