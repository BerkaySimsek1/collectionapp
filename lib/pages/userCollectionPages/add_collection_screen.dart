import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/common_ui_methods.dart';
import 'package:collectionapp/widgets/common/project_single_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collectionapp/models/predefined_collections.dart';

class AddCollectionScreen extends StatefulWidget {
  final String userId;

  const AddCollectionScreen({super.key, required this.userId});

  @override
  AddCollectionScreenState createState() => AddCollectionScreenState();
}

class AddCollectionScreenState extends State<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCollection;
  final TextEditingController _customCollectionController =
      TextEditingController();
  bool _isLoading = false;

  void _onCollectionTypeChanged(String? value) {
    setState(() {
      _selectedCollection = value;
    });
  }

  Future<void> _saveCollection(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final collectionName = _selectedCollection == "Diğer"
            ? _customCollectionController.text.trim()
            : _selectedCollection;

        await FirebaseFirestore.instance
            .collection("userCollections")
            .doc(widget.userId)
            .collection("collectionsList")
            .doc(collectionName)
            .set({
          "name": collectionName,
          "createdAt": DateTime.now().toIso8601String(),
        });

        if (mounted) Navigator.pop(context);
      } catch (e) {
        // Error handling
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProjectSingleLayout(
      title: "Add New Collection",
      subtitle: "Choose a collection type or create your own",
      headerIcon: Icons.add_box_outlined,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Collection Details",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24), // Collection Type Dropdown
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
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: Colors.white,
                  value: _selectedCollection,
                  decoration: InputDecoration(
                    labelText: "Collection Type",
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
                      child: const Icon(
                        Icons.category_outlined,
                        color: Colors.deepPurple,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  items: [
                    ...predefinedCollections.keys
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(
                                type,
                                style: GoogleFonts.poppins(),
                              ),
                            )),
                    DropdownMenuItem(
                      value: "Diğer",
                      child: Text(
                        "Diğer",
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                  onChanged: _onCollectionTypeChanged,
                  validator: (value) =>
                      value == null ? "Please select a collection type" : null,
                ),
              ),

              if (_selectedCollection == "Diğer") ...[
                const SizedBox(height: 24),
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
                  child: TextFormField(
                    controller: _customCollectionController,
                    decoration: InputDecoration(
                      labelText: "Collection Name",
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
                        child: const Icon(
                          Icons.edit_outlined,
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
                      if (_selectedCollection == "Diğer" &&
                          (value == null || value.isEmpty)) {
                        return "Please enter a collection name";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomButton(
        isLoading: _isLoading,
        onPressed: () => _saveCollection(context),
        buttonText: "Create Collection",
        icon: Icons.save_outlined,
      ),
    );
  }
}
