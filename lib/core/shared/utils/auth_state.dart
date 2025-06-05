import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:tamwuilktest/core/services/logger_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _redirectUrl = 'com.example.tamwuilk://home_screen';

  /// تسجيل الدخول العام عبر OAuth للمزودين المختلفين
  Future<void> signInWithOAuthProvider(OAuthProvider provider) async {
    try {
      LoggerService.info(
        'بدء عملية تسجيل الدخول عبر ${provider.name}...',
        tag: 'AuthService',
      );

      final response = await _supabase.auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb ? null : _redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
        scopes: _getScopesForProvider(provider),
      );

      if (!response) {
        LoggerService.error(
          'فشل في بدء عملية تسجيل الدخول عبر ${provider.name}',
          tag: 'AuthService',
        );
        throw Exception('فشل بدء العملية');
      }

      LoggerService.info(
        'تم بدء العملية بنجاح. انتظار إكمال المستخدم...',
        tag: 'AuthService',
      );
    } on AuthException catch (e) {
      LoggerService.error(
        'خطأ في المصادقة: ${e.message}',
        tag: 'AuthService',
        exception: e,
      );
      rethrow;
    } catch (e) {
      LoggerService.error(
        'خطأ غير متوقع: ${e.toString()}',
        tag: 'AuthService',
        exception: e,
      );
      throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  /// تحديد الصلاحيات حسب المزود
  String _getScopesForProvider(OAuthProvider provider) {
    switch (provider) {
      case OAuthProvider.facebook:
        return 'email,public_profile';
      case OAuthProvider.google:
        return 'email,profile';
      default:
        return 'email';
    }
  }

  /// تسجيل الدخول عبر فيسبوك (مغلف لـ OAuth العام)
  Future<void> signInWithFacebook() =>
      signInWithOAuthProvider(OAuthProvider.facebook);

  /// تسجيل الدخول عبر جوجل (مغلف لـ OAuth العام)
  Future<void> signInWithGoogle() =>
      signInWithOAuthProvider(OAuthProvider.google);

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      LoggerService.info('تم تسجيل الخروج بنجاح', tag: 'AuthService');
    } on AuthException catch (e) {
      LoggerService.error(
        'خطأ في تسجيل الخروج: ${e.message}',
        tag: 'AuthService',
        exception: e,
      );
      rethrow;
    }
  }

  /// الحصول على حالة المستخدم الحالي
  User? get currentUser => _supabase.auth.currentUser;

  /// دفق مراقبة حالة المصادقة
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
