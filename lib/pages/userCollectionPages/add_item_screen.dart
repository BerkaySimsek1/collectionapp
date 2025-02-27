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

  List<XFile> selectedImages = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (predefinedCollections.containsKey(widget.collectionName)) {
      _predefinedFields = predefinedCollections[widget.collectionName]!;
      for (var field in _predefinedFields) {
        _predefinedFieldValues[field["name"]!] = null;
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.length <= 5) {
      setState(() {
        selectedImages = images;
      });
    } else {
      if (mounted) {
        projectSnackBar(context, "You can add up to 5 photos.", "red");
      }
    }
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
        _isUploading = true; // loading started
      });

      final itemName = _nameController.text.trim();
      final rarity = _rarityController.text.trim();
      final List<String> photoPaths = [];

      // upload multiple photos at the same time
      final List<Future> uploadTasks = selectedImages.map((image) async {
        final compressedFile = await _compressImage(File(image.path));
        final storageRef = FirebaseStorage.instance.ref().child(
            "item_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}");

        final uploadTask = await storageRef.putFile(compressedFile!);
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
        "Photos": photoPaths,
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
          .collection("collectionsList")
          .doc(widget.collectionName)
          .collection("items")
          .add(itemData);

      setState(() {
        _isUploading = false; // Yükleme bitti
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const ProjectBackButton(),
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
                                    "Add New Item",
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
                                  style: GoogleFonts.poppins(),
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
                                  style: GoogleFonts.poppins(),
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
                                    if (selectedImages.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 120,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: selectedImages.length,
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
                                                    child: Image.file(
                                                      File(selectedImages[index]
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
                                                      onTap: () {
                                                        setState(() {
                                                          selectedImages
                                                              .removeAt(index);
                                                        });
                                                      },
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
                                      "${selectedImages.length}/5 images selected",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Predefined Fields Section
                              if (_predefinedFields.isNotEmpty) ...[
                                Text(
                                  "Collection Fields",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                    onPressed: () => addCustomField(
                                        context,
                                        _customFields,
                                        _customFieldValues,
                                        setState),
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : () => _saveItem(context),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.save_outlined, color: Colors.white),
        label: _isUploading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Save Item",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Widget _buildPredefinedFieldInputs() {
    return Column(
      children: _predefinedFields.map((field) {
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
                      fieldType == "NumberField" ? int.tryParse(value) : value;
                });
              },
              style: GoogleFonts.poppins(),
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
        } else if (fieldType == "Dropdown") {
          final options = field["options"]!.split(",");
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                  child: const Icon(
                    Icons.arrow_drop_down,
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
              items: options
                  .map((option) => DropdownMenuItem(
                      value: option,
                      child: Text(
                        option,
                        style: GoogleFonts.poppins(),
                      )))
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
      }).toList(),
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
}
