import "dart:io";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:collectionapp/design_elements.dart";
import "package:intl/intl.dart";

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
    String displayValue;

    if (fieldValue is Timestamp) {
      // Firestore Timestamp ise, DateTime'e çevir
      DateTime dateTime = fieldValue.toDate();
      displayValue = DateFormat('dd.MM.yyyy').format(dateTime);
    } else if (fieldValue is DateTime) {
      // Eğer doğrudan DateTime geliyorsa
      displayValue = DateFormat('dd.MM.yyyy').format(fieldValue);
    } else if (fieldValue is String) {
      // Eğer string bir tarih ise, DateTime'a çevir ve formatla
      try {
        DateTime dateTime = DateTime.parse(fieldValue);
        displayValue = DateFormat('dd.MM.yyyy').format(dateTime);
      } catch (e) {
        // Eğer parse edilemezse, olduğu gibi göster
        displayValue = fieldValue;
      }
    } else {
      // Diğer durumlar için
      displayValue = fieldValue.toString();
    }

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
          displayValue,
          style: ProjectTextStyles.cardDescriptionTextStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const ProjectAppbar(
        titleText: "Item Details",
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("userCollections")
            .doc(userId)
            .collection("collectionsList")
            .doc(collectionName)
            .collection("items")
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
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photo = photos[index];
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 1,
                                  spreadRadius: 1,
                                  color: Colors.grey),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
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
