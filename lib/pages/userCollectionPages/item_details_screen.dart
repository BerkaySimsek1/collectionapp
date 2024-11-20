import 'package:collectionapp/pages/userCollectionPages/add_field_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String userId;
  final String collectionName;
  final String itemId;

  const ItemDetailsScreen({
    Key? key,
    required this.userId,
    required this.collectionName,
    required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ürün Detayları')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('userCollections')
            .doc(userId)
            .collection(collectionName)
            .doc(itemId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Ürün bulunamadı.'));
          }

          final item = snapshot.data!.data() as Map<String, dynamic>;
          final customFields = item['customFields'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Ürün İsmi'),
                subtitle: Text(item['name'] ?? 'Belirtilmemiş'),
              ),
              ListTile(
                title: const Text('Nadirlik'),
                subtitle: Text(item['rarity'] ?? 'Belirtilmemiş'),
              ),
              const Divider(),
              ...customFields.map<Widget>((field) {
                final fieldName = field['name'];
                return ListTile(
                  title: Text(fieldName),
                  subtitle: Text(item[fieldName]?.toString() ?? 'Değer yok'),
                );
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFieldScreen(
                userId: userId,
                collectionName: collectionName,
                itemId: itemId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
