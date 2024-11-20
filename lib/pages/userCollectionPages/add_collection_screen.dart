import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/predefined_collections.dart';
import 'package:flutter/material.dart';

class AddCollectionScreen extends StatefulWidget {
  final String userId;

  const AddCollectionScreen({Key? key, required this.userId}) : super(key: key);

  @override
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

  Widget _buildCustomFieldList() {
    if (_customFields.isEmpty) {
      return Text('Bu koleksiyon için özel alanlar tanımlı değil.');
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _customFields.length,
      itemBuilder: (context, index) {
        final field = _customFields[index];
        return ListTile(
          title: Text(field['name']!),
          subtitle: Text('Tür: ${field['type']}'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Koleksiyon Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Koleksiyon Türü'),
                value: _selectedCollection,
                items: [
                  ...predefinedCollections.keys
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
                ],
                onChanged: _onCollectionTypeChanged,
                validator: (value) =>
                    value == null ? 'Lütfen bir koleksiyon seçin.' : null,
              ),
              if (_selectedCollection == 'Diğer')
                TextFormField(
                  controller: _customCollectionController,
                  decoration: InputDecoration(labelText: 'Koleksiyon İsmi'),
                  validator: (value) {
                    if (_selectedCollection == 'Diğer' &&
                        (value == null || value.isEmpty)) {
                      return 'Lütfen bir koleksiyon ismi girin.';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 16),
              Text(
                'Bu koleksiyon için özel alanlar:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildCustomFieldList(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _saveCollection(context),
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
