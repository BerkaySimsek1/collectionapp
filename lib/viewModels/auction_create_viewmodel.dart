import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:collectionapp/models/AuctionModel.dart';

class AuctionCreateViewModel with ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<XFile> selectedImages = [];
  int selectedDays = 1;
  bool isUploading = false;

  Future<void> pickImages(BuildContext context) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.length <= 7) {
      selectedImages = images;
      notifyListeners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("En fazla 7 resim seçebilirsiniz.")),
      );
    }
  }

  Future<void> uploadAuction(BuildContext context) async {
    if (!formKey.currentState!.validate() ||
        selectedImages.isEmpty ||
        selectedDays < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Tüm alanları doldurun ve resim ekleyin.")),
      );
      return;
    }

    isUploading = true;
    notifyListeners();

    try {
      final DateTime endTime = DateTime.now().add(Duration(days: selectedDays));
      List<String> imageUrls = await _uploadImages();

      final auction = AuctionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        startingPrice: double.parse(priceController.text),
        creatorId: FirebaseAuth.instance.currentUser!.uid,
        endTime: endTime,
        description: descriptionController.text,
        imageUrls: imageUrls,
        isAuctionEnd: false,
      );

      await FirebaseFirestore.instance
          .collection("auctions")
          .doc(auction.id)
          .set(auction.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Auction successfully created!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (var image in selectedImages) {
      final compressedFile = await _compressImage(File(image.path));
      final storageRef = FirebaseStorage.instance.ref().child(
          "auction_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}");
      final uploadTask = await storageRef.putFile(compressedFile!);
      if (uploadTask.state == TaskState.success) {
        final downloadURL = await storageRef.getDownloadURL();
        imageUrls.add(downloadURL);
      } else {
        throw Exception("Image upload failed");
      }
    }
    return imageUrls;
  }

  Future<File?> _compressImage(File file) async {
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      "${file.parent.path}/compressed_${file.uri.pathSegments.last}",
      quality: 70, // %70 kalite
      minWidth: 800, // Maksimum genişlik
      minHeight: 600, // Maksimum yükseklik
    );
    return compressedFile != null ? File(compressedFile.path) : null;
  }

  void updateDuration(int days) {
    selectedDays = days;
    notifyListeners(); // Notify the listeners about the change
  }
}
