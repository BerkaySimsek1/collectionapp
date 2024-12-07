import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final DateTime createdAt;
  final String category;
  final List<String> members;
  final List<String> adminIds;
  final String? coverImageUrl;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.createdAt,
    required this.category,
    this.members = const [],
    this.adminIds = const [],
    this.coverImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'createdAt': createdAt,
      'category': category,
      'members': members,
      'adminIds': adminIds,
      'coverImageUrl': coverImageUrl,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      creatorId: map['creatorId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      category: map['category'],
      members: List<String>.from(map['members'] ?? []),
      adminIds: List<String>.from(map['adminIds'] ?? []),
      coverImageUrl: map['coverImageUrl'],
    );
  }
}
