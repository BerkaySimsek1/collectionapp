import 'dart:async';
import 'dart:io';
import 'package:collectionapp/firebase_methods/firestore_methods/auction_firestoremethods.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuctionUploadScreen extends StatefulWidget {
  const AuctionUploadScreen({Key? key}) : super(key: key);

  @override
  _AuctionUploadScreenState createState() => _AuctionUploadScreenState();
}

class _AuctionUploadScreenState extends State<AuctionUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<XFile> _selectedImages = [];
  int _selectedDays = 1;
  DateTime? _endTime;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.length <= 7) {
      setState(() {
        _selectedImages = images;
      });
    } else {
      // Kullanıcıyı 7'den fazla resim seçemeyeceği konusunda bilgilendirin
      print("En fazla 7 resim seçebilirsiniz.");
    }
  }

  void _setEndTime() {
    final now = DateTime.now();
    setState(() {
      _endTime = now.add(Duration(days: _selectedDays));
    });
  }

  Future<void> _uploadAuction() async {
    _setEndTime();

    if (_formKey.currentState!.validate() &&
        _selectedImages.isNotEmpty &&
        _endTime != null) {
      final auction = AuctionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        startingPrice: double.parse(_priceController.text),
        creatorId: FirebaseAuth.instance.currentUser!.uid,
        endTime: _endTime!,
        description: _descriptionController.text,
        imageUrls: [],
        isAuctionEnd: false,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        await uploadAuctionWithImages(auction, _selectedImages);
        Navigator.of(context).pop();
        print("Açık artırma başarıyla yüklendi.");
      } catch (e) {
        Navigator.of(context).pop();
        print("Yükleme sırasında hata oluştu: $e");
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Form geçerli değil, eksik bilgileri tamamlayınız."),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auction Upload")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Auction Name"),
                  validator: (value) =>
                      value!.isEmpty ? "This field is required" : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration:
                      const InputDecoration(labelText: "Starting Price"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? "This field is required" : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? "This field is required" : null,
                ),
                const SizedBox(height: 10),
                DropdownButton<int>(
                  value: _selectedDays,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("1 Day")),
                    DropdownMenuItem(value: 2, child: Text("2 Days")),
                    DropdownMenuItem(value: 3, child: Text("3 Days")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDays = value!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text("Select Images"),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Wrap(
                    children: _selectedImages.map((image) {
                      return Image.file(File(image.path),
                          width: 100, height: 100);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _uploadAuction,
                  child: const Text("Upload Auction"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
