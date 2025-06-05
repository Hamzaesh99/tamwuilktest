import 'package:flutter/material.dart';

// نموذج بيانات للإشعار
class NotificationModel {
  final String message;
  final String user; // اسم المستخدم الذي قام بالإجراء
  final String type; // نوع الإشعار (مثل 'like', 'comment', 'follow')
  final DateTime timestamp; // وقت حدوث الإشعار
  bool isRead;

  NotificationModel({
    required this.message,
    required this.user,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  // قائمة إشعارات وهمية
  final List<NotificationModel> _notifications = [
    NotificationModel(
      message: 'أعجب منشورك الأخير.',
      user: 'علي',
      type: 'like',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    NotificationModel(
      message: 'ترك تعليقًا على منشورك.',
      user: 'فاطمة',
      type: 'comment',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: true,
    ),
    NotificationModel(
      message: 'بدأ بمتابعتك.',
      user: 'أحمد',
      type: 'follow',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      message: 'أعجب بعدة من منشوراتك.',
      user: 'سارة',
      type: 'like_multiple',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NotificationModel(
      message: 'تمت الإشارة إليك في تعليق.',
      user: 'خالد',
      type: 'mention',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // لون خلفية أبيض
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _notifications.isEmpty
            ? const Center(
                child: Text('لا توجد إشعارات جديدة'),
              )
            : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return NotificationItem(
                    notification: _notifications[index],
                    onTap: () {
                      setState(() {
                        _notifications[index].isRead = true;
                      });
                    },
                  );
                },
              ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({super.key, required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine read/unread icon

    // Format timestamp (simple example)
    String timeAgo = _getTimeAgo(notification.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0, // Slightly less elevation for a flatter look
      shadowColor: Color.fromRGBO(0, 0, 0, 0.1), // Lighter shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Slightly less rounded corners
      ),
      color: notification.isRead ? Colors.white : Colors.blue[50], // White for read, light blue for unread
      child: InkWell(
        onTap: () {
          onTap(); // Mark as read
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('تفاصيل الإشعار'),
                content: Text(notification.message),
                actions: <Widget>[
                  TextButton(
                    child: Text('إغلاق'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjust padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
            children: [
              // Placeholder for Profile Picture
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.grey[600]),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: notification.user,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' ${notification.message} '), // Add space around message
                          TextSpan(
                            text: timeAgo,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                          ),
                        ],
                      ),
                    ),
                    // You can add more details here based on notification type
                    // For example, a small image preview for a photo like
                    // if (notification.type == 'like' && notification.imageUrl != null)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 8.0),
                    //     child: Image.network(notification.imageUrl, height: 50, width: 50, fit: BoxFit.cover),
                    //   ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              // Read/Unread Icon on the right
              // Display graphic based on notification type
              _buildNotificationGraphic(notification.type),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build graphic based on notification type
  Widget _buildNotificationGraphic(String type) {
    switch (type) {
      case 'like':
        return Icon(Icons.favorite, color: Colors.red[400], size: 30); // Like icon
      case 'comment':
        return Icon(Icons.comment, color: Colors.blue[400], size: 30); // Comment icon
      case 'follow':
        return Icon(Icons.person_add, color: Colors.green[400], size: 30); // Follow icon
      case 'like_multiple':
        return Icon(Icons.favorite, color: Colors.red[400], size: 30); // Same as like for now
      case 'mention':
        return Icon(Icons.alternate_email, color: Colors.blue[400], size: 30); // Mention icon
      default:
        // Default icon
        return Icon(Icons.notifications, color: Colors.grey, size: 30);
    }
  }

  // Helper function to format time ago (simple implementation)
  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} دقيقة مضت';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ساعة مضت';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} يوم مضى';
    } else {
      return '${(difference.inDays / 7).floor()} أسبوع مضى';
    }
  }
}