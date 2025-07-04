import 'package:collectionapp/designElements/layouts/project_single_layout.dart';
import 'package:collectionapp/firebase_methods/user_firestore_methods.dart';
import 'package:collectionapp/screens/paymentScreens/successful_screen.dart';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WithdrawFundsScreen extends StatefulWidget {
  const WithdrawFundsScreen({super.key});

  @override
  State<WithdrawFundsScreen> createState() => _WithdrawFundsScreenState();
}

class _WithdrawFundsScreenState extends State<WithdrawFundsScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final UserFirestoreMethods _userMethods = UserFirestoreMethods();

  bool _isLoading = false;
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

  Future<void> _handleWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final result = await _userMethods.withdrawFunds(
        amount: amount,
        accountInfo: _accountController.text,
      );

      if (result['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SuccessfulScreen(
              successType: SuccessType.withdrawal,
              amount: result['amount'],
              transactionId: result['transactionId'],
              accountInfo: result['accountInfo'],
            ),
          ),
        );
      } else {
        projectSnackBar(context, result['message'], 'error');
      }
    } catch (e) {
      projectSnackBar(context, 'Invalid amount entered', 'error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: "Withdraw Funds",
      subtitle: "Enter withdrawal details",
      headerIcon: Icons.payments_outlined,
      onPressed: _isLoading ? null : _handleWithdrawal,
      buttonText: _isLoading ? "Processing..." : "Confirm Withdrawal",
      buttonIcon:
          _isLoading ? Icons.hourglass_empty : Icons.check_circle_outline,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple.shade300,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet Balance Card
                    buildPrimaryCard(
                      icon: Icons.account_balance_wallet,
                      title: 'Available Balance',
                      value: '\$${_userBalance.toStringAsFixed(2)}',
                      margin: const EdgeInsets.only(bottom: 16),
                    ),

                    Text(
                      "Withdrawal Details",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _amountController,
                      label: "Amount (USD)",
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Please enter a valid amount';
                        }
                        if (amount < 10) {
                          return 'Minimum withdrawal amount is \$10';
                        }
                        if (amount > _userBalance) {
                          return 'Insufficient balance';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _accountController,
                      label: "Bank Account / IBAN",
                      icon: Icons.account_balance,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account details';
                        }
                        if (value.length < 10) {
                          return 'Please enter valid account details';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Processing Information',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Withdrawal requests are processed within 1-3 business days. Minimum amount is \$10.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.blue[600],
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
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }
}
