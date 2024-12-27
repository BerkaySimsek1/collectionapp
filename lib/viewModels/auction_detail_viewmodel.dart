import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collectionapp/models/UserInfoModel.dart';
import 'package:collectionapp/models/AuctionModel.dart';

class AuctionDetailViewModel with ChangeNotifier {
  final AuctionModel auction;
  final User currentUser = FirebaseAuth.instance.currentUser!;
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

  Future<void> editAuction(
      BuildContext context, String newName, String newDescription) async {
    try {
      await FirebaseFirestore.instance
          .collection("auctions")
          .doc(auction.id)
          .update({
        "name": newName,
        "description": newDescription,
      });
      auction.name = newName;
      auction.description = newDescription;

      await _loadUserInfo(); // Kullanıcı bilgilerini güncelle
      notifyListeners(); // UI'yi güncelle
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Auction updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating auction: $e")),
      );
    }
  }

  Future<void> placeBid(double bidAmount, BuildContext context) async {
    if (bidAmount <= auction.startingPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid bid amount.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("auctions")
          .doc(auction.id)
          .update({
        "starting_price": bidAmount,
        "bidder_id": currentUser.uid,
      });
      auction.startingPrice = bidAmount;
      auction.bidderId = currentUser.uid;

      await _loadUserInfo(); // Update bidder info
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bid placed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing bid: $e")),
      );
    }
  }
}
