import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addCollectionItem({
    required String userId,
    required String collectionName,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db
          .collection("userCollections")
          .doc(userId)
          .collection(collectionName)
          .add(data);
    } catch (e) {
      debugPrint("Error adding collection item: $e");
      rethrow;
    }
  }

  Future<DocumentSnapshot> getDocument({
    required String userId,
    required String collectionName,
    required String docId,
  }) async {
    try {
      return await _db
          .collection("userCollections")
          .doc(userId)
          .collection(collectionName)
          .doc(docId)
          .get();
    } catch (e) {
      debugPrint("Error fetching document: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getCollectionItems({
    required String userId,
    required String collectionName,
  }) {
    return _db
        .collection("userCollections")
        .doc(userId)
        .collection(collectionName)
        .snapshots();
  }

  Future<void> updateCollectionItem({
    required String userId,
    required String collectionName,
    required String docId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      await _db
          .collection("userCollections")
          .doc(userId)
          .collection(collectionName)
          .doc(docId)
          .update(updatedData);
    } catch (e) {
      debugPrint("Error updating collection item: $e");
      rethrow;
    }
  }

  Future<void> deleteCollectionItem({
    required String userId,
    required String collectionName,
    required String docId,
  }) async {
    try {
      await _db
          .collection("userCollections")
          .doc(userId)
          .collection(collectionName)
          .doc(docId)
          .delete();
    } catch (e) {
      debugPrint("Error deleting collection item: $e");
      rethrow;
    }
  }
}
