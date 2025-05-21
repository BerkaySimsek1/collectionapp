import 'package:collectionapp/common_ui_methods.dart';
import 'package:flutter/material.dart';
import 'package:collectionapp/models/notification_model.dart';
import 'package:collectionapp/firebase_methods/notification_methods.dart';
import 'package:collectionapp/pages/auctionPages/auction_detail.dart';
import 'package:collectionapp/models/AuctionModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationMethods _notificationMethods = NotificationMethods();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
        leading: const ProjectIconButton(),
        actions: [
          TextButton.icon(
            onPressed: () => _notificationMethods.markAllAsRead(userId),
            icon: const Icon(Icons.done_all, color: Colors.deepPurple),
            label: Text(
              'Mark all as read',
              style: GoogleFonts.poppins(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationMethods.getNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showWarningDialog(
          context,
          () async {
            await _notificationMethods.deleteNotification(notification.id);
            if (mounted) {
              projectSnackBar(
                  context, '${notification.title} dismissed', "green");
            }
          },
          title: "Delete Notification",
          message: "Are you sure you want to delete this notification?",
          buttonText: "Delete",
          icon: Icons.delete_outline,
        );
      },
      child: GestureDetector(
        onTap: () async {
          // Önce bildirimi okundu olarak işaretle
          if (!notification.isRead) {
            await _notificationMethods.markAsRead(notification.id);
          }

          // Sonra auction detayına git
          if (notification.auctionId.isNotEmpty && context.mounted) {
            final auction = await AuctionModel.fromId(notification.auctionId);
            if (auction != null && context.mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuctionDetail(auction: auction),
                ),
              );
            }
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                notification.isRead ? Colors.white : Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
              ),
            ),
            title: Text(
              notification.title,
              style: GoogleFonts.poppins(
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(
                    DateTime.fromMillisecondsSinceEpoch(notification.createdAt),
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bildirim kartının rengini de tipine göre özelleştirelim
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'bid':
        return Colors.deepPurple;
      case 'auction_won':
        return Colors
            .green; // Değiştirildi: Kazanılan açık artırma yeşil renkte
      case 'auction_end':
        return Colors.red; // Kaybedilen açık artırma kırmızı renkte
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'bid':
        return Icons.gavel;
      case 'auction_won':
        return Icons.emoji_events; // Kupa ikonu kazanan için
      case 'auction_end':
        return Icons.timer_off; // Saat ikonu kaybeden için
      default:
        return Icons.notifications;
    }
  }
}
