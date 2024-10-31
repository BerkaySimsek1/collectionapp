import 'dart:async';
import 'dart:io';
import 'package:collectionapp/firebase_methods/firestore_methods/auction_creation.dart';
import 'package:collectionapp/image_picker.dart';
import 'package:collectionapp/models/AuctionModel.dart';
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
  XFile? _selectedImage;
  int _selectedDays = 1; // Varsayılan olarak 1 gün
  DateTime? _endTime;

  Future<void> _pickImage() async {
    final image = await pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _setEndTime() {
    // "Açık Artırmayı Yükle" tuşuna basılınca gün sayısına göre bitiş zamanını hesapla
    final now = DateTime.now();
    setState(() {
      _endTime = now.add(Duration(days: _selectedDays));
    });
  }

  Future<void> _uploadAuction() async {
    // Gün sayısına göre endTime'i hesapla
    _setEndTime();

    if (_formKey.currentState!.validate() &&
        _selectedImage != null &&
        _endTime != null) {
      final auction = AuctionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        startingPrice: double.parse(_priceController.text),
        creatorId: 'user_id', // Bu alanı kullanıcı kimliği ile güncelleyin
        endTime: _endTime!,
        description: _descriptionController.text,
        imageUrl: '',
      );

      await uploadAuctionWithImage(auction, _selectedImage!);
      print("Açık artırma yüklendi ve geri sayım başlatıldı.");
    } else {
      print("Form geçerli değil, resim veya süre seçilmedi.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auction Upload"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(labelText: "Açık Artırma İsmi"),
                validator: (value) =>
                    value!.isEmpty ? "Bu alan zorunludur" : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration:
                    const InputDecoration(labelText: "Başlangıç Fiyatı"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Bu alan zorunludur" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Açıklama"),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? "Bu alan zorunludur" : null,
              ),
              const SizedBox(height: 10),
              DropdownButton<int>(
                value: _selectedDays,
                items: const [
                  DropdownMenuItem(value: 1, child: Text("1 Gün")),
                  DropdownMenuItem(value: 2, child: Text("2 Gün")),
                  DropdownMenuItem(value: 3, child: Text("3 Gün")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDays = value!;
                  });
                },
              ),
              _selectedImage == null
                  ? ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text("Resim Seç"),
                    )
                  : Image.file(File(_selectedImage!.path), height: 150),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadAuction,
                child: const Text("Açık Artırmayı Yükle"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
