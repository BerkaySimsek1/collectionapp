import "dart:io";
import "package:collectionapp/design_elements.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:image_picker/image_picker.dart"; // Fotoğraf seçimi için
import "package:collectionapp/models/predefined_collections.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class AddItemScreen extends StatefulWidget {
  final String userId;
  final String collectionName;

  const AddItemScreen({
    super.key,
    required this.userId,
    required this.collectionName,
  });

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rarityController = TextEditingController();

  List<Map<String, String>> _predefinedFields = [];
  final Map<String, dynamic> _predefinedFieldValues = {};
  final List<Map<String, dynamic>> _customFields = [];
  final Map<String, dynamic> _customFieldValues = {};

  List<XFile> _selectedImages = [];
  bool _isUploading = false; // Yükleme durumunu izlemek için

  @override
  void initState() {
    super.initState();

    // Koleksiyon türüne göre alanları yükle
    if (predefinedCollections.containsKey(widget.collectionName)) {
      _predefinedFields = predefinedCollections[widget.collectionName]!;
      for (var field in _predefinedFields) {
        _predefinedFieldValues[field["name"]!] = null;
      }
    }
  }

  void _addCustomField() {
    showDialog(
      context: context,
      builder: (context) {
        String fieldName = "";
        String fieldType = "TextField";
        return AlertDialog(
          title: const Text(
            "Add Custom Field",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Field Name"),
                onChanged: (value) {
                  fieldName = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: fieldType,
                items: ["TextField", "NumberField", "DatePicker"]
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    fieldType = value;
                  }
                },
                decoration: const InputDecoration(labelText: "Field Type"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
            ),
            GestureDetector(
              // save button
              onTap: () {
                if (fieldName.isNotEmpty) {
                  setState(() {
                    _customFields.add({"name": fieldName, "type": fieldType});
                    _customFieldValues[fieldName] = null;
                  });
                  Navigator.pop(context);
                }
              },
              child: Container(
                height: 40,
                width: 60,
                decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: _isUploading
                      ? const CircularProgressIndicator() // indicator appears when loading
                      : const Text(
                          "Add",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.length <= 5) {
      setState(() {
        _selectedImages = images;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can add up to 5 photos.")),
      );
    }
  }

  Future<void> _saveItem(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true; // loading started
      });

      final itemName = _nameController.text.trim();
      final rarity = _rarityController.text.trim();
      final List<String> photoPaths = [];

      // upload multiple photos at the same time
      final List<Future> uploadTasks = _selectedImages.map((image) async {
        final storageRef = FirebaseStorage.instance.ref().child(
            "item_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}");

        final uploadTask = await storageRef.putFile(File(image.path));
        if (uploadTask.state == TaskState.success) {
          final downloadURL = await storageRef.getDownloadURL();
          photoPaths.add(downloadURL);
        } else {
          throw Exception("Couldn't loaded.");
        }
      }).toList();

      // Tüm yüklemeler tamamlanana kadar bekleyin
      await Future.wait(uploadTasks);

      final Map<String, dynamic> itemData = {
        "İsim": itemName,
        "Nadirlik": rarity,
        "Photos": photoPaths, // Fotoğraf yollarını kaydet
      };

      // Önceden tanımlı alanları ekle
      _predefinedFieldValues.forEach((key, value) {
        itemData[key] = value;
      });

      // Custom field değerlerini ekle
      _customFieldValues.forEach((key, value) {
        itemData[key] = value;
      });

      await FirebaseFirestore.instance
          .collection("userCollections")
          .doc(widget.userId)
          .collection(widget.collectionName)
          .add(itemData);

      setState(() {
        _isUploading = false; // Yükleme bitti
      });

      Navigator.pop(context);
    }
  }

  Widget _buildPredefinedFieldInputs() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _predefinedFields.length,
      itemBuilder: (context, index) {
        final field = _predefinedFields[index];
        final fieldName = field["name"]!;
        final fieldType = field["type"]!;

        if (fieldType == "TextField") {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: fieldName,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _predefinedFieldValues[fieldName] = value;
              },
            ),
          );
        } else if (fieldType == "NumberField") {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: fieldName,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _predefinedFieldValues[fieldName] = int.tryParse(value) ?? 0;
              },
            ),
          );
        } else if (fieldType == "DatePicker") {
          return ListTile(
            title: Text(fieldName),
            subtitle: Text(
              _predefinedFieldValues[fieldName]?.toString() ??
                  "Tarih seçilmedi",
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() {
                  _predefinedFieldValues[fieldName] = date.toIso8601String();
                });
              }
            },
          );
        } else if (fieldType == "Dropdown") {
          final options = field["options"]!.split(",");
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: fieldName,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: options
                  .map((option) =>
                      DropdownMenuItem(value: option, child: Text(option)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _predefinedFieldValues[fieldName] = value;
                });
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCustomFieldInputs() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _customFields.length,
      itemBuilder: (context, index) {
        final field = _customFields[index];
        final fieldName = field["name"];
        final fieldType = field["type"];

        if (fieldType == "TextField") {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: fieldName,
                filled: true, // optional decoration
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _customFieldValues[fieldName] = value;
              },
            ),
          );
        } else if (fieldType == "NumberField") {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: fieldName,
                filled: true, // optional decoration
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _customFieldValues[fieldName] = int.tryParse(value) ?? 0;
              },
            ),
          );
        } else if (fieldType == "DatePicker") {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: const Icon(
                  Icons.calendar_month_sharp,
                  color: Colors.deepPurple,
                ),
                title: Text(fieldName,
                    style: ProjectTextStyles.cardHeaderTextStyle),
                subtitle: Text(
                    _customFieldValues[fieldName]?.toString() ??
                        "Date must be selected.",
                    style: ProjectTextStyles.cardDescriptionTextStyle),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.deepPurple,
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _customFieldValues[fieldName] = date.toIso8601String();
                    });
                  }
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: const ProjectAppbar(
        titletext: "Add New Item",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Item Name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _rarityController,
                  decoration: InputDecoration(
                    labelText: "Rarity",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                      label: const Text("Select Images",
                          style: ProjectTextStyles.buttonTextStyle),
                      style: ProjectDecorations.elevatedButtonStyle),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Added Photos (${_selectedImages.length}/5):",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages
                      .length, // itemCount"u _selectedImages.length olarak ayarla
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      child: Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 3,
                              spreadRadius: 1,
                              color: Colors.grey,
                            )
                          ],
                        ),
                        child: Image.file(
                          File(_selectedImages[index]
                              .path), // Doğrudan item"dan image al
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildPredefinedFieldInputs(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                        onPressed: _addCustomField,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: const Text("Add Custom Field",
                            style: ProjectTextStyles.buttonTextStyle),
                        style: ProjectDecorations.elevatedButtonStyle),
                  ],
                ),
              ),
              _buildCustomFieldInputs(),
              const SizedBox(height: 48), // view adjustable custom fields
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        // save button
        onTap: _isUploading ? null : () => _saveItem(context),
        child:
            FinalFloatingDecoration(buttonText: "Save", progress: _isUploading),
      ),
    );
  }
}
