import 'package:collectionapp/designElements/layouts/project_single_layout.dart';
import 'package:collectionapp/firebase_methods/user_firestore_methods.dart';
import 'package:collectionapp/screens/paymentScreens/add_funds_payment_screen.dart';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFundsScreen extends StatefulWidget {
  const AddFundsScreen({super.key});

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  final UserFirestoreMethods _userMethods = UserFirestoreMethods();
  int? _selectedAmount;
  double _userBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    final balance = await _userMethods.getUserBalance();
    setState(() {
      _userBalance = balance;
    });
  }

  Future<void> _handleAddFunds() async {
    if (_selectedAmount == null) {
      projectSnackBar(context, 'Please select an amount', 'error');
      return;
    }

    // Navigate to payment method selection instead of directly adding funds
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFundsPaymentScreen(
          amount: _selectedAmount!.toDouble(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: "Add Funds",
      subtitle: "Select amount to add to your wallet",
      headerIcon: Icons.account_balance_wallet,
      onPressed: _handleAddFunds,
      buttonText: "Proceed to Payment",
      buttonIcon: Icons.payment,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Card
            buildPrimaryCard(
              icon: Icons.account_balance_wallet,
              title: 'Current Balance',
              value: '\$${_userBalance.toStringAsFixed(2)}',
            ),
            Text(
              "Select Amount",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              padding: const EdgeInsets.all(12),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [10, 20, 50, 100, 200, 500]
                  .map((amount) => _buildAmountCard(context, amount))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context, int amount) {
    final isSelected = _selectedAmount == amount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            isSelected ? Border.all(color: Colors.deepPurple, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.deepPurple.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isSelected ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedAmount = amount;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$$amount',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.deepPurple : Colors.grey[800],
                  ),
                ),
                Text(
                  'USD',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isSelected ? Colors.deepPurple : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddFundsSuccessfulScreen extends StatelessWidget {
  final double amount;
  final String transactionId;

  const AddFundsSuccessfulScreen({
    super.key,
    required this.amount,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Funds Added',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Success Icon
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: projectLinearGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Success Message
              Text(
                'Funds Added Successfully!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '\$${amount.toStringAsFixed(2)} has been added to your wallet.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 60),

              // Back to Home Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: projectLinearGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Back to Home',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
