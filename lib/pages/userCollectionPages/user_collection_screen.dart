import "package:collectionapp/design_elements.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "add_collection_screen.dart";
import "collection_items_screen.dart";

class UserCollectionsScreen extends StatelessWidget {
  final String userId;

  const UserCollectionsScreen({super.key, required this.userId});

  // Koleksiyon türüne göre ikon oluşturma
  IconData _getIconForCollectionType(String type) {
    switch (type) {
      case 'Record':
        return Icons.music_note;
      case 'Stamp':
        return Icons.stay_primary_landscape;
      case 'Coin':
        return Icons.money;
      case 'Book':
        return Icons.book;
      case 'Painting':
        return Icons.photo;
      case 'Comic Book':
        return Icons.book_online;
      case 'Vintage Posters':
        return Icons.mediation;
      case 'Diğer':
        return Icons.more_horiz;
      default:
        return Icons.more_horiz;
    }
  }

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
          crossAxisAlignment: CrossAxisAlignment.start,
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

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final collectionDoc = collections[index];
                      final collectionName = collectionDoc.id;
                      final collectionData =
                          collectionDoc.data() as Map<String, dynamic>;
                      final collectionType = collectionData['name'] ?? 'Diğer';

                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                radius: 30,
                                child: Icon(
                                  _getIconForCollectionType(collectionType),
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                collectionName,
                                style: ProjectTextStyles.cardHeaderTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCollectionScreen(userId: userId),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Collection",
          style: ProjectTextStyles.buttonTextStyle,
        ),
      ),
    );
  }
}
