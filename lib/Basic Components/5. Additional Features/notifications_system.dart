import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier { // ✅ مورث من ChangeNotifier
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void incrementUnreadCount() {
    _unreadCount++;
    notifyListeners(); // إشعار الواجهات بالتحديث
  }
}