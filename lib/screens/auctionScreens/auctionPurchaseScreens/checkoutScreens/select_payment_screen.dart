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
  String? _selectedCardForComposite;
  bool _isCompositeSelected = false;

  @override
  void initState() {
    super.initState();
    // No default selection since payment methods are loaded dynamically
  }

  // Payment method'u parse eden helper method
  Map<String, dynamic> parsePaymentMethod() {
    if (_selectedPaymentMethod == null) {
      return {'type': 'none'};
    }

    if (_selectedPaymentMethod == 'wallet') {
      return {'type': 'wallet'};
    }

    if (_selectedPaymentMethod == 'composite' &&
        _selectedCardForComposite != null) {
      return {
        'type': 'composite',
        'cardId': _selectedCardForComposite,
      };
    }

    // Regular card payment
    return {
      'type': 'card',
      'cardId': _selectedPaymentMethod,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: 'Select Payment Method',
      subtitle: 'Choose your payment option',
      headerIcon: Icons.payment_outlined,
      isLoading: false,
      onPressed: (_selectedPaymentMethod == null ||
              (_isCompositeSelected && _selectedCardForComposite == null))
          ? null
          : () {
              final paymentData = parsePaymentMethod();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SumAndProceedScreen(
                    auction: widget.auction,
                    userUid: widget.userUid,
                    addressId: widget.addressId,
                    paymentMethod: _selectedPaymentMethod!,
                    paymentData: paymentData, // Pass parsed payment data
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

          if (balance == 0.0) {
            // No funds at all - show only saved cards
            return StreamBuilder<QuerySnapshot>(
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No payment methods available',
                          style: GoogleFonts.poppins(
                              fontSize: 16, color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please add a payment method in your profile settings.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Your wallet balance: \$0.00',
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select a payment method:',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    })
                  ],
                );
              },
            );
          } else if (balance > 0.0 && balance < price) {
            // Partial funds - show composite option AND saved cards
            final double needed = price - balance;
            return StreamBuilder<QuerySnapshot>(
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

                final docs = snapshot.hasData ? snapshot.data!.docs : [];

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Your wallet has \$${balance.toStringAsFixed(2)}.\n'
                      'Total needed: \$${price.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 20),
                    // Composite payment option
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.deepPurple.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: RadioListTile<String>(
                        value: 'composite',
                        groupValue: _selectedPaymentMethod,
                        onChanged: docs.isNotEmpty
                            ? (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                  _isCompositeSelected = true;
                                  _selectedCardForComposite = null;
                                });
                              }
                            : null,
                        title: Text(
                          'Combine Wallet + Card',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: docs.isNotEmpty
                                ? Colors.deepPurple
                                : Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                          '\$${balance.toStringAsFixed(2)} from wallet + \$${needed.toStringAsFixed(2)} from card',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    if (_isCompositeSelected &&
                        _selectedPaymentMethod == 'composite') ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Select a card to charge \$${needed.toStringAsFixed(2)}:',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
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
                            border: Border.all(
                              color: _selectedCardForComposite == doc.id
                                  ? Colors.blue
                                  : Colors.grey.withValues(alpha: 0.3),
                              width:
                                  _selectedCardForComposite == doc.id ? 2 : 1,
                            ),
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
                            groupValue: _selectedCardForComposite,
                            onChanged: (value) {
                              setState(() {
                                _selectedCardForComposite = value;
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
                              '**** **** **** $cardLast4  Exp: $expiry\nWill be charged: \$${needed.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                    if (docs.isNotEmpty) ...[
                      Text(
                        'Or pay entirely with card:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                _isCompositeSelected = false;
                                _selectedCardForComposite = null;
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
                      })
                    ] else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Please add a payment method in your profile settings to complete this purchase.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                  ],
                );
              },
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
