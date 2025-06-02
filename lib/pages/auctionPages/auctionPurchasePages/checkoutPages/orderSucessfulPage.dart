import 'package:flutter/material.dart';
import 'package:collectionapp/models/auction_model.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSuccessfulPage extends StatelessWidget {
  final AuctionModel auction;
  final Map<String, dynamic> addressData;
  final Map<String, dynamic> paymentData;

  const OrderSuccessfulPage({
    super.key,
    required this.auction,
    required this.addressData,
    required this.paymentData,
  });

  @override
  Widget build(BuildContext context) {
    // Extract address fields
    final title = addressData['title'] ?? '';
    final detailedAddress = addressData['detailedAddress'] ?? '';
    final city = addressData['city'] ?? '';
    final country = addressData['country'] ?? '';

    // Extract payment fields
    final cardHolder = paymentData['cardHolderName'] ?? '';
    final cardNumber = paymentData['cardNumber'] ?? '';
    final last4 = cardNumber.length >= 4
        ? cardNumber.substring(cardNumber.length - 4)
        : '****';
    final expiry = paymentData['expiryDate'] ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Order Successful',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 24),
            Text(
              'Thank you! Your order has been placed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 32),
            // Order details section
            Text(
              'Order Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product: ${auction.name}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: \$${auction.startingPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shipping Address:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$title, $detailedAddress, $city, $country',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Payment Method:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$cardHolder  **** **** **** $last4  Exp: $expiry',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                'Go to Home',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
