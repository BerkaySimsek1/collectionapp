import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collectionapp/models/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> getNotifications(String userId) {
    try {
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true) // __name__ kaldırıldı
          .snapshots()
          .map((querySnapshot) {
        final notifications = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return NotificationModel.fromMap(data, doc.id);
        }).toList();
        debugPrint('Parsed ${notifications.length} notifications.');
        return notifications;
      });
    } catch (e) {
      debugPrint('Error in getNotifications: $e');
      return Stream.value([]);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> createNotification({
    required String userId,
    required String auctionId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'auctionId': auctionId,
        'title': title,
        'message': message,
        'isRead': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'type': type,
      });
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }
}
