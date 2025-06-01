import "dart:io";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:collectionapp/models/group_model.dart";
import "package:collectionapp/models/post_model.dart";

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

  Future<bool> isUserAdmin(String groupId, String userId) async {
    final groupDoc = await _firestore.collection("groups").doc(groupId).get();
    if (!groupDoc.exists) return false;

    final adminIds = List<String>.from(groupDoc.data()?["adminIds"] ?? []);
    return adminIds.contains(userId);
  }

  Future<void> deletePost(String postId) async {
    try {
      final postDoc = await _firestore.collection("posts").doc(postId).get();

      if (!postDoc.exists) {
        throw Exception("Post bulunamadı.");
      }

      final data = postDoc.data();
      final imageUrl = data?["imageUrl"] as String?;

      // Gönderide bir fotoğraf varsa Storage'tan sil
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await storageRef.delete();
        } catch (e) {
          debugPrint("Post fotoğrafını silerken hata oluştu: $e");
        }
      }

      // Son olarak Firestore dokümanını sil
      await _firestore.collection("posts").doc(postId).delete();
    } catch (e) {
      debugPrint("Post silinirken hata oluştu: $e");
      rethrow;
    }
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _firestore.collection("posts").doc(postId).update(data);
  }

  Future<void> deleteCommentFromPost(String postId, Comment comment) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);

      await postRef.update({
        'comments': FieldValue.arrayRemove([comment.toMap()])
      });
    } catch (e) {
      throw Exception('Failed to remove comment: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      final groupDoc = await _firestore.collection("groups").doc(groupId).get();

      if (!groupDoc.exists) {
        throw Exception("Grup bulunamadı.");
      }

      final data = groupDoc.data();
      final coverImageUrl = data?["coverImageUrl"] as String?;

      // Kapak resmi varsa Storage'tan sil
      if (coverImageUrl != null && coverImageUrl.isNotEmpty) {
        try {
          final storageRef = FirebaseStorage.instance.refFromURL(coverImageUrl);
          await storageRef.delete();
        } catch (e) {
          debugPrint("Grup kapak fotoğrafını silerken hata oluştu: $e");
        }
      }

      // İsteğe bağlı: Bu grup altındaki post’ları da silmek isterseniz
      // burada önce ilgili post’ları çekip tek tek deletePost ile silebilirsiniz.
      // Örnek (dikkat: büyük koleksiyonlarda transaction/fonksiyon gerektirebilir):
      //
      // final postsQuery = await _firestore
      //     .collection("posts")
      //     .where("groupId", isEqualTo: groupId)
      //     .get();
      // for (var doc in postsQuery.docs) {
      //   await deletePost(doc.id);
      // }

      // Son olarak grup dokümanını sil
      await _firestore.collection("groups").doc(groupId).delete();
    } catch (e) {
      debugPrint("Grup silinirken hata oluştu: $e");
      rethrow;
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
    await FirebaseFirestore.instance
        .collection("joinRequests")
        .doc(groupId)
        .collection("requests") // Kullanıcı bazlı koleksiyon
        .doc(userId)
        .set({
      "userId": userId,
      "status": "pending",
      "requestedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<bool> getJoinRequest(String groupId, String userId) async {
    final requestDoc = await FirebaseFirestore.instance
        .collection("joinRequests")
        .doc(groupId)
        .collection("requests") // Kullanıcı bazlı alt koleksiyon
        .doc(userId)
        .get();

    return requestDoc.exists;
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
