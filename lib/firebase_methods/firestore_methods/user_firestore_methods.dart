import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      print("Error fetching user data: $e");
      return null;
    }
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
      print("Error updating user data: $e");
    }
  }

  // Şifreyi güncelle
  Future<void> updatePassword(String newPassword) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await currentUser.updatePassword(newPassword);
    } catch (e) {
      print("Error updating password: $e");
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
      print("Error deleting account: $e");
      rethrow;
    }
  }
}
