import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String userId;
  final String collectionName;
  final String itemId;

  const ItemDetailsScreen({
    super.key,
    required this.userId,
    required this.collectionName,
    required this.itemId,
  });

  Widget _buildFieldWidget({
    required String fieldName,
    required dynamic fieldValue,
  }) {
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
          final photos = item['Photos'] as List<dynamic>?;

          // Fotoğrafları ve diğer alanları dinamik olarak göster
          final fieldWidgets = item.entries.map((entry) {
            final fieldName = entry.key;
            final fieldValue = entry.value;

            if (fieldName == 'Photos') return const SizedBox.shrink();

            return _buildFieldWidget(
              fieldName: fieldName,
              fieldValue: fieldValue,
            );
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (photos != null && photos.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: photo.startsWith('http')
                            ? Image.network(
                                photo, // URL ise network
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(photo), // Lokal dosya ise file
                                fit: BoxFit.cover,
                              ),
                      );
                    },
                  ),
                ),
              ...fieldWidgets,
            ],
          );
        },
      ),
    );
  }
}
