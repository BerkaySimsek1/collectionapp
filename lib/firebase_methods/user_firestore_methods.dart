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

  // Kullanıcı, müzayede veya grup şikayetini Firebase'e kaydeder (yeni yapıya göre güncellendi)
  Future<void> reportUserOrAuction(
      String objectType, // "user", "auction", veya "group" olabilir
      String reporterId,
      String? reason,
      {String?
          reportedId, // Raporlanan kullanıcı ID'si, grupsa grup ID'si, müzayedeyse ilişkili kullanıcı ID'si
      String? auctionId // Sadece müzayede raporları için müzayede ID'si
      }) async {
    try {
      // "reports" koleksiyonunda yeni bir rapor için benzersiz bir ID oluştur
      final String newReportId = _firestore.collection("reports").doc().id;

      final Map<String, dynamic> reportDocumentData = {
        "type": objectType,
        "reporterId": reporterId,
        "reason": reason,
        "timestamp": FieldValue.serverTimestamp(),
        "status":
            "pending", // Varsayılan durum, admin panelinden güncellenebilir
      };

      // Rapor tipine göre özel alanları ekle
      if (objectType == "user") {
        // 'reportedId' parametresi, raporlanan kullanıcının ID'sidir.
        if (reportedId != null) {
          reportDocumentData["reportedId"] = reportedId;
        } else {
          debugPrint(
              "Kullanıcı raporu hatası: Raporlanan kullanıcı ID'si ('reportedId') null.");
          // Hata durumunu ele alabilir veya işlemi sonlandırabilirsiniz.
          return;
        }
      } else if (objectType == "auction") {
        // 'reportedId' parametresi, müzayede ile ilişkili kullanıcının ID'sidir (örneğin, satıcı).
        // 'auctionId' parametresi, müzayedenin kendi ID'sidir.
        // Bu, istediğin şemayla eşleşir (müzayede raporunda hem reportedId hem de auctionId bulunur).
        if (reportedId != null) {
          // Müzayede ile ilişkili kullanıcı
          reportDocumentData["reportedId"] = reportedId;
        }
        // auctionId alanı müzayede raporlarına özeldir
        if (auctionId != null) {
          reportDocumentData["auctionId"] = auctionId;
        } else {
          // İstediğin şemaya göre, müzayede raporları için auctionId mevcut olmalıdır.
          debugPrint("Müzayede raporu hatası: 'auctionId' null.");
          // Gereksinimlere bağlı olarak, bir hata fırlatılabilir veya işlem sonlandırılabilir.
          return;
        }
      } else if (objectType == "group") {
        // 'reportedId' parametresinin bir grup raporu için groupId olduğunu varsayıyoruz.
        if (reportedId != null) {
          reportDocumentData["reportedId"] =
              reportedId; // Bu, grup ID'si olacaktır.
        } else {
          debugPrint(
              "Grup raporu hatası: Raporlanan grup ID'si ('reportedId') null.");
          return;
        }
        // Not: 'auctionId' parametresi grup raporları için null olacaktır ve bu sorun değil.
      } else {
        debugPrint("Hata: Bilinmeyen rapor tipi '$objectType'.");
        return;
      }

      // Raporu yeni yapıya uygun olarak 'reports/{newReportId}' yoluna kaydet
      await _firestore
          .collection("reports")
          .doc(newReportId)
          .set(reportDocumentData);

      debugPrint(
          "Rapor (tip: $objectType) başarıyla reports/$newReportId adresine gönderildi.");
    } catch (e) {
      debugPrint(
          "$objectType tipi için reportUserOrAuction metodunda hata: $e");
      // İsteğe bağlı olarak hatayı yeniden fırlatabilir veya kullanıcı dostu bir şekilde ele alabilirsiniz.
      // throw Exception("Rapor gönderilemedi: $e");
    }
  }

  // Kullanıcının son aktif olma tarihini güncelle
  Future<bool> updateLastActive() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint("Son aktiflik güncellenirken hata: $e");
      return false;
    }
  }
}
