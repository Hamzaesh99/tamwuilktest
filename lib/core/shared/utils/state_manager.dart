import 'package:flutter/material.dart';
import 'package:tamwuilktest/core/shared/models/user_model.dart' as user_model;

/// Provider para gestionar el estado del usuario en la aplicación
class UserProvider extends ChangeNotifier {
  user_model.User? _currentUser;

  user_model.User? get currentUser => _currentUser;

  void setUser(user_model.User user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateUser(user_model.User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  /// استرجاع بيانات المستخدم من Supabase
  Future<user_model.User?>? getUserData(String userId) async {
    // هنا يمكن إضافة منطق لاسترجاع بيانات المستخدم من Supabase
    // في هذه المرحلة، نعيد المستخدم الحالي إذا كان موجودًا
    return Future.value(_currentUser);
  }

  /// جلب بيانات المستخدم من Supabase وتحديث الحالة
  Future<void> fetchUserData(String userId) async {
    try {
      // هنا يمكن إضافة منطق لجلب بيانات المستخدم من Supabase
      // مثال: استدعاء API أو قاعدة بيانات

      // في هذه المرحلة، نقوم بإنشاء مستخدم افتراضي إذا لم يكن هناك مستخدم حالي
      if (_currentUser == null) {
        _currentUser = user_model.User(
          id: userId,
          name: 'مستخدم جديد',
          email: 'user@example.com',
          createdAt: DateTime.now(),
          userRole: 'user',
        );
        notifyListeners();
      }
    } catch (e) {
      // استخدام نظام تسجيل أفضل بدلاً من print
      debugPrint('خطأ في جلب بيانات المستخدم: $e');
    }
  }

  // تحديث الحقول حسب user_model.User
  void updateUserField({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    bool? isPremium,
    List<String>? favoriteProjects,
    List<String>? investedProjects,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
    String? accountType,
    String? userRole,
  }) {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      isPremium: isPremium,
      favoriteProjects: favoriteProjects,
      investedProjects: investedProjects,
      createdAt: createdAt,
      settings: settings,
      accountType: accountType,
      userRole: userRole,
    );
    notifyListeners();
  }

  /// تحديث إعدادات المستخدم
  void updateUserSettings(Map<String, dynamic> newSettings) {
    if (_currentUser == null) return;

    final updatedSettings = Map<String, dynamic>.from(_currentUser!.settings);
    updatedSettings.addAll(newSettings);

    updateUserField(settings: updatedSettings);
  }
}

/// مدير حالة الإشعارات
class NotificationProvider extends ChangeNotifier {
  final List<Notification> _notifications = [];
  int _unreadCount = 0;

  List<Notification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void addNotification(Notification notification) {
    _notifications.add(notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount--;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      if (!notification.isRead) {
        notification = notification.copyWith(isRead: true);
      }
    }
    _unreadCount = 0;
    notifyListeners();
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    // Optionally, update unread count if the removed notification was unread
    // This would require checking the isRead status before removing, which might be complex
    // A simpler approach is to recalculate unread count after removal if needed,
    // or ensure unread count is decremented when marked as read.
    // For now, I will just remove and notify listeners.
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}

/// نموذج بيانات الإشعار
class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedProjectId;

  const Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedProjectId,
  });

  Notification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? relatedProjectId,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedProjectId: relatedProjectId ?? this.relatedProjectId,
    );
  }
}
