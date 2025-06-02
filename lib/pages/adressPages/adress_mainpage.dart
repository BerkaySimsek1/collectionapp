// lib/pages/adressPages/adress_mainpage.dart

import 'package:collectionapp/common_ui_methods.dart';
import 'package:collectionapp/pages/adressPages/address_page.dart';
import 'package:collectionapp/widgets/common/project_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchAddressDoc() {
    return FirebaseFirestore.instance.collection('adresses').doc(_uid).get();
  }

  Future<void> _deleteAddress() async {
    await FirebaseFirestore.instance.collection('adresses').doc(_uid).delete();
  }

  @override
  Widget build(BuildContext context) {
    return ProjectLayout(
      title: 'My Addresses',
      subtitle: 'Your saved addresses',
      headerIcon: Icons.location_on,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _fetchAddressDoc(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Veri yüklenirken gösterilecek yükleme göstergesi
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Hata olursa kullanıcıya bilgi verin
            return const Center(
              child: Text(
                'Adres bilgisi alınırken bir hata oluştu.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final doc = snapshot.data;
          if (doc == null || !doc.exists) {
            // Adres yoksa, bir sonraki çerçevede AddressPage’e yönlendir
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddressPage(),
                ),
              );
            });
            return const SizedBox.shrink();
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
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  // Silme onayı almak isterseniz buraya dialog ekleyebilirsiniz.
                  return true;
                },
                onDismissed: (direction) async {
                  // Firestore’dan sil
                  await _deleteAddress();
                  projectSnackBar(context, 'Address deleted', 'green');
                  // Silme işleminden sonra adres ekleme sayfasına dön
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressPage(),
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (country.isNotEmpty) Text('Country: $country'),
                          if (state.isNotEmpty) Text('State: $state'),
                          if (city.isNotEmpty) Text('City: $city'),
                          if (detailed.isNotEmpty) Text('Address: $detailed'),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: ElevatedButton.icon(
          onPressed: () {
            // “Yeni Adres Ekle” butonuyla AddressPage’e gidebilir
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddressPage(),
              ),
            );
          },
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Add New Address'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
