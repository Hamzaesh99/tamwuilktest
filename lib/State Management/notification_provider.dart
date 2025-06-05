import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final String? relatedProjectId; // Added for filtering

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedProjectId,
  });

  // Factory constructor to create a Notification from a Supabase row
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'].toString(), // Assuming 'id' is the unique identifier
      title: map['title'] ?? 'No Title',
      message: map['message'] ?? 'No Message',
      timestamp: DateTime.parse(map['created_at']), // Assuming 'created_at' is the timestamp
      isRead: map['is_read'] ?? false,
      relatedProjectId: map['related_project_id']?.toString(), // Assuming this field exists
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client; // Add Supabase client

  int _unreadCount = 0;
  List<Notification> _notifications = []; // Store notifications in the provider

  int get unreadCount => _unreadCount;
  List<Notification> get notifications => _notifications;

  // Method to fetch notifications with pagination
  Future<List<Notification>> fetchNotifications({int limit = 20, int offset = 0}) async {
    try {
      final PostgrestList response = await _supabase
          .from('notifications') // Assuming your table name is 'notifications'
          .select()
          .order('created_at', ascending: false) // Order by timestamp
          .range(offset, offset + limit - 1); // Implement pagination

      final List<dynamic> data = response as List;
      final fetchedNotifications = data.map((item) => Notification.fromMap(item)).toList();

      // Append fetched notifications to the existing list (or replace if starting from offset 0)
      if (offset == 0) {
        _notifications = fetchedNotifications;
      } else {
        _notifications.addAll(fetchedNotifications);
      }

      notifyListeners(); // Notify listeners about the updated list
      return fetchedNotifications;

    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      // Handle error appropriately
      return []; // Return empty list on error
    }
  }

  void incrementUnreadCount() {
    _unreadCount++;
    notifyListeners(); // إشعار الواجهات بالتحديث
  }

  void markAllAsRead() {
    _unreadCount = 0;
    // You might also want to update the 'is_read' status in the database
    notifyListeners();
  }

  // Method to mark a single notification as read
  void markAsRead(String notificationId) {
    final notificationIndex = _notifications.indexWhere((n) => n.id == notificationId);
    if (notificationIndex != -1 && !_notifications[notificationIndex].isRead) {
      _notifications[notificationIndex].isRead = true;
      // Optionally, update in the database
      // _supabase.from('notifications').update({'is_read': true}).eq('id', notificationId);
      notifyListeners();
    }
  }

   // Method to remove a single notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    // Optionally, delete from the database
    // _supabase.from('notifications').delete().eq('id', notificationId);
    notifyListeners();
  }

  // Method to clear all notifications (already exists, but ensure it clears the list)
  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0; // Assuming clearing notifications also clears unread count
    // Optionally, delete all from the database
    // _supabase.from('notifications').delete().neq('id', null);
    notifyListeners();
  }
}
