import 'dart:io';

import 'package:collectionapp/design_elements.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart'; // Kalıcı dosyalar için gerekli
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

  Future<String> _ensureLocalCopy(String filePath) async {
    // Eğer dosya geçiciyse, kalıcı bir yere kopyala
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = filePath.split('/').last;
    final newFilePath = '${appDir.path}/$fileName';

    final file = File(filePath);
    if (await file.exists()) {
      if (!await File(newFilePath).exists()) {
        await file.copy(newFilePath);
      }
      return newFilePath;
    } else {
      return ''; // Dosya mevcut değilse boş bir yol döndür
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: ProjectAppbar(
          titletext: "$collectionName Koleksiyonu",
        ),
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
              return Center(
                  child: Text(
                'No items added yet.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ));
            }

            final items = snapshot.data!.docs;

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final photos = item['Photos'] as List<dynamic>?;

                return FutureBuilder<String>(
                  future: photos != null && photos.isNotEmpty
                      ? _ensureLocalCopy(photos[0])
                      : Future.value(''),
                  builder: (context, fileSnapshot) {
                    if (fileSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final localPath = fileSnapshot.data ?? '';

                    return ListTile(
                      leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: photos != null && photos.isNotEmpty
                              ? Image.network(
                                  photos[0].toString(),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : localPath.isNotEmpty
                                  ? Image.file(
                                      File(localPath.toString()),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.broken_image)),
                      title: Text(item['İsim'] ?? 'İsimsiz Ürün'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'Düzenle') {
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
            );
          },
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
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
          child: const AddFloatingDecoration(
            buttonText: "Add Item",
          ),
        ));
  }
}
