// lib/pages/adressPages/adress_mainpage.dart

import 'package:collectionapp/common_ui_methods.dart';
import 'package:collectionapp/pages/adressPages/address_page.dart';
import 'package:collectionapp/widgets/common/project_single_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressMainPage extends StatefulWidget {
  const AddressMainPage({super.key});

  @override
  State<AddressMainPage> createState() => _AddressMainPageState();
}

class _AddressMainPageState extends State<AddressMainPage> {
  final _auth = FirebaseAuth.instance;
  late final String _uid;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user == null) {
      _uid = '';
    } else {
      _uid = user.uid;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getAddressStream() {
    return FirebaseFirestore.instance
        .collection('adresses')
        .doc(_uid)
        .snapshots();
  }

  Future<void> _deleteAddress() async {
    await FirebaseFirestore.instance.collection('adresses').doc(_uid).delete();
  }

  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressPage(),
      ),
    );

    if (result == true && mounted) {
      // Optional: Show a success message or perform additional actions
      setState(() {}); // Force rebuild if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: 'My Addresses',
      subtitle: 'Your saved addresses',
      headerIcon: Icons.location_on,
      onPressed: _navigateToAddAddress,
      buttonText: "Add New Address",
      buttonIcon: Icons.add_location_alt_outlined,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _getAddressStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Adres bilgisi alınırken bir hata oluştu.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final doc = snapshot.data;
          if (doc == null || !doc.exists) {
            return buildEmptyState(
              icon: Icons.home_filled,
              title: "There are no addresses",
              subtitle: "You haven't added any addresses yet.",
            );
          }

          // Belge varsa, içindeki alanları alalım
          final data = doc.data()!;
          final title = data['title'] as String? ?? 'No title';
          final country = data['country'] as String? ?? '';
          final state = data['state'] as String? ?? '';
          final city = data['city'] as String? ?? '';
          final detailed = data['detailedAddress'] as String? ?? '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Dismissible(
                key: ValueKey(doc.id),
                direction: DismissDirection.startToEnd,
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showWarningDialog(
                    context,
                    () async {
                      await _deleteAddress();
                      setState(() {});
                    },
                    title: "Delete Address",
                    message: "Are you sure you want to delete this address?",
                    buttonText: "Delete",
                    icon: Icons.delete_outline,
                  );
                },
                child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      title,
                      style: GoogleFonts.poppins(),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (country.isNotEmpty)
                            Text(
                              'Country: $country',
                              style: GoogleFonts.poppins(),
                            ),
                          if (state.isNotEmpty)
                            Text(
                              'State: $state',
                              style: GoogleFonts.poppins(),
                            ),
                          if (city.isNotEmpty)
                            Text(
                              'City: $city',
                              style: GoogleFonts.poppins(),
                            ),
                          if (detailed.isNotEmpty)
                            Text(
                              'Address: $detailed',
                              style: GoogleFonts.poppins(),
                            ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      // Adres düzenleme sayfasına yönlendir
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
