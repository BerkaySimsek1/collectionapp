import 'package:flutter/material.dart';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collectionapp/models/auction_model.dart';

enum SuccessType {
  withdrawal,
  addFunds,
  order,
  shipping,
}

class SuccessfulScreen extends StatefulWidget {
  final SuccessType successType;
  final double? amount;
  final String? transactionId;
  final String? accountInfo;
  final AuctionModel? auction;
  final Map<String, dynamic>? addressData;
  final Map<String, dynamic>? paymentData;
  final String? shippingCode;

  const SuccessfulScreen({
    super.key,
    required this.successType,
    this.amount,
    this.transactionId,
    this.accountInfo,
    this.auction,
    this.addressData,
    this.paymentData,
    this.shippingCode,
  });

  @override
  State<SuccessfulScreen> createState() => _SuccessfulScreenState();
}

class _SuccessfulScreenState extends State<SuccessfulScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _checkScaleAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();

    _checkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkAnimationController,
      curve: Curves.elasticOut,
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeInOut,
    ));

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _checkAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _checkAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  String get _getTitle {
    switch (widget.successType) {
      case SuccessType.withdrawal:
        return 'Withdrawal Submitted!';
      case SuccessType.addFunds:
        return 'Funds Added Successfully!';
      case SuccessType.order:
        return 'Order Successful!';
      case SuccessType.shipping:
        return 'Shipped Successfully!';
    }
  }

  String get _getSubtitle {
    switch (widget.successType) {
      case SuccessType.withdrawal:
        return 'Your withdrawal request has been submitted successfully. It will be processed within 1-3 business days.';
      case SuccessType.addFunds:
        return '\$${widget.amount?.toStringAsFixed(2) ?? '0.00'} has been added to your wallet.';
      case SuccessType.order:
        return 'Thank you for your purchase! Your order has been confirmed and will be processed shortly.';
      case SuccessType.shipping:
        return 'Your item has been marked as shipped and is on its way to the buyer.';
    }
  }

  String get _getAppBarTitle {
    switch (widget.successType) {
      case SuccessType.withdrawal:
        return 'Withdrawal Request';
      case SuccessType.addFunds:
        return 'Funds Added';
      case SuccessType.order:
        return 'Order Confirmation';
      case SuccessType.shipping:
        return 'Shipping Confirmation';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _getAppBarTitle,
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
              const SizedBox(height: 20),

              // Success Animation
              AnimatedBuilder(
                animation: _checkScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _checkScaleAnimation.value,
                    child: Container(
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
                  );
                },
              ),

              const SizedBox(height: 32),

              // Success Message
              SlideTransition(
                position: _contentSlideAnimation,
                child: FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        _getTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Details Section
              SlideTransition(
                position: _contentSlideAnimation,
                child: FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: _buildDetailsSection(),
                ),
              ),

              const SizedBox(height: 40),

              // Action Button
              SlideTransition(
                position: _contentSlideAnimation,
                child: FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: _buildActionButtons(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    switch (widget.successType) {
      case SuccessType.withdrawal:
        return _buildWithdrawalDetails();
      case SuccessType.addFunds:
        return _buildAddFundsDetails();
      case SuccessType.order:
        return _buildOrderDetails();
      case SuccessType.shipping:
        return _buildShippingDetails();
    }
  }

  Widget _buildWithdrawalDetails() {
    return _buildDetailCard(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Withdrawal Details',
      children: [
        _buildDetailRow(
            'Amount', '\$${widget.amount?.toStringAsFixed(2) ?? '0.00'}'),
        _buildDetailRow('Transaction ID',
            widget.transactionId?.substring(0, 8).toUpperCase() ?? ''),
        if (widget.accountInfo != null)
          _buildDetailRow('Account', widget.accountInfo!),
        _buildDetailRow('Status', 'Pending'),
        _buildDetailRow('Processing Time', '1-3 business days'),
      ],
    );
  }

  Widget _buildAddFundsDetails() {
    return _buildDetailCard(
      icon: Icons.add_circle_outline,
      title: 'Transaction Details',
      children: [
        _buildDetailRow(
            'Amount', '\$${widget.amount?.toStringAsFixed(2) ?? '0.00'}'),
        _buildDetailRow('Transaction ID',
            widget.transactionId?.substring(0, 8).toUpperCase() ?? ''),
        _buildDetailRow('Status', 'Completed'),
        _buildDetailRow('Processing Time', 'Instant'),
      ],
    );
  }

  Widget _buildOrderDetails() {
    if (widget.auction == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Product Details
        _buildDetailCard(
          icon: Icons.inventory_2_outlined,
          title: 'Product Information',
          children: [
            _buildDetailRow('Item', widget.auction!.name),
            _buildDetailRow('Price',
                '\$${widget.auction!.startingPrice.toStringAsFixed(2)}'),
            if (widget.auction!.imageUrls.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(widget.auction!.imageUrls.first),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),

        if (widget.addressData != null) ...[
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.local_shipping_outlined,
            title: 'Shipping Address',
            children: [
              _buildDetailRow('Name', widget.addressData!['title'] ?? ''),
              _buildDetailRow(
                  'Address', widget.addressData!['detailedAddress'] ?? ''),
              _buildDetailRow('Location',
                  '${widget.addressData!['city'] ?? ''}, ${widget.addressData!['country'] ?? ''}'),
            ],
          ),
        ],

        if (widget.paymentData != null) ...[
          const SizedBox(height: 16),
          _buildDetailCard(
            icon: Icons.credit_card_outlined,
            title: 'Payment Method',
            children: [
              _buildDetailRow(
                  'Card Holder', widget.paymentData!['cardHolderName'] ?? ''),
              _buildDetailRow(
                  'Card Number', '**** **** **** ${_getCardLast4()}'),
              _buildDetailRow(
                  'Expires', widget.paymentData!['expiryDate'] ?? ''),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildShippingDetails() {
    if (widget.auction == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildDetailCard(
          icon: Icons.inventory_2_outlined,
          title: 'Shipped Item',
          children: [
            _buildDetailRow('Item', widget.auction!.name),
            _buildDetailRow('Price',
                '\$${widget.auction!.startingPrice.toStringAsFixed(2)}'),
            if (widget.shippingCode != null)
              _buildDetailRow('Shipping Code', widget.shippingCode!),
            _buildDetailRow('Status', 'Shipped'),
          ],
        ),
      ],
    );
  }

  String _getCardLast4() {
    final cardNumber = widget.paymentData?['cardNumber'] ?? '';
    return cardNumber.length >= 4
        ? cardNumber.substring(cardNumber.length - 4)
        : '****';
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

  Widget _buildActionButtons() {
    return Column(
      children: [
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
        if (widget.successType == SuccessType.order) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              projectSnackBar(
                  context, 'Track order feature coming soon!', 'green');
            },
            icon: Icon(
              Icons.track_changes_outlined,
              color: Colors.deepPurple.withValues(alpha: 0.8),
            ),
            label: Text(
              'Track Your Order',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
