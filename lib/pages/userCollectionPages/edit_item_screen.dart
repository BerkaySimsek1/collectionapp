import "dart:io";
import "package:collectionapp/common_ui_methods.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:image_picker/image_picker.dart";
import "package:collectionapp/models/predefined_collections.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:intl/intl.dart";
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';

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
        if (!_predefinedFieldValues.containsKey(key) &&
            key != "İsim" &&
            key != "Nadirlik" &&
            key != "Photos") {
          String type;

          if (value is int || value is double) {
            type = "NumberField";
          } else if (value is String) {
            try {
              DateTime.parse(value);
              type = "DatePicker";
            } catch (_) {
              type = "TextField";
            }
          } else {
            type = "TextField";
          }

          _customFields.add({"name": key, "type": type});
          _customFieldValues[key] = value;
        }
      });

      setState(() {});
    }
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
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                "You can add up to 5 photos",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ],
          ),
        ),
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

      if (!context.mounted) return;
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
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                "Item updated successfully!",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      Navigator.pop(context, true);
    }
  }

  void _addCustomField() {
    showDialog(
      context: context,
      builder: (context) {
        String fieldName = "";
        String fieldType = "TextField";
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Add Custom Field",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Field Name",
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              child: const Icon(
                                Icons.label_outline,
                                color: Colors.deepPurple,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) => fieldName = value,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          value: fieldType,
                          decoration: InputDecoration(
                            labelText: "Field Type",
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              child: const Icon(
                                Icons.category_outlined,
                                color: Colors.deepPurple,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: [
                            {"label": "Text", "value": "TextField"},
                            {"label": "Number", "value": "NumberField"},
                            {"label": "Date", "value": "DatePicker"},
                          ].map((type) {
                            return DropdownMenuItem<String>(
                              value: type["value"],
                              child: Text(
                                type["label"]!,
                                style: GoogleFonts.poppins(),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) fieldType = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (fieldName.isNotEmpty) {
                              setState(() {
                                _customFields.add(
                                    {"name": fieldName, "type": fieldType});
                                _customFieldValues[fieldName] = null;
                              });
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Add",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPredefinedFieldInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_predefinedFields.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            "Collection Fields",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
        ],
        ..._predefinedFields.map((field) {
          final fieldName = field["name"]!;
          final fieldType = field["type"]!;

          if (fieldType == "TextField" || fieldType == "NumberField") {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                initialValue: _predefinedFieldValues[fieldName]?.toString(),
                decoration: InputDecoration(
                  labelText: fieldName,
                  labelStyle: GoogleFonts.poppins(
                    color: Colors.grey[600],
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Icon(
                      fieldType == "NumberField"
                          ? Icons.numbers_outlined
                          : Icons.text_fields_outlined,
                      color: Colors.deepPurple,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: fieldType == "NumberField"
                    ? TextInputType.number
                    : TextInputType.text,
                onChanged: (value) {
                  setState(() {
                    _predefinedFieldValues[fieldName] =
                        fieldType == "NumberField"
                            ? int.tryParse(value)
                            : value;
                  });
                },
              ),
            );
          } else if (fieldType == "DatePicker") {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.deepPurple,
                              onPrimary: Colors.white,
                              onSurface: Colors.deepPurple.shade900,
                            ),
                            textTheme: projectTextTheme(context),
                            dialogTheme: DialogTheme(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() {
                        _predefinedFieldValues[fieldName] =
                            date.toIso8601String();
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fieldName,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _predefinedFieldValues[fieldName] != null
                                    ? DateFormat('dd.MM.yyyy').format(
                                        DateTime.parse(
                                            _predefinedFieldValues[fieldName]))
                                    : "Select Date",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildCustomFieldInputs() {
    return Column(
      children: _customFields.map((field) {
        final fieldName = field["name"];
        final fieldType = field["type"];

        Widget fieldWidget;
        if (fieldType == "TextField" || fieldType == "NumberField") {
          fieldWidget = TextFormField(
            initialValue: _customFieldValues[fieldName]?.toString(),
            decoration: InputDecoration(
              labelText: fieldName,
              labelStyle: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Icon(
                  fieldType == "NumberField"
                      ? Icons.numbers_outlined
                      : Icons.text_fields_outlined,
                  color: Colors.deepPurple,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: fieldType == "NumberField"
                ? TextInputType.number
                : TextInputType.text,
            onChanged: (value) {
              setState(() {
                _customFieldValues[fieldName] =
                    fieldType == "NumberField" ? int.tryParse(value) : value;
              });
            },
            style: GoogleFonts.poppins(),
          );
        } else {
          fieldWidget = InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.deepPurple,
                        onPrimary: Colors.white,
                        onSurface: Colors.deepPurple.shade900,
                      ),
                      textTheme: projectTextTheme(context),
                      dialogTheme: DialogTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() {
                  _customFieldValues[fieldName] = date.toIso8601String();
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fieldName,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _customFieldValues[fieldName] != null
                              ? DateFormat('dd.MM.yyyy').format(
                                  DateTime.parse(_customFieldValues[fieldName]))
                              : "Select Date",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              fieldWidget,
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _customFields.removeWhere((f) => f["name"] == fieldName);
                      _customFieldValues.remove(fieldName);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        // Stack eklendi
        children: [
          Column(
            children: [
              // Header Section
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        24, 0, 24, 80), // bottom padding 80'e çıkarıldı
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_box_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Edit Item",
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "to ${widget.collectionName}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Form Content
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -60), // -20'den -60'a değiştirildi
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView(
                      // SingleChildScrollView yerine ListView
                      padding: const EdgeInsets.all(24),
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Basic Information Section
                              Text(
                                "Basic Information",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: "Item Name",
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                    ),
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.deepPurple.withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.label_outline,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter a name";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _rarityController,
                                  decoration: InputDecoration(
                                    labelText: "Rarity",
                                    labelStyle: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                    ),
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.deepPurple.withOpacity(0.1),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.stars_outlined,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Images Section
                              Text(
                                "Item Images",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.deepPurple.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _pickImage,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        "Select Images",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (_selectedImages.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 120,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _selectedImages.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: _selectedImages[
                                                                index]
                                                            .path
                                                            .startsWith('http')
                                                        ? Image.network(
                                                            _selectedImages[
                                                                    index]
                                                                .path,
                                                            width: 120,
                                                            height: 120,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                return child;
                                                              }
                                                              return Container(
                                                                width: 120,
                                                                height: 120,
                                                                color: Colors
                                                                    .grey[200],
                                                                child: Center(
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    value: loadingProgress.expectedTotalBytes !=
                                                                            null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                            loadingProgress.expectedTotalBytes!
                                                                        : null,
                                                                    color: Colors
                                                                        .deepPurple,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )
                                                        : Image.file(
                                                            File(
                                                                _selectedImages[
                                                                        index]
                                                                    .path),
                                                            width: 120,
                                                            height: 120,
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),
                                                  Positioned(
                                                    top: 4,
                                                    right: 4,
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          _removeImage(index),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black
                                                              .withOpacity(0.5),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Text(
                                      "${_selectedImages.length}/5 images selected",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Predefined Fields Section
                              if (_predefinedFields.isNotEmpty) ...[
                                _buildPredefinedFieldInputs(),
                                const SizedBox(height: 24),
                              ],

                              // Custom Fields Section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Custom Fields",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _addCustomField,
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          Colors.deepPurple.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildCustomFieldInputs(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _isUploading ? null : () => _saveItem(context),
                child: _isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_outlined, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "Save Item",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
