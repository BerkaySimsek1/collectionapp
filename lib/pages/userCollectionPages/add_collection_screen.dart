import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/design_elements.dart';
import 'package:collectionapp/models/predefined_collections.dart';
import 'package:flutter/material.dart';

class AddCollectionScreen extends StatefulWidget {
  final String userId;

  const AddCollectionScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _AddCollectionScreenState createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends State<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCollection;
  final TextEditingController _customCollectionController =
      TextEditingController();

  List<Map<String, String>> _customFields = [];

  void _onCollectionTypeChanged(String? value) {
    setState(() {
      _selectedCollection = value;

      // Önceden tanımlı koleksiyon seçildiyse özel alanları otomatik ekle
      if (predefinedCollections.containsKey(value)) {
        _customFields = predefinedCollections[value]!;
      } else {
        _customFields = [];
      }
    });
  }

  Future<void> _saveCollection(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final collectionName = _selectedCollection == 'Diğer'
          ? _customCollectionController.text.trim()
          : _selectedCollection;

      // Firestore’a koleksiyon kaydet
      await FirebaseFirestore.instance
          .collection('userCollections')
          .doc(widget.userId)
          .collection('collections')
          .add({
        'name': collectionName,
        'customFields': _customFields,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProjectAppbar(
        titletext: "Add New Collection",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Koleksiyon Türü'),
                value: _selectedCollection,
                items: [
                  ...predefinedCollections.keys.map((type) =>
                      DropdownMenuItem(value: type, child: Text(type))),
                  const DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
                ],
                onChanged: _onCollectionTypeChanged,
                validator: (value) =>
                    value == null ? 'Lütfen bir koleksiyon seçin.' : null,
              ),
              if (_selectedCollection == 'Diğer')
                TextFormField(
                  controller: _customCollectionController,
                  decoration:
                      const InputDecoration(labelText: 'Koleksiyon İsmi'),
                  validator: (value) {
                    if (_selectedCollection == 'Diğer' &&
                        (value == null || value.isEmpty)) {
                      return 'Lütfen bir koleksiyon ismi girin.';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _saveCollection(context),
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
