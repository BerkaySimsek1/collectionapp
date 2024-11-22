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

  Widget _buildFieldWidget({
    required String fieldName,
    required dynamic fieldValue,
  }) {
    // Alan türünü dinamik olarak çözümle
    if (fieldValue is String) {
      return ListTile(
        title: Text(fieldName),
        subtitle: Text(fieldValue),
      );
    } else if (fieldValue is int || fieldValue is double) {
      return ListTile(
        title: Text(fieldName),
        subtitle: Text(fieldValue.toString()),
      );
    } else {
      return ListTile(
        title: Text(fieldName),
        subtitle: const Text('Desteklenmeyen alan türü'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Detayları')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('userCollections')
            .doc(userId)
            .collection(collectionName)
            .doc(itemId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Ürün bulunamadı.'));
          }

          final item = snapshot.data!.data() as Map<String, dynamic>;

          // Dokümandaki tüm alanları dinamik olarak göster
          final fieldWidgets = item.entries.map((entry) {
            final fieldName = entry.key;
            final fieldValue = entry.value;

            // Özel olarak `customFields` listesini atlıyoruz
            if (fieldName == 'customFields') {
              return const SizedBox.shrink();
            }

            return _buildFieldWidget(
              fieldName: fieldName,
              fieldValue: fieldValue,
            );
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: fieldWidgets,
          );
        },
      ),
    );
  }
}
