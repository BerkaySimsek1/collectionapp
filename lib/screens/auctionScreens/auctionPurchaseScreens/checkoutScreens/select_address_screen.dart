import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/auction_model.dart';
import 'package:collectionapp/screens/adressScreens/add_address_screen.dart';
import 'package:collectionapp/screens/adressScreens/address_main_screen.dart';
import 'package:collectionapp/screens/auctionScreens/auctionPurchaseScreens/checkoutScreens/select_payment_screen.dart';
import 'package:collectionapp/designElements/layouts/project_single_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectAddressScreen extends StatefulWidget {
  final AuctionModel auction;
  final String userUid;
  const SelectAddressScreen({
    super.key,
    required this.auction,
    required this.userUid,
  });

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _selectedAddressId = widget.userUid;
  }

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: 'Select Shipping Address',
      subtitle: 'Choose where to deliver your auction item',
      headerIcon: Icons.location_on_outlined,
      headerHeight: 275,
      isLoading: false,
      onPressed: _selectedAddressId == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectPaymentScreen(
                    auction: widget.auction,
                    userUid: widget.userUid,
                    addressId: widget.userUid,
                  ),
                ),
              );
            },
      buttonText: 'Continue to Payment',
      buttonIcon: Icons.payment_outlined,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('adresses')
                  .doc(widget.userUid)
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
                  return _buildEmptyState();
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final title = data['title'] ?? '';
                final detailedAdress = data['detailedAddress'] ?? '';
                final city = data['city'] ?? '';
                final country = data['country'] ?? '';

                _selectedAddressId = widget.userUid;

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: RadioListTile<String>(
                        value: widget.userUid,
                        groupValue: _selectedAddressId,
                        onChanged: (value) {
                          setState(() {
                            _selectedAddressId = value;
                          });
                        },
                        title: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              detailedAdress,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '$city, $country',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                foregroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressMainScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_location_alt),
              label: Text(
                'Select Another Address',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off,
                size: 64,
                color: Colors.deepPurple.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No saved addresses found.',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to add a new shipping address.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAddressPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Address',
                style: GoogleFonts.poppins(
                  fontSize: 14,
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
