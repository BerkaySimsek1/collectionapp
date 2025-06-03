import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:collectionapp/models/auction_model.dart';

class PrepareOrderForShippingPage extends StatefulWidget {
  final AuctionModel auction;

  const PrepareOrderForShippingPage({
    super.key,
    required this.auction,
  });

  @override
  State<PrepareOrderForShippingPage> createState() =>
      _PrepareOrderForShippingPageState();
}

class _PrepareOrderForShippingPageState
    extends State<PrepareOrderForShippingPage> {
  late String _shippingCode;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _addressFuture;
  late Future<String> _buyerNameFuture;
  late Future<String> _buyerProfileImageFuture;

  @override
  void initState() {
    super.initState();

    // 1) Rastgele bir kargo kodu oluştur
    final random = Random();
    final codeNumber = random.nextInt(900000) + 100000; // 100000–999999 arası
    _shippingCode = 'SHIP-$codeNumber';

    // 2) Kullanıcının adresini almak için future tanımla.
    //    Artık nested collection yerine doğrudan user dokümanı çekilecek.
    final userId = widget.auction.bidderId;
    _addressFuture =
        FirebaseFirestore.instance.collection('adresses').doc(userId).get();
    _buyerNameFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) => doc.data()?['firstName'] ?? '');
    _buyerProfileImageFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) => doc.data()?['profileImageUrl'] ?? '');
  }

  Future<void> _markAsShipped() async {
    // 3) Firestore'daki auction dokümanının status alanını "Shipped" yap
    final auctionDocRef = FirebaseFirestore.instance
        .collection('auctions')
        .doc(widget.auction.id);

    await auctionDocRef.update({
      'status': 'Shipped',
    });

    // 4) Başarılı olunca alert dialog göster
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Successful!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Dialogu kapat
              Navigator.of(context).pop(); // Bir önceki sayfaya dön
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prepare For Shipping',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _addressFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'Could not load address.',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              );
            }

            final addressData = snapshot.data!.data()!;
            // Örneğin addressData içinde "street", "city", "zipcode" vb. alanlar var:
            final street = addressData['state'] ?? '';
            final city = addressData['city'] ?? '';
            final district = addressData['detailedAddress'] ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.auction.imageUrls.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              widget.auction.imageUrls.first,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          widget.auction.name,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.auction.description,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<String>>(
                          future: Future.wait(
                              [_buyerNameFuture, _buyerProfileImageFuture]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 40,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[300],
                                    child: Icon(Icons.person,
                                        color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Buyer Info Unavailable',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              );
                            }
                            final buyerName = snapshot.data![0];
                            final profileUrl = snapshot.data![1];
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: profileUrl.isNotEmpty
                                      ? NetworkImage(profileUrl)
                                      : null,
                                  backgroundColor: profileUrl.isEmpty
                                      ? Colors.grey[300]
                                      : null,
                                  child: profileUrl.isEmpty
                                      ? Icon(Icons.person,
                                          color: Colors.grey[600])
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  buyerName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Shipping Address:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$street\n$district / $city',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Shipping Code:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _shippingCode,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _markAsShipped(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'I delivered it to cargo company',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
