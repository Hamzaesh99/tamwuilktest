import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/app_user.dart'; // Import the AppUser model

import 'dart:developer';

/// فئة مزود المستخدم
class UserProvider extends ChangeNotifier {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<void> setUser(User? authUser) async {
    if (authUser == null) {
      _currentUser = null;
    } else {
      // Fetch user profile from Supabase 'profiles' table
      try {
        final response =
            await Supabase.instance.client
                .from('profiles')
                .select()
                .eq('id', authUser.id)
                .single();

        _currentUser = AppUser.fromMap(response);
      } catch (e) {
        // Handle error, e.g., user profile not found or network issue
        // For now, we'll create a basic AppUser with email and id, userRole will be null
        _currentUser = AppUser(
          id: authUser.id,
          email: authUser.email ?? '',
          userRole: null,
        );
        log('Error fetching user profile: $e');
      }
    }
    notifyListeners();
  }

  // Method to explicitly set an AppUser, useful for guest users or testing
  void setAppUser(AppUser? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Clear user data on sign out
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
