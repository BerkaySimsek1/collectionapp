import 'package:collectionapp/pages/userCollectionPages/add_item_screen.dart';
import 'package:collectionapp/pages/userCollectionPages/item_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Henüz ürün eklenmemiş.'));
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['name'] ?? 'İsimsiz Ürün'),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
