import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuctionModel {
  String id;
  String name;
  double startingPrice;
  String creatorId;
  String bidderId;
  DateTime endTime;
  String description;
  List<String> imageUrls; // Tek resim yerine liste yapısına dönüştürdük
  bool isAuctionEnd;
  List<Bid> bidHistory; // Teklif geçmişi için yeni alan
  String? status; // Yeni durum alanı, null olabilir

  AuctionModel({
    required this.id,
    required this.name,
    required this.startingPrice,
    required this.creatorId,
    this.bidderId = "",
    required this.endTime,
    required this.description,
    required this.imageUrls,
    required this.isAuctionEnd,
    this.status,
    List<Bid>? bidHistory,
  }) : bidHistory = bidHistory ?? [];

  // Firestore"a eklemek için veriyi Map"e dönüştürme
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "starting_price": startingPrice,
      "creator_id": creatorId,
      "bidder_id": bidderId,
      "end_time": endTime.millisecondsSinceEpoch,
      "description": description,
      "image_urls": imageUrls, // Liste olarak kaydediliyor
      "created_at": DateTime.now().millisecondsSinceEpoch,
      "isAuctionEnd": isAuctionEnd,
      "status": status,
      "bid_history": bidHistory
          .map((bid) => bid.toMap())
          .toList(), // Teklif geçmişini Map listesine dönüştür
    };
  }

  // Firestore"dan veriyi alırken AuctionModel"e dönüştürme
  factory AuctionModel.fromMap(Map<String, dynamic> map) {
    List<dynamic> bidHistoryData = map["bid_history"] ?? [];
    List<Bid> bids = bidHistoryData
        .map((bidData) => Bid.fromMap(bidData as Map<String, dynamic>))
        .toList();

    return AuctionModel(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      startingPrice: map["starting_price"]?.toDouble() ?? 0.0,
      creatorId: map["creator_id"] ?? "",
      bidderId: map["bidder_id"] ?? "",
      endTime: DateTime.fromMillisecondsSinceEpoch(map["end_time"] ?? 0),
      description: map["description"] ?? "",
      imageUrls:
          List<String>.from(map["image_urls"] ?? []), // Listeye dönüştürme
      isAuctionEnd: map["isAuctionEnd"] ?? false,
      status: map["status"] as String?,
      bidHistory: bids,
    );
  }

  // Yeni teklif ekleme yardımcı metodu
  void addBid(String userId, double amount) {
    bidHistory.add(Bid(
      userId: userId,
      amount: amount,
      timestamp: DateTime.now(),
    ));
    bidderId = userId;
    startingPrice = amount;
  }

  static Future<AuctionModel?> fromId(String id) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('auctions').doc(id).get();
      if (doc.exists) {
        return AuctionModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching auction: $e');
      return null;
    }
  }
}

// Teklif modelini tanımlıyoruz
class Bid {
  final String userId;
  final double amount;
  final DateTime timestamp;

  Bid({
    required this.userId,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "amount": amount,
      "timestamp": timestamp.millisecondsSinceEpoch,
    };
  }

  factory Bid.fromMap(Map<String, dynamic> map) {
    return Bid(
      userId: map["user_id"] ?? "",
      amount: map["amount"]?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map["timestamp"] ?? 0),
    );
  }
}
