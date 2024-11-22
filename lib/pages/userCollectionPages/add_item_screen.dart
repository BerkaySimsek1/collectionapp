import 'package:collectionapp/models/predefined_collections.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItemScreen extends StatefulWidget {
  final String userId;
  final String collectionName;

  const AddItemScreen({
    super.key,
    required this.userId,
    required this.collectionName,
  });

  @override
  // ignore: library_private_types_in_public_api
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

  @override
  void initState() {
    super.initState();

    // Koleksiyon türüne göre alanları yükle
    if (predefinedCollections.containsKey(widget.collectionName)) {
      _predefinedFields = predefinedCollections[widget.collectionName]!;
      for (var field in _predefinedFields) {
        _predefinedFieldValues[field['name']!] = null;
      }
    }
  }

  void _addCustomField() {
    showDialog(
      context: context,
      builder: (context) {
        String fieldName = '';
        String fieldType = 'TextField';
        return AlertDialog(
          title: const Text('Yeni Alan Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Alan Adı'),
                onChanged: (value) {
                  fieldName = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: fieldType,
                items: ['TextField', 'DatePicker', 'NumberField']
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    fieldType = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Alan Türü'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (fieldName.isNotEmpty) {
                  setState(() {
                    _customFields.add({'name': fieldName, 'type': fieldType});
                    _customFieldValues[fieldName] = null;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveItem(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final itemName = _nameController.text.trim();
      final rarity = _rarityController.text.trim();

      final Map<String, dynamic> itemData = {
        'name': itemName,
        'rarity': rarity,
        'customFields': _customFields,
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
          .collection('userCollections')
          .doc(widget.userId)
          .collection(widget.collectionName)
          .add(itemData);

      // ignore: use_build_context_synchronously
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
        final fieldName = field['name']!;
        final fieldType = field['type']!;

        if (fieldType == 'TextField') {
          return TextFormField(
            decoration: InputDecoration(labelText: fieldName),
            onChanged: (value) {
              _predefinedFieldValues[fieldName] = value;
            },
          );
        } else if (fieldType == 'NumberField') {
          return TextFormField(
            decoration: InputDecoration(labelText: fieldName),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _predefinedFieldValues[fieldName] = int.tryParse(value) ?? 0;
            },
          );
        } else if (fieldType == 'DatePicker') {
          return ListTile(
            title: Text(fieldName),
            subtitle: Text(
              _predefinedFieldValues[fieldName]?.toString() ??
                  'Tarih seçilmedi',
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
        } else if (fieldType == 'Dropdown') {
          final options = field['options']!.split(',');
          return DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: fieldName),
            items: options
                .map((option) =>
                    DropdownMenuItem(value: option, child: Text(option)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _predefinedFieldValues[fieldName] = value;
              });
            },
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
        final fieldName = field['name'];
        final fieldType = field['type'];

        if (fieldType == 'TextField') {
          return TextFormField(
            decoration: InputDecoration(labelText: fieldName),
            onChanged: (value) {
              _customFieldValues[fieldName] = value;
            },
          );
        } else if (fieldType == 'NumberField') {
          return TextFormField(
            decoration: InputDecoration(labelText: fieldName),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _customFieldValues[fieldName] = int.tryParse(value) ?? 0;
            },
          );
        } else if (fieldType == 'DatePicker') {
          return ListTile(
            title: Text(fieldName),
            subtitle: Text(
              _customFieldValues[fieldName]?.toString() ?? 'Tarih seçilmedi',
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
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Ürün Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ürün İsmi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir isim girin.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rarityController,
                decoration: const InputDecoration(labelText: 'Nadirlik'),
              ),
              const SizedBox(height: 16),
              _buildPredefinedFieldInputs(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addCustomField,
                child: const Text('Özel Alan Ekle'),
              ),
              const SizedBox(height: 16),
              _buildCustomFieldInputs(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _saveItem(context),
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
