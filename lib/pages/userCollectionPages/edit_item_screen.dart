import "dart:io";
import "package:collectionapp/design_elements.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:image_picker/image_picker.dart";
import "package:collectionapp/models/predefined_collections.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:intl/intl.dart";
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditItemScreen extends StatefulWidget {
  final String userId;
  final String collectionName;
  final String itemId;

  const EditItemScreen({
    super.key,
    required this.userId,
    required this.collectionName,
    required this.itemId,
  });

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rarityController = TextEditingController();

  List<Map<String, String>> _predefinedFields = [];
  final Map<String, dynamic> _predefinedFieldValues = {};
  final List<Map<String, dynamic>> _customFields = [];
  final Map<String, dynamic> _customFieldValues = {};

  List<XFile> _selectedImages = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadItemData();
  }

  Future<void> _loadItemData() async {
    final doc = await FirebaseFirestore.instance
        .collection("userCollections")
        .doc(widget.userId)
        .collection("collectionsList")
        .doc(widget.collectionName)
        .collection("items")
        .doc(widget.itemId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data["İsim"] ?? "";
      _rarityController.text = data["Nadirlik"] ?? "";
      _selectedImages = (data["Photos"] as List<dynamic>)
          .map((photo) => XFile(photo))
          .toList();

      // Predefined Fields
      if (predefinedCollections.containsKey(widget.collectionName)) {
        _predefinedFields = predefinedCollections[widget.collectionName]!;
        for (var field in _predefinedFields) {
          _predefinedFieldValues[field["name"]!] = data[field["name"]!];
        }
      }

      // Custom Fields
      data.forEach((key, value) {
        // Önemli alanları atla
        if (!_predefinedFieldValues.containsKey(key) &&
            key != "İsim" &&
            key != "Nadirlik" &&
            key != "Photos") {
          String type;

          if (value is int || value is double) {
            type = "NumberField";
          } else if (value is String) {
            // Tarih formatını kontrol et
            try {
              DateTime.parse(value);
              type = "DatePicker";
            } catch (_) {
              type = "TextField";
            }
          } else {
            type = "TextField"; // Varsayılan olarak TextField
          }

          _customFields.add({"name": key, "type": type});
          _customFieldValues[key] = value;
        }
      });

      setState(() {});
    }
  }

  void _addCustomField() {
    showDialog(
      context: context,
      builder: (context) {
        String fieldName = "";
        String fieldType = "TextField";
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            "Add Custom Field",
            style: ProjectTextStyles.appBarTextStyle,
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
                items: [
                  {"label": "Text", "value": "TextField"},
                  {"label": "Number", "value": "NumberField"},
                  {"label": "Date", "value": "DatePicker"},
                ].map((type) {
                  return DropdownMenuItem<String>(
                    value: type["value"], // Arka planda kullanılacak değer
                    child: Text(type["label"]!), // Kullanıcının göreceği etiket
                  );
                }).toList(),
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
    if (_selectedImages.length + images.length <= 5) {
      setState(() {
        _selectedImages.addAll(images);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can add up to 5 photos.")),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<File?> _compressImage(File file) async {
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      "${file.parent.path}/compressed_${file.uri.pathSegments.last}",
      quality: 70,
      minWidth: 800,
      minHeight: 600,
    );
    return compressedFile != null ? File(compressedFile.path) : null;
  }

  Future<void> _saveItem(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      final itemName = _nameController.text.trim();
      final rarity = _rarityController.text.trim();
      final List<String> photoPaths = [];

      final List<Future> uploadTasks = _selectedImages.map((image) async {
        if (image.path.startsWith('http')) {
          photoPaths.add(image.path);
        } else {
          final compressedFile = await _compressImage(File(image.path));
          final storageRef = FirebaseStorage.instance.ref().child(
              "item_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}");

          final uploadTask = await storageRef.putFile(compressedFile!);
          if (uploadTask.state == TaskState.success) {
            final downloadURL = await storageRef.getDownloadURL();
            photoPaths.add(downloadURL);
          } else {
            throw Exception("Couldn't load.");
          }
        }
      }).toList();

      await Future.wait(uploadTasks);

      final Map<String, dynamic> itemData = {
        "İsim": itemName,
        "Nadirlik": rarity,
        "Photos": photoPaths,
      };

      _predefinedFieldValues.forEach((key, value) {
        itemData[key] = value;
      });

      _customFieldValues.forEach((key, value) {
        itemData[key] = value;
      });

      await FirebaseFirestore.instance
          .collection("userCollections")
          .doc(widget.userId)
          .collection("collectionsList")
          .doc(widget.collectionName)
          .collection("items")
          .doc(widget.itemId)
          .update(itemData);

      setState(() {
        _isUploading = false;
      });

      Navigator.pop(context, true); // Return true to indicate success
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
              initialValue: _predefinedFieldValues[fieldName]?.toString(),
              decoration: InputDecoration(
                labelText: fieldName,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
              initialValue: _predefinedFieldValues[fieldName]?.toString(),
              decoration: InputDecoration(
                labelText: fieldName,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
              _predefinedFieldValues[fieldName] != null
                  ? DateFormat('dd.MM.yyyy')
                      .format(DateTime.parse(_predefinedFieldValues[fieldName]))
                  : "Tarih seçilmedi",
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
              value: _predefinedFieldValues[fieldName]?.toString(),
              decoration: InputDecoration(
                labelText: fieldName,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
              initialValue: _customFieldValues[fieldName]?.toString(),
              decoration: InputDecoration(
                labelText: fieldName,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
              initialValue: _customFieldValues[fieldName]?.toString(),
              decoration: InputDecoration(
                labelText: fieldName,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
                  _customFieldValues[fieldName] != null
                      ? (() {
                          try {
                            final date =
                                DateTime.parse(_customFieldValues[fieldName]);
                            return DateFormat('dd.MM.yyyy').format(date);
                          } catch (e) {
                            return _customFieldValues[fieldName].toString();
                          }
                        })()
                      : "Date must be selected.",
                  style: ProjectTextStyles.cardDescriptionTextStyle,
                ),
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
      backgroundColor: Colors.grey[100],
      appBar: const ProjectAppbar(
        titleText: "Edit Item",
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
                    borderRadius: BorderRadius.circular(8),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
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
                    style: ProjectDecorations.elevatedButtonStyle,
                  ),
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
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Padding(
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
                            child:
                                buildImageWidget(_selectedImages[index].path),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
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
                      style: ProjectDecorations.elevatedButtonStyle,
                    ),
                  ],
                ),
              ),
              _buildCustomFieldInputs(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _isUploading ? null : () => _saveItem(context),
        child:
            FinalFloatingDecoration(buttonText: "Save", progress: _isUploading),
      ),
    );
  }
}

Widget buildImageWidget(String path) {
  if (path.startsWith('http')) {
    // If it's an HTTP(S) URL from Firebase Storage
    return Image.network(
      path,
      width: 150,
      height: 150,
      fit: BoxFit.cover,
    );
  } else {
    // Otherwise assume it's a local file path
    return Image.file(
      File(path),
      width: 150,
      height: 150,
      fit: BoxFit.cover,
    );
  }
}
