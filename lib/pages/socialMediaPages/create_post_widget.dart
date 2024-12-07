import 'dart:io';

import 'package:collectionapp/firebase_methods/firestore_methods/SM_firestore_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostWidget extends StatefulWidget {
  final String groupId;

  const CreatePostWidget({Key? key, required this.groupId}) : super(key: key);

  @override
  _CreatePostWidgetState createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final _postService = GroupDetailService();
  final _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _postController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _createPost() async {
    if (_postController.text.isNotEmpty || _imageFile != null) {
      try {
        await _postService.createPost(
          groupId: widget.groupId,
          userId: _currentUser!.uid,
          content: _postController.text,
          imageFile: _imageFile,
          username: _currentUser!.displayName ?? 'Kullanıcı',
          userProfilePic: _currentUser!.photoURL ?? '',
        );

        // Gönderi sonrası temizlik
        _postController.clear();
        setState(() {
          _imageFile = null;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gönderi paylaşıldı')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gönderi paylaşılamadı: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _postController,
            decoration: InputDecoration(
              hintText: 'Bir şeyler paylaş...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 8),

          // Seçilen Fotoğraf Önizlemesi
          if (_imageFile != null)
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(
                  _imageFile!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                    });
                  },
                ),
              ],
            ),

          Row(
            children: [
              IconButton(
                icon: Icon(Icons.photo_library),
                onPressed: _pickImage,
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _createPost,
                child: Text('Paylaş'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
