import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<void> pickImageFromCamera(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      if (selectedImages.length < 7) {
        selectedImages.add(image);
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("En fazla 7 resim seçebilirsiniz.")),
        );
      }
    }
  }

  Future<void> uploadAuction(BuildContext context) async {
    if (!formKey.currentState!.validate() ||
        selectedImages.isEmpty ||
        selectedDays < 1) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              "All the fields must be filled.",
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ));

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

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        // createdAuctions alanına yeni auction.id değerini ekliyoruz
        "createdAuctions": FieldValue.arrayUnion([auction.id]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                "Auction created successfully!",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                "Error: $e",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
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
