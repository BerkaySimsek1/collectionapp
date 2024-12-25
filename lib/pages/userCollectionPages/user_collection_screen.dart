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
        titleText: "My Collections",
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "You can manage all your collections or add new ones here.",
              style: ProjectTextStyles.subtitleTextStyle,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("userCollections")
                    .doc(userId)
                    .collection("collectionsList")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No collections added yet",
                        style: ProjectTextStyles.subtitleTextStyle,
                      ),
                    );
                  }

                  final collections = snapshot.data!.docs;

                  // Bu dokümanların ID’si senin "collectionName" değerlerini tutuyor (ya da doc["name"]).
                  return ListView.builder(
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final collectionDoc = collections[index];

                      // Eğer doc ID'siyle tutuyorsan:
                      final collectionName = collectionDoc.id;

                      // Veya doc'un içinde "name" alanıyla tutuyorsan:
                      // final collectionName = collectionDoc["name"];

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          title: Text(
                            collectionName,
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
                                  collectionName: collectionName,
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
      ),
    );
  }
}
