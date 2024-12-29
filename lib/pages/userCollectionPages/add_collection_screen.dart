import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:collectionapp/design_elements.dart";
import "package:collectionapp/models/predefined_collections.dart";

class AddCollectionScreen extends StatefulWidget {
  final String userId;

  const AddCollectionScreen({super.key, required this.userId});

  @override
  _AddCollectionScreenState createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends State<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCollection;
  final TextEditingController _customCollectionController =
      TextEditingController();

  void _onCollectionTypeChanged(String? value) {
    setState(() {
      _selectedCollection = value;
      // Bu kısımda _customFields devre dışı bırakıldığı için hiçbir şey yapmıyoruz
      // if (predefinedCollections.containsKey(value)) {
      //   _customFields = predefinedCollections[value]!;
      // } else {
      //   _customFields = [];
      // }
    });
  }

  Future<void> _saveCollection(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
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

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const ProjectAppbar(
        titleText: "Add New Collection",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(8),
                decoration: InputDecoration(
                  labelText: "Collection Type",
                  labelStyle: ProjectTextStyles.subtitleTextStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedCollection,
                items: [
                  ...predefinedCollections.keys.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: ProjectTextStyles.appBarTextStyle
                            .copyWith(fontSize: 16),
                      ))),
                  DropdownMenuItem(
                      value: "Diğer",
                      child: Text(
                        "Diğer",
                        style: ProjectTextStyles.appBarTextStyle
                            .copyWith(fontSize: 16),
                      )),
                ],
                onChanged: _onCollectionTypeChanged,
                validator: (value) =>
                    value == null ? "Please select collection type" : null,
              ),
              if (_selectedCollection == "Diğer") ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customCollectionController,
                  decoration: InputDecoration(
                    labelText: "Collection Name",
                    labelStyle: ProjectTextStyles.subtitleTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (_selectedCollection == "Diğer" &&
                        (value == null || value.isEmpty)) {
                      return "Please enter collection name";
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _saveCollection(context),
                style: ProjectDecorations.elevatedButtonStyle,
                child: const Text(
                  "Save",
                  style: ProjectTextStyles.buttonTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
