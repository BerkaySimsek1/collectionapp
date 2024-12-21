import "dart:async";
import "dart:io";
import "package:collectionapp/design_elements.dart";
import "package:collectionapp/firebase_methods/firestore_methods/auction_firestoremethods.dart";
import "package:collectionapp/models/AuctionModel.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class AuctionUploadScreen extends StatefulWidget {
  const AuctionUploadScreen({super.key});

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("En fazla 7 resim seçebilirsiniz.")),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Auction loaded successfully.")),
        );
        Navigator.of(context).pop();
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text(
                "The form is not valid, please complete the missing information."),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: const ProjectAppbar(
        titletext: "Create Auction",
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add your auction details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Auction Name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "This field is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: "Starting Price",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? "This field is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? "This field is required" : null,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Duration:",
                        style: ProjectTextStyles
                            .cardHeaderTextStyle, // Use a consistent text style
                      ),
                      const SizedBox(
                          width: 16), // Adjust spacing for better alignment
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                        child: DropdownButton<int>(
                          value: _selectedDays,
                          underline: Container(), // Remove default underline
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
                          style: ProjectTextStyles
                              .subtitleTextStyle, // Consistent text style
                          dropdownColor:
                              Colors.white, // Match dropdown color with theme
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.deepPurple),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Select Images",
                    style: ProjectTextStyles.buttonTextStyle,
                  ),
                  style: ProjectDecorations.elevatedButtonStyle,
                ),
                const SizedBox(height: 16),
                Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: _selectedImages
                      .map((image) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(image.path),
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _uploadAuction,
        child: const FinalFloatingDecoration(
          buttonText: "Upload Auction",
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
