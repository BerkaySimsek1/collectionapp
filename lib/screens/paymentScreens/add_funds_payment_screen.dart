import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/designElements/layouts/project_single_layout.dart';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:collectionapp/screens/paymentScreens/add_funds_confirm_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFundsPaymentScreen extends StatefulWidget {
  final double amount;

  const AddFundsPaymentScreen({
    super.key,
    required this.amount,
  });

  @override
  State<AddFundsPaymentScreen> createState() => _AddFundsPaymentScreenState();
}

class _AddFundsPaymentScreenState extends State<AddFundsPaymentScreen> {
  String? _selectedPaymentMethod;
  final String userUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: 'Select Payment Method',
      subtitle: 'Choose your payment option',
      headerIcon: Icons.payment_outlined,
      onPressed: (_selectedPaymentMethod == null)
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFundsConfirmScreen(
                    amount: widget.amount,
                    paymentMethodId: _selectedPaymentMethod!,
                  ),
                ),
              );
            },
      buttonText: 'Continue',
      buttonIcon: Icons.arrow_forward_outlined,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('paymentMethods')
            .where('userId', isEqualTo: userUid)
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
              // Amount Card
              buildPrimaryCard(
                icon: Icons.attach_money,
                title: 'Amount to Add',
                value: '\$${widget.amount.toStringAsFixed(2)}',
                margin: const EdgeInsets.only(bottom: 16),
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
                    border: _selectedPaymentMethod == doc.id
                        ? Border.all(color: Colors.deepPurple, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: _selectedPaymentMethod == doc.id
                            ? Colors.deepPurple.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.1),
                        blurRadius: _selectedPaymentMethod == doc.id ? 15 : 8,
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
                    title: Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: _selectedPaymentMethod == doc.id
                              ? Colors.deepPurple
                              : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cardHolder,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _selectedPaymentMethod == doc.id
                                ? Colors.deepPurple
                                : Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: Text(
                        '**** **** **** $cardLast4  Exp: $expiry',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _selectedPaymentMethod == doc.id
                              ? Colors.deepPurple.withValues(alpha: 0.8)
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    activeColor: Colors.deepPurple,
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
