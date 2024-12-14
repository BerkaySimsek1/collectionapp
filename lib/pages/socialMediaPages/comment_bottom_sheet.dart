import 'package:collectionapp/firebase_methods/firestore_methods/SM_firestore_methods.dart';
import 'package:collectionapp/models/PostModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentBottomSheet extends StatefulWidget {
  final Post post;
  final GroupDetailService groupDetailService;

  const CommentBottomSheet(
      {Key? key, required this.post, required this.groupDetailService})
      : super(key: key);

  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

  void _submitComment() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _commentController.text.trim().isEmpty) return;

    final comment = Comment(
      id: DateTime.now().toString(), // Consider using a unique ID generator
      userId: currentUser.uid,
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
      username: currentUser.displayName ?? 'Anonymous',
      userProfilePic: currentUser.photoURL ?? '',
      groupId: widget.post.groupId, // Add this field to pass group context
    );

    try {
      await widget.groupDetailService.addCommentToPost(widget.post.id, comment);
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }
}
