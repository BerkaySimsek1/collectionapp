import "package:collectionapp/design_elements.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "add_collection_screen.dart";
import "collection_items_screen.dart";

class UserCollectionsScreen extends StatelessWidget {
  final String userId;

  const UserCollectionsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const ProjectAppbar(
          titletext: "My Collections",
        ),
        backgroundColor: Colors.grey[200],
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üstte Karşılama Mesajı
              Text(
                "You can manage all your collections or add new ones here.",
                style: ProjectTextStyles.subtitleTextStyle,
              ),
              const SizedBox(height: 16),
              // Koleksiyonlar Listesi
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("userCollections")
                      .doc(userId)
                      .collection("collections")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text("No collections added yet",
                            style: ProjectTextStyles.subtitleTextStyle),
                      );
                    }

                    final collections = snapshot.data!.docs;
                    // Kaydırılabilir sekme
                    return ListView.builder(
                      itemCount: collections.length,
                      itemBuilder: (context, index) {
                        final collection = collections[index];
                        // Koleksiyon kartları
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            title: Text(
                              collection["name"],
                              style: ProjectTextStyles.cardHeaderTextStyle,
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                color: Colors.deepPurple),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CollectionItemsScreen(
                                    userId: userId,
                                    collectionName: collection["name"],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Yeni Koleksiyon Ekleme Butonu
        floatingActionButton: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddCollectionScreen(userId: userId),
              ),
            );
          },
          style: ProjectDecorations.elevatedButtonStyle,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Add Collection",
            style: ProjectTextStyles.buttonTextStyle,
          ),
        ));
  }
}
