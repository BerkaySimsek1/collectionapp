import "dart:io";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/design_elements.dart";

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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          fieldName,
          style: ProjectTextStyles.cardHeaderTextStyle,
        ),
        subtitle: Text(
          fieldValue.toString(),
          style: ProjectTextStyles.cardDescriptionTextStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: const ProjectAppbar(
        titletext: "Item Details",
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("userCollections")
            .doc(userId)
            .collection(collectionName)
            .doc(itemId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "Item not found",
                style: ProjectTextStyles.subtitleTextStyle,
              ),
            );
          }

          final item = snapshot.data!.data() as Map<String, dynamic>;
          final photos = item["Photos"] as List<dynamic>?;

          final fieldWidgets = item.entries.map((entry) {
            final fieldName = entry.key;
            final fieldValue = entry.value;

            if (fieldName == "Photos") return const SizedBox.shrink();

            return _buildFieldWidget(
              fieldName: fieldName,
              fieldValue: fieldValue,
            );
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (photos != null && photos.isNotEmpty)
                Container(
                  height: 250,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: photo.startsWith('http')
                              ? Image.network(
                                  photo,
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error,
                                          color: Colors.red),
                                )
                              : Image.file(
                                  File(photo),
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.cover,
                                ),
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
