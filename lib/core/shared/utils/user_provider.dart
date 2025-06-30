import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/app_user.dart'; // Import the AppUser model
import '../../services/logger_service.dart';

/// فئة مزود المستخدم
class UserProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool isLoadingUser = true;
  final bool _isCreatingProfile = false;

  AppUser? get currentUser => _currentUser;
  bool get isCreatingProfile => _isCreatingProfile;

  Future<void> setUser(User? authUser) async {
    isLoadingUser = true;
    notifyListeners();
    if (authUser == null) {
      _currentUser = null;
      isLoadingUser = false;
      notifyListeners();
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', authUser.id)
          .single();

      _currentUser = AppUser.fromMap(response);
      LoggerService.info(
        'تم جلب ملف تعريف المستخدم بنجاح: ${authUser.id}',
        tag: 'UserProvider',
      );
    } catch (error) {
      LoggerService.error(
        'خطأ في جلب ملف تعريف المستخدم: $error. ربما تأخر الـ Trigger.',
        tag: 'UserProvider',
      );
      _currentUser = AppUser(
        id: authUser.id,
        email: authUser.email ?? '',
        userRole: authUser.userMetadata?['user_role'] ?? 'investor',
      );
    } finally {
      isLoadingUser = false;
      notifyListeners();
    }
  }

  // Method to explicitly set an AppUser, useful for guest users or testing
  void setAppUser(AppUser? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Clear user data on sign out
  void clearUser() {
    _currentUser = null;
    isLoadingUser = false;
    notifyListeners();
  }
}
