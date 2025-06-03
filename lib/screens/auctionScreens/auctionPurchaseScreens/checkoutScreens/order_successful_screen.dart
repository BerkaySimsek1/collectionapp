import 'package:flutter/material.dart';
import 'package:collectionapp/models/auction_model.dart';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final AuctionModel auction;
  final Map<String, dynamic> addressData;
  final Map<String, dynamic> paymentData;

  const OrderSuccessfulScreen({
    super.key,
    required this.auction,
    required this.addressData,
    required this.paymentData,
  });

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen>
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

    // Start animations
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

  @override
  Widget build(BuildContext context) {
    // Extract address fields
    final title = widget.addressData['title'] ?? '';
    final detailedAddress = widget.addressData['detailedAddress'] ?? '';
    final city = widget.addressData['city'] ?? '';
    final country = widget.addressData['country'] ?? '';

    // Extract payment fields
    final cardHolder = widget.paymentData['cardHolderName'] ?? '';
    final cardNumber = widget.paymentData['cardNumber'] ?? '';
    final last4 = cardNumber.length >= 4
        ? cardNumber.substring(cardNumber.length - 4)
        : '****';
    final expiry = widget.paymentData['expiryDate'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Order Confirmation',
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
                        'Order Successful!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Thank you for your purchase! Your order has been confirmed and will be processed shortly.',
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

              // Order Details Section
              SlideTransition(
                position: _contentSlideAnimation,
                child: FadeTransition(
                  opacity: _contentFadeAnimation,
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
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Order Details',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Product Card
                      _buildDetailCard(
                        icon: Icons.inventory_2_outlined,
                        title: 'Product Information',
                        children: [
                          _buildDetailRow('Item', widget.auction.name),
                          _buildDetailRow('Price',
                              '\$${widget.auction.startingPrice.toStringAsFixed(2)}'),
                          if (widget.auction.imageUrls.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      widget.auction.imageUrls.first),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Shipping Card
                      _buildDetailCard(
                        icon: Icons.local_shipping_outlined,
                        title: 'Shipping Address',
                        children: [
                          _buildDetailRow('Name', title),
                          _buildDetailRow('Address', detailedAddress),
                          _buildDetailRow('Location', '$city, $country'),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Payment Card
                      _buildDetailCard(
                        icon: Icons.credit_card_outlined,
                        title: 'Payment Method',
                        children: [
                          _buildDetailRow('Card Holder', cardHolder),
                          _buildDetailRow(
                              'Card Number', '**** **** **** $last4'),
                          _buildDetailRow('Expires', expiry),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Action Buttons
              SlideTransition(
                position: _contentSlideAnimation,
                child: FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: Column(
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
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
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
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          // Add track order functionality
                          projectSnackBar(context,
                              'Track order feature coming soon!', 'green');
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
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
