import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/designElements/layouts/project_single_layout.dart';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:collectionapp/firebase_methods/user_firestore_methods.dart';
import 'package:collectionapp/screens/paymentScreens/successful_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFundsConfirmScreen extends StatefulWidget {
  final double amount;
  final String paymentMethodId;

  const AddFundsConfirmScreen({
    super.key,
    required this.amount,
    required this.paymentMethodId,
  });

  @override
  State<AddFundsConfirmScreen> createState() => _AddFundsConfirmScreenState();
}

class _AddFundsConfirmScreenState extends State<AddFundsConfirmScreen> {
  final UserFirestoreMethods _userMethods = UserFirestoreMethods();
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      final result = await _userMethods.addFunds(
        amount: widget.amount,
      );

      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SuccessfulScreen(
              isWithdrawal: false,
              amount: widget.amount,
              transactionId: result['transactionId'],
              accountInfo: null,
            ),
          ),
        );
      } else {
        projectSnackBar(context, result['message'], 'error');
      }
    } catch (e) {
      projectSnackBar(context, 'Payment failed', 'error');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: 'Confirm Payment',
      subtitle: 'Review your transaction details',
      headerIcon: Icons.fact_check_outlined,
      onPressed: _isProcessing ? null : _processPayment,
      buttonText: _isProcessing ? 'Processing...' : 'Confirm Payment',
      buttonIcon:
          _isProcessing ? Icons.hourglass_empty : Icons.check_circle_outline,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('paymentMethods')
            .doc(widget.paymentMethodId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple.shade300,
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Payment method not found',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          final pmData = snapshot.data!.data() as Map<String, dynamic>;
          final cardHolder = pmData['cardHolderName'] ?? '';
          final cardNumber = pmData['cardNumber'] ?? '';
          final cardLast4 = cardNumber.length >= 4
              ? cardNumber.substring(cardNumber.length - 4)
              : '****';
          final expiry = pmData['expiryDate'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Amount Summary Card
                buildPrimaryCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Amount to Add',
                  value: '\$${widget.amount.toStringAsFixed(2)}',
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: projectLinearGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'This amount will be added to your wallet',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Payment Method Card
                _buildDetailCard(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment Method',
                  children: [
                    _buildDetailRow('Card Holder', cardHolder),
                    _buildDetailRow('Card Number', '**** **** **** $cardLast4'),
                    _buildDetailRow('Expires', expiry),
                  ],
                ),

                const SizedBox(height: 16),

                // Transaction Details Card
                _buildDetailCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Transaction Details',
                  children: [
                    _buildDetailRow(
                        'Amount', '\$${widget.amount.toStringAsFixed(2)}'),
                    _buildDetailRow('Processing Fee', 'Free'),
                    const Divider(height: 20),
                    _buildDetailRow(
                      'Total',
                      '\$${widget.amount.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Security Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security_outlined,
                        color: Colors.green[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure Payment',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your payment information is encrypted and secure.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                color: isTotal ? Colors.deepPurple : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? Colors.deepPurple : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
