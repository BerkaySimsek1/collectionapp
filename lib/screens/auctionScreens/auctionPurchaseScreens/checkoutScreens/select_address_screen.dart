import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/designElements/common_ui_methods.dart';
import 'package:collectionapp/models/auction_model.dart';
import 'package:collectionapp/screens/adressScreens/add_address_screen.dart';
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
      subtitle: 'Choose where to deliver your item',
      headerIcon: Icons.location_on_outlined,
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
                  return buildEmptyState(
                    icon: Icons.location_off,
                    title: 'No saved addresses found.',
                    subtitle:
                        'Tap the button below to add a new shipping address.',
                  );
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
                    builder: (context) => const AddAddressScreen(),
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
}
