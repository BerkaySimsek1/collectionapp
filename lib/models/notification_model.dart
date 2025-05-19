import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String auctionId;
  final String title;
  final String message;
  final bool isRead;
  final int createdAt;
  final String type;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.auctionId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'auctionId': auctionId,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt,
      'type': type,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    try {
      return NotificationModel(
        id: docId,
        userId: map['userId'] as String? ?? '',
        auctionId: map['auctionId'] as String? ?? '',
        title: map['title'] as String? ?? '',
        message: map['message'] as String? ?? '',
        isRead: map['isRead'] as bool? ?? false, // Boolean dönüşümünü düzelt
        createdAt: (map['createdAt'] as int?) ?? 0,
        type: map['type'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('Error parsing notification: $map');
      rethrow;
    }
  }
}
