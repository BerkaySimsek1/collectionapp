import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFieldScreen extends StatefulWidget {
  final String userId;
  final String collectionName;
  final String itemId;

  const AddFieldScreen({
    Key? key,
    required this.userId,
    required this.collectionName,
    required this.itemId,
  }) : super(key: key);

  @override
  _AddFieldScreenState createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fieldNameController = TextEditingController();
  String _selectedFieldType = 'TextField';

  final List<String> _fieldTypes = ['TextField', 'DatePicker', 'NumberField'];

  Future<void> _saveField() async {
    if (_formKey.currentState!.validate()) {
      final fieldName = _fieldNameController.text.trim();

      // Firestore'da bu item'e yeni bir field ekle
      await FirebaseFirestore.instance
          .collection('userCollections')
          .doc(widget.userId)
          .collection(widget.collectionName)
          .doc(widget.itemId)
          .update({
        'customFields': FieldValue.arrayUnion([
          {'name': fieldName, 'type': _selectedFieldType}
        ])
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yeni Alan Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fieldNameController,
                decoration: InputDecoration(labelText: 'Alan Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alan adı gerekli.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFieldType,
                items: _fieldTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFieldType = value;
                    });
                  }
                },
                decoration: InputDecoration(labelText: 'Alan Türü'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveField,
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
