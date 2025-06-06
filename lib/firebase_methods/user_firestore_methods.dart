import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collectionapp/firebase_methods/notification_methods.dart';

class UserFirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationMethods _notificationMethods = NotificationMethods();

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

  // Para çekme işlemi
  Future<Map<String, dynamic>> withdrawFunds({
    required double amount,
    required String accountInfo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;

      if (currentBalance < amount) {
        return {'success': false, 'message': 'Insufficient balance'};
      }

      if (amount < 10) {
        return {
          'success': false,
          'message': 'Minimum withdrawal amount is \$10'
        };
      }

      final newBalance = currentBalance - amount;
      final transactionId =
          _firestore.collection('withdrawal_requests').doc().id;

      // Kullanıcının bakiyesini güncelle
      await _firestore.collection('users').doc(user.uid).update({
        'balance': newBalance,
      });

      // Para çekme talebini kaydet
      await _firestore.collection('withdrawal_requests').add({
        'userId': user.uid,
        'transactionId': transactionId,
        'amount': amount,
        'accountInfo': accountInfo,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      // Kullanıcıya bildirim gönder
      await _notificationMethods.createNotification(
        userId: user.uid,
        auctionId: '',
        title: 'Withdrawal Request Submitted',
        message:
            'Your withdrawal request of \$${amount.toStringAsFixed(2)} has been submitted and is being processed.',
        type: 'withdrawal',
      );

      return {
        'success': true,
        'message': 'Withdrawal request submitted successfully',
        'transactionId': transactionId,
        'amount': amount,
        'accountInfo': accountInfo,
      };
    } catch (e) {
      debugPrint('Error processing withdrawal: $e');
      return {'success': false, 'message': 'Failed to process withdrawal'};
    }
  }

  // Para ekleme işlemi
  Future<Map<String, dynamic>> addFunds({
    required double amount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance + amount;
      final transactionId = _firestore.collection('transactions').doc().id;

      // Kullanıcının bakiyesini güncelle
      await _firestore.collection('users').doc(user.uid).update({
        'balance': newBalance,
      });

      // İşlem kaydını tut
      await _firestore.collection('transactions').add({
        'userId': user.uid,
        'transactionId': transactionId,
        'type': 'add_funds',
        'amount': amount,
        'previousBalance': currentBalance,
        'newBalance': newBalance,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Funds added successfully',
        'transactionId': transactionId,
        'amount': amount,
        'newBalance': newBalance,
      };
    } catch (e) {
      debugPrint('Error adding funds: $e');
      return {'success': false, 'message': 'Failed to add funds'};
    }
  }

  // Kullanıcının bakiyesini getir
  Future<double> getUserBalance() async {
    final user = _auth.currentUser;
    if (user == null) return 0.0;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return (userData['balance'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      debugPrint('Error getting user balance: $e');
      return 0.0;
    }
  }

  // Başka kullanıcıya para ekleme (müzayede satışları için)
  Future<bool> addFundsToUser({
    required String userId,
    required double amount,
    required String description,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance + amount;

      await _firestore.collection('users').doc(userId).update({
        'balance': newBalance,
      });

      // İşlem kaydını tut
      await _firestore.collection('transactions').add({
        'userId': userId,
        'type': 'auction_sale',
        'amount': amount,
        'description': description,
        'previousBalance': currentBalance,
        'newBalance': newBalance,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error adding funds to user: $e');
      return false;
    }
  }

  // Composite payment işlemi (wallet + card)
  Future<Map<String, dynamic>> processCompositePayment({
    required String userId,
    required double totalAmount,
    required String cardId,
    required String description,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;

      if (currentBalance <= 0) {
        return {'success': false, 'message': 'No wallet balance available'};
      }

      final walletAmount = currentBalance;
      final cardAmount = totalAmount - walletAmount;

      if (cardAmount <= 0) {
        return {'success': false, 'message': 'Invalid payment calculation'};
      }

      // Wallet bakiyesini sıfırla (tüm bakiye kullanılıyor)
      await _firestore.collection('users').doc(userId).update({
        'balance': 0.0,
      });

      // İşlem kaydını tut
      final transactionId = _firestore.collection('transactions').doc().id;
      await _firestore.collection('transactions').add({
        'userId': userId,
        'transactionId': transactionId,
        'type': 'composite_payment',
        'totalAmount': totalAmount,
        'walletAmount': walletAmount,
        'cardAmount': cardAmount,
        'cardId': cardId,
        'description': description,
        'previousBalance': currentBalance,
        'newBalance': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Composite payment processed successfully',
        'transactionId': transactionId,
        'walletAmount': walletAmount,
        'cardAmount': cardAmount,
      };
    } catch (e) {
      debugPrint('Error processing composite payment: $e');
      return {
        'success': false,
        'message': 'Failed to process composite payment'
      };
    }
  }

  // Wallet'tan para çekme işlemi (müzayede ödemeleri için)
  Future<Map<String, dynamic>> deductFromWallet({
    required String userId,
    required double amount,
    required String description,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return {'success': false, 'message': 'User not found'};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;

      if (currentBalance < amount) {
        return {'success': false, 'message': 'Insufficient wallet balance'};
      }

      final newBalance = currentBalance - amount;

      // Kullanıcının bakiyesini güncelle
      await _firestore.collection('users').doc(userId).update({
        'balance': newBalance,
      });

      // İşlem kaydını tut
      final transactionId = _firestore.collection('transactions').doc().id;
      await _firestore.collection('transactions').add({
        'userId': userId,
        'transactionId': transactionId,
        'type': 'wallet_payment',
        'amount': amount,
        'description': description,
        'previousBalance': currentBalance,
        'newBalance': newBalance,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Payment deducted from wallet successfully',
        'transactionId': transactionId,
        'amount': amount,
        'newBalance': newBalance,
      };
    } catch (e) {
      debugPrint('Error deducting from wallet: $e');
      return {'success': false, 'message': 'Failed to deduct from wallet'};
    }
  }
}
