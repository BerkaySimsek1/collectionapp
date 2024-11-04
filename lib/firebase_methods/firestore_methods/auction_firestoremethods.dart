import 'package:collectionapp/models/AuctionModel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<void> updateAuctionField(
    String auctionId, String field, dynamic value) async {
  try {
    // Belirli bir alanı güncellemek için
    await FirebaseFirestore.instance
        .collection('auctions')
        .doc(auctionId)
        .update({field: value});
    print("Auction field updated successfully!");
  } catch (e) {
    print("Failed to update auction field: $e");
  }
}

Future<void> updateAuction(AuctionModel auction) async {
  try {
    // "auctions" koleksiyonunda id'si verilen belgeyi bulup günceller
    await FirebaseFirestore.instance
        .collection('auctions')
        .doc(auction.id)
        .update(auction.toMap());
    print("Auction updated successfully!");
  } catch (e) {
    print("Failed to update auction: $e");
  }
}

Future<void> uploadAuctionWithImages(
    AuctionModel auction, List<XFile> imageFiles) async {
  try {
    List<String> downloadUrls = [];

    // Her bir resmi Firebase Storage'a yükle
    for (var imageFile in imageFiles) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('auction_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Resmi yükleyin
      final uploadTask = await storageRef.putFile(File(imageFile.path));

      // Yükleme sonucunu kontrol edin
      if (uploadTask.state == TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } else {
        throw Exception("Resim yüklenemedi: ${uploadTask.state}");
      }
    }

    // Tüm resimler yüklendikten sonra URL'leri modele ekleyin
    final updatedAuction = AuctionModel(
      id: auction.id,
      name: auction.name,
      startingPrice: auction.startingPrice,
      creatorId: auction.creatorId,
      bidderId: auction.bidderId,
      endTime: auction.endTime,
      description: auction.description,
      imageUrls: downloadUrls,
      isAuctionEnd: false,
    );

    // Firestore'a ekleyin
    await FirebaseFirestore.instance
        .collection('auctions')
        .doc(updatedAuction.id)
        .set(updatedAuction.toMap());

    print("Açık artırma başarıyla yüklendi ve Firestore'a kaydedildi.");
  } catch (e) {
    print("Hata oluştu: $e");
  }
}
