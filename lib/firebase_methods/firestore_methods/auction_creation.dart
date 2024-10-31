import 'package:collectionapp/models/AuctionModel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<void> uploadAuctionWithImage(
    AuctionModel auction, XFile imageFile) async {
  try {
    // Firebase Storage referansı oluştur
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('auction_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Resmi yükle
    await storageRef.putFile(File(imageFile.path));

    // Resmin URL'sini al
    final downloadUrl = await storageRef.getDownloadURL();

    // Image URL'yi modelde güncelleyerek yeni bir AuctionModel örneği oluştur
    final updatedAuction = AuctionModel(
      id: auction.id,
      name: auction.name,
      startingPrice: auction.startingPrice,
      creatorId: auction.creatorId,
      bidderId: auction.bidderId, // Başlangıçta boş olabilir
      endTime: auction.endTime, // Bitiş zamanı
      description: auction.description,
      imageUrl: downloadUrl, // Yeni yüklenen resmin URL'si
    );

    // Modeli Firestore’a kaydet
    await FirebaseFirestore.instance
        .collection('auctions')
        .doc(updatedAuction.id)
        .set(updatedAuction.toMap());

    print("Açık artırma başarıyla yüklendi ve Firestore'a kaydedildi.");
  } catch (e) {
    print("Hata oluştu: $e");
  }
}
