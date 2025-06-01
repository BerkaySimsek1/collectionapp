import "package:cloud_firestore/cloud_firestore.dart";

class Post {
  final String id;
  final String groupId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final List<String> likes;
  final List<Comment> comments;
  final String? imageUrl;
  final String username;
  final String userProfilePic;

  Post({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.likes = const [],
    this.comments = const [],
    this.imageUrl,
    required this.username,
    required this.userProfilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "groupId": groupId,
      "userId": userId,
      "content": content,
      "createdAt": createdAt,
      "likes": likes,
      "comments": comments.map((comment) => comment.toMap()).toList(),
      "imageUrl": imageUrl,
      "username": username,
      "userProfilePic": userProfilePic,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map["id"],
      groupId: map["groupId"],
      userId: map["userId"],
      content: map["content"],
      createdAt: (map["createdAt"] as Timestamp).toDate(),
      likes: List<String>.from(map["likes"] ?? []),
      comments: map["comments"] != null
          ? (map["comments"] as List)
              .map((commentMap) => Comment.fromMap(commentMap))
              .toList()
          : [],
      imageUrl: map["imageUrl"],
      username: map["username"],
      userProfilePic: map["userProfilePic"],
    );
  }
}

class Comment {
  final String id;
  final String groupId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String username;
  final String userProfilePic;

  Comment({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.username,
    required this.userProfilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "groupId": groupId,
      "userId": userId,
      "content": content,
      "createdAt": createdAt,
      "username": username,
      "userProfilePic": userProfilePic,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map["id"],
      groupId: map["groupId"],
      userId: map["userId"],
      content: map["content"],
      createdAt: (map["createdAt"] as Timestamp).toDate(),
      username: map["username"],
      userProfilePic: map["userProfilePic"],
    );
  }
}
