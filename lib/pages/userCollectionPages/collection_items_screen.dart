import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/pages/userCollectionPages/item_details_screen.dart';
import 'package:collectionapp/pages/userCollectionPages/add_item_screen.dart';

class CollectionItemsScreen extends StatelessWidget {
  final String userId;
  final String collectionName;

  const CollectionItemsScreen({
    Key? key,
    required this.userId,
    required this.collectionName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$collectionName Koleksiyonu')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('userCollections')
            .doc(userId)
            .collection(collectionName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Henüz ürün eklenmemiş.'));
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final photos = item['Photos'] as List<dynamic>?;

              return ListTile(
                leading: photos != null && photos.isNotEmpty
                    ? photos[0].startsWith(
                            'http') // URL olup olmadığını kontrol et
                        ? Image.network(
                            photos[0], // URL varsa network kullan
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(photos[0]), // Lokal dosya yoluysa file kullan
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                    : const Icon(Icons.image_not_supported),
                title: Text(item['İsim'] ?? 'İsimsiz Ürün'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Düzenle') {
                      // Düzenle işlemi
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddItemScreen(
                            userId: userId,
                            collectionName: collectionName,
                          ),
                        ),
                      );
                    } else if (value == 'Sil') {
                      // Silme işlemi
                      FirebaseFirestore.instance
                          .collection('userCollections')
                          .doc(userId)
                          .collection(collectionName)
                          .doc(item.id)
                          .delete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Düzenle',
                      child: Text('Düzenle'),
                    ),
                    const PopupMenuItem(
                      value: 'Sil',
                      child: Text('Sil'),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsScreen(
                        userId: userId,
                        collectionName: collectionName,
                        itemId: item.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemScreen(
                userId: userId,
                collectionName: collectionName,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
