import "dart:io";
import "package:collectionapp/design_elements.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:path_provider/path_provider.dart";
import "package:collectionapp/pages/userCollectionPages/item_details_screen.dart";
import "package:collectionapp/pages/userCollectionPages/add_item_screen.dart";

class CollectionItemsScreen extends StatelessWidget {
  final String userId;
  final String collectionName;

  const CollectionItemsScreen({
    super.key,
    required this.userId,
    required this.collectionName,
  });

  Future<String> _ensureLocalCopy(String filePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = filePath.split("/").last;
    final newFilePath = "${appDir.path}/$fileName";

    final file = File(filePath);
    if (await file.exists()) {
      if (!await File(newFilePath).exists()) {
        await file.copy(newFilePath);
      }
      return newFilePath;
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: ProjectAppbar(
        titletext: "$collectionName Koleksiyonu",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("userCollections")
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
                  "No items added yet.",
                  style: ProjectTextStyles.subtitleTextStyle,
                ),
              );
            }

            final items = snapshot.data!.docs;

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final photos = item["Photos"] as List<dynamic>?;

                return FutureBuilder<String>(
                  future: photos != null && photos.isNotEmpty
                      ? _ensureLocalCopy(photos[0])
                      : Future.value(""),
                  builder: (context, fileSnapshot) {
                    if (fileSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final localPath = fileSnapshot.data ?? "";

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: photos != null && photos.isNotEmpty
                                ? Image.network(
                                    photos[0].toString(),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.deepPurple,
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error,
                                                color: Colors.red),
                                  )
                                : localPath.isNotEmpty
                                    ? Image.file(
                                        File(localPath.toString()),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.broken_image),
                          ),
                        ),
                        title: Text(
                          item["İsim"] ?? "İsimsiz Ürün",
                          style: ProjectTextStyles.cardHeaderTextStyle,
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == "Düzenle") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddItemScreen(
                                    userId: userId,
                                    collectionName: collectionName,
                                  ),
                                ),
                              );
                            } else if (value == "Sil") {
                              FirebaseFirestore.instance
                                  .collection("userCollections")
                                  .doc(userId)
                                  .collection(collectionName)
                                  .doc(item.id)
                                  .delete();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "Düzenle",
                              child: Text("Düzenle"),
                            ),
                            const PopupMenuItem(
                              value: "Sil",
                              child: Text("Sil"),
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
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
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
        style: ProjectDecorations.elevatedButtonStyle,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Item",
          style: ProjectTextStyles.buttonTextStyle,
        ),
      ),
    );
  }
}
