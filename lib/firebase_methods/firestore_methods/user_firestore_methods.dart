import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserFirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı bilgilerini al
  Future<Map<String, dynamic>?> getUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(currentUser.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data();
  }

  // Kullanıcı bilgilerini güncelle
  Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore
          .collection("users")
          .doc(currentUser.uid)
          .update(updatedData);
    } catch (e) {
      debugPrint("Error updating user data: $e");
    }
  }

  // Şifreyi güncelle
  Future<void> updatePassword(String newPassword) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await currentUser.updatePassword(newPassword);
    } catch (e) {
      debugPrint("Error updating password: $e");
      rethrow;
    }
  }

  // Hesabı sil
  Future<void> deleteAccount() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore.collection("users").doc(currentUser.uid).delete();
      await currentUser.delete();
    } catch (e) {
      debugPrint("Error deleting account: $e");
      rethrow;
    }
  }

  // Kullanıcı veya auction şikayetini kaydet
  Future<void> reportUserOrAuction(
      String object, String reporterId, String? reason,
      {String? reportedId, String? auctionId}) async {
    try {
      final reportData = {
        "reporterId": reporterId,
        "reason": reason,
        "timestamp": FieldValue.serverTimestamp(),
        "reportedId": reportedId,
        "auctionId": auctionId,
      };

      if (object == "user") {
        await _firestore
            .collection("reports")
            .doc("user")
            .collection(reporterId)
            .add(reportData);
      } else if (object == "auction") {
        await _firestore
            .collection("reports")
            .doc("auction")
            .collection(reporterId)
            .add(reportData);
      }
    } catch (e) {
      debugPrint("Error reporting: $e");
    }
  }
}
