import 'dart:io';
import 'package:collectionapp/common_ui_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collectionapp/firebase_methods/SM_firestore_methods.dart';
import 'package:collectionapp/models/predefined_collections.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupService = GroupService();
  final _currentUser = FirebaseAuth.instance.currentUser;

  String _name = '';
  String _description = '';
  String _category = 'Diğer';
  File? _coverImage;
  bool _isLoading = false;

  final List<String> _categories = [
    'Diğer',
    ...predefinedCollections.keys,
  ];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        await _groupService.createGroup(
          name: _name,
          description: _description,
          creatorId: _currentUser!.uid,
          category: _category,
          coverImage: _coverImage,
        );

        if (mounted) {
          projectSnackBar(context, "Group created successfully", "green");
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          projectSnackBar(context, "Failed to create group: $e", "red");
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const ProjectIconButton(),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Gradient Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade900,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.group_add,
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
                                    "Create New Group",
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Fill in the details below",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
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
                  offset: const Offset(0, -60),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cover Image Section
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade50,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Kapak Resmi Seçimi
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.deepPurple
                                              .withValues(alpha: 0.3),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: _coverImage != null
                                          ? Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18), // border width'i düşünerek 18
                                                  child: Image.file(
                                                    _coverImage!,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                // Kaldırma butonu
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.6),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _coverImage = null;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepPurple
                                                        .withValues(alpha: 0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons
                                                        .add_photo_alternate_outlined,
                                                    color: Colors.deepPurple,
                                                    size: 32,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  "Add Cover Image",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.deepPurple,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Tap to upload a cover image",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Group Details Section
                            Text(
                              "Group Details",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Group Name Field
                            _buildTextField(
                              label: "Group Name",
                              icon: Icons.group,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a group name';
                                }
                                return null;
                              },
                              onSaved: (value) => _name = value!,
                            ),
                            const SizedBox(height: 16),

                            // Description Field
                            _buildTextField(
                              label: "Description",
                              icon: Icons.description,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                              onSaved: (value) => _description = value!,
                            ),
                            const SizedBox(height: 16),

                            // Category Dropdown
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                value: _category,
                                decoration: InputDecoration(
                                  labelText: "Category",
                                  labelStyle: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                  prefixIcon: Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple
                                          .withValues(alpha: 0.15),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.category,
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
                                items: _categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _category = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Create Button
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
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
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
                          const Icon(Icons.group_add, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "Create Group",
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    int? maxLines,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
        onSaved: onSaved,
        style: GoogleFonts.poppins(),
      ),
    );
  }
}
