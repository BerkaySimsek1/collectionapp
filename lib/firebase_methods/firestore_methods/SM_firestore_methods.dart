import "dart:io";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:collectionapp/models/GroupModel.dart";
import "package:collectionapp/models/PostModel.dart";

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Yeni Grup Oluşturma
  Future<String> createGroup({
    required String name,
    required String description,
    required String creatorId,
    required String category,
    File? coverImage,
  }) async {
    try {
      // Benzersiz ID oluştur
      final groupRef = _firestore.collection("groups").doc();

      // Kapak resmi yükleme (opsiyonel)
      String? coverImageUrl;
      if (coverImage != null) {
        final storageRef = _storage.ref().child("group_covers/${groupRef.id}");
        await storageRef.putFile(coverImage);
        coverImageUrl = await storageRef.getDownloadURL();
      }

      // Grup verilerini hazırla
      final group = Group(
        id: groupRef.id,
        name: name,
        description: description,
        creatorId: creatorId,
        createdAt: DateTime.now(),
        category: category,
        members: [creatorId],
        adminIds: [creatorId],
        coverImageUrl: coverImageUrl,
      );

      // Firestore"a kaydet
      await groupRef.set(group.toMap());

      return groupRef.id;
    } catch (e) {
      debugPrint("Failed to create groups: $e");
      rethrow;
    }
  }

  // Tüm Grupları Listeleme
  Stream<List<Group>> getGroups() {
    return _firestore.collection("groups").snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList());
  }

  // Belirli Kategorideki Grupları Listeleme
  Stream<List<Group>> getGroupsByCategory(String category) {
    return _firestore
        .collection("groups")
        .where("category", isEqualTo: category)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList());
  }

  // Kullanıcının Üye Olduğu Grupları Listeleme
  Stream<List<Group>> getUserGroups(String userId) {
    return _firestore
        .collection("groups")
        .where("members", arrayContains: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList());
  }
}

class GroupDetailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCommentToPost(String postId, Comment comment) async {
    try {
      final postRef =
          FirebaseFirestore.instance.collection("posts").doc(postId);

      await postRef.update({
        "comments": FieldValue.arrayUnion([comment.toMap()])
      });
    } catch (e) {
      debugPrint("Error adding comment: $e");
      throw Exception("Failed to add comment");
    }
  }

  Stream<List<Comment>> getPostComments(String groupId, String postId) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null || data["comments"] == null) return [];

      return (data["comments"] as List)
          .map((commentMap) => Comment.fromMap(commentMap))
          .toList();
    });
  }

  // Gruba Katılma İsteği Gönderme
  Future<void> sendJoinRequest(String groupId, String userId) async {
    await _firestore.collection("group_join_requests").doc(groupId).set({
      "groupId": groupId,
      "userId": userId,
      "status": "pending",
      "requestedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getJoinRequest(
      String groupId, String userId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection("group_join_requests").doc(groupId).get();

      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        Map<String, dynamic> requestData =
            documentSnapshot.data() as Map<String, dynamic>;
        return requestData;
      } else {
        return null; // Join request not found
      }
    } catch (e) {
      debugPrint("Error retrieving join request: $e");
      return null;
    }
  }

  // Kullanıcının Gruba Üyelik Durumunu Kontrol Etme
  Future<bool> isUserMember(String groupId, String userId) async {
    final groupDoc = await _firestore.collection("groups").doc(groupId).get();
    final members = List<String>.from(groupDoc["members"] ?? []);
    return members.contains(userId);
  }

  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<void> createPost({
    required String groupId,
    required String userId,
    required String content,
    File? imageFile,
    required String username,
    required String userProfilePic,
  }) async {
    try {
      String? imageUrl;

      // Fotoğraf yükleme
      if (imageFile != null) {
        final storageRef = _storage
            .ref()
            .child("post_images/${DateTime.now().millisecondsSinceEpoch}");
        await storageRef.putFile(imageFile);
        imageUrl = await storageRef.getDownloadURL();
      }

      final postRef = _firestore.collection("posts").doc();

      final post = Post(
        id: postRef.id,
        groupId: groupId,
        userId: userId,
        content: content,
        createdAt: DateTime.now(),
        imageUrl: imageUrl,
        username: username,
        userProfilePic: userProfilePic,
      );

      await postRef.set(post.toMap());
    } catch (e) {
      debugPrint("Falied to post: $e");
      rethrow;
    }
  }

  // Grubun Gönderilerini Getirme
  Stream<List<Post>> getGroupPosts(String groupId) {
    return _firestore
        .collection("posts")
        .where("groupId", isEqualTo: groupId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList());
  }

  // Gönderiyi Beğenme/Beğenmekten Çıkma
  Future<void> toggleLike(String postId, String userId) async {
    final postRef = _firestore.collection("posts").doc(postId);

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist");
      }

      final likes = List<String>.from(postSnapshot["likes"] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      transaction.update(postRef, {"likes": likes});
    });
  }
}
