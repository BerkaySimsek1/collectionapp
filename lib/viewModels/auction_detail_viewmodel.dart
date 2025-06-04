import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collectionapp/models/user_info_model.dart';
import 'package:collectionapp/models/auction_model.dart';
import 'package:collectionapp/firebase_methods/notification_methods.dart';

class AuctionDetailViewModel with ChangeNotifier {
  final AuctionModel auction;
  final User currentUser = FirebaseAuth.instance.currentUser!;
  final NotificationMethods _notificationMethods = NotificationMethods();
  UserInfoModel? creatorInfo;
  UserInfoModel? bidderInfo;

  AuctionDetailViewModel(this.auction) {
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    await _getUserInfo(auction.creatorId, (info) => creatorInfo = info);
    if (auction.bidderId.isNotEmpty) {
      await _getUserInfo(auction.bidderId, (info) => bidderInfo = info);
    }
    notifyListeners();
  }

  Future<void> _getUserInfo(
      String userId, Function(UserInfoModel) onSuccess) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      if (doc.exists) {
        onSuccess(UserInfoModel.fromJson(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      debugPrint("Error fetching user info: $e");
    }
  }

  Future<bool> deleteAuction() async {
    try {
      await FirebaseFirestore.instance
          .collection("auctions")
          .doc(auction.id)
          .delete();

      // İşlem başarılı
      return true;
    } catch (e) {
      debugPrint("Error deleting auction: $e");
      return false;
    }
  }

  Future<bool> editAuction(
      String newName, String newDescription, double newPrice) async {
    try {
      await FirebaseFirestore.instance
          .collection("auctions")
          .doc(auction.id)
          .update({
        "name": newName,
        "description": newDescription,
        "starting_price": newPrice,
      });

      auction.name = newName;
      auction.description = newDescription;
      auction.startingPrice = newPrice;

      await _loadUserInfo(); // Kullanıcı bilgilerini güncelle
      notifyListeners(); // UI'yi güncelle
      return true; // Başarılı
    } catch (e) {
      debugPrint("Error updating auction: $e");
      return false; // Başarısız
    }
  }

  Future<bool> placeBid(double bidAmount) async {
    if (bidAmount <= auction.startingPrice) {
      return false;
    }
    final user = FirebaseAuth.instance.currentUser;

    final userRef =
        FirebaseFirestore.instance.collection("users").doc(user!.uid);
    try {
      // Teklif geçmişini güncelle
      auction.addBid(currentUser.uid, bidAmount);

      await FirebaseFirestore.instance
          .collection("auctions")
          .doc(auction.id)
          .update({
        "starting_price": bidAmount,
        "bidder_id": currentUser.uid,
        "bid_history": auction.bidHistory.map((bid) => bid.toMap()).toList(),
      });

      // Kullanıcı bilgilerini güncelle, son aktivite tarihini yenile
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final userInfo =
            UserInfoModel.fromJson(userDoc.data() as Map<String, dynamic>);
        final updatedUserInfo = userInfo.updateLastActive();

        await userRef.update({
          "joinedAuctions": FieldValue.arrayUnion([auction.id]),
          "lastActive": updatedUserInfo.lastActive.millisecondsSinceEpoch,
        });
      }

      // Bildirim oluştur
      await _notificationMethods.createNotification(
        userId: auction.creatorId,
        auctionId: auction.id,
        title: 'New Bid',
        message:
            'Someone placed a bid of \$${bidAmount.toStringAsFixed(2)} on your auction "${auction.name}"',
        type: 'bid',
      );

      await _loadUserInfo(); // Bidder bilgilerini güncelle
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error placing bid: $e");
      return false;
    }
  }

  double calculateBidIncrement(double currentPrice) {
    if (currentPrice <= 20) {
      return 2;
    } else if (currentPrice <= 100) {
      return 5;
    } else if (currentPrice <= 250) {
      return 10;
    } else if (currentPrice <= 500) {
      return 25;
    } else if (currentPrice <= 1000) {
      return 100;
    } else {
      return 200;
    }
  }
}
