import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger_service.dart';

/// خدمة المصادقة باستخدام OTP
/// توفر وظائف لتسجيل الدخول باستخدام رمز لمرة واحدة عبر البريد الإلكتروني
class OtpAuthService {
  // استخدام getter للحصول على مثيل Supabase
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// تسجيل الدخول باستخدام OTP عبر البريد الإلكتروني
  ///
  /// [email] البريد الإلكتروني للمستخدم
  /// [redirectTo] عنوان URL لإعادة التوجيه بعد المصادقة (اختياري)
  static Future<void> signInWithOtp({
    required String email,
    String? redirectTo,
  }) async {
    try {
      LoggerService.info(
        'بدء عملية تسجيل الدخول باستخدام OTP للبريد: $email',
        tag: 'OtpAuthService',
      );

      // استخدام عنوان إعادة التوجيه المحدد في لوحة تحكم Supabase
      final String redirectUrl =
          redirectTo ?? 'com.example.tamwuilk://home_screen';

      // إرسال رمز OTP إلى البريد الإلكتروني
      final response = await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectUrl,
      );

      LoggerService.info(
        'تم إرسال رمز OTP بنجاح إلى البريد: $email',
        tag: 'OtpAuthService',
      );

      return response;
    } catch (error) {
      LoggerService.error(
        'خطأ في إرسال رمز OTP',
        tag: 'OtpAuthService',
        exception: error.toString(),
      );
      rethrow;
    }
  }

  /// التحقق من رمز OTP المرسل إلى البريد الإلكتروني
  ///
  /// [email] البريد الإلكتروني للمستخدم
  /// [token] رمز OTP المرسل إلى البريد الإلكتروني
  static Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      LoggerService.info(
        'التحقق من رمز OTP للبريد: $email',
        tag: 'OtpAuthService',
      );

      // التحقق من رمز OTP
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.magiclink,
      );

      LoggerService.info(
        'تم التحقق من رمز OTP بنجاح للبريد: $email',
        tag: 'OtpAuthService',
      );

      return response;
    } catch (error) {
      LoggerService.error(
        'خطأ في التحقق من رمز OTP',
        tag: 'OtpAuthService',
        exception: error.toString(),
      );
      rethrow;
    }
  }

  /// إعادة إرسال رمز OTP إلى البريد الإلكتروني
  ///
  /// [email] البريد الإلكتروني للمستخدم
  /// [redirectTo] عنوان URL لإعادة التوجيه بعد المصادقة (اختياري)
  static Future<void> resendOtp({
    required String email,
    String? redirectTo,
  }) async {
    try {
      LoggerService.info(
        'إعادة إرسال رمز OTP للبريد: $email',
        tag: 'OtpAuthService',
      );

      // استخدام عنوان إعادة التوجيه المحدد في AndroidManifest.xml
      final String redirectUrl =
          redirectTo ?? 'com.example.tamwuilk://home_screen';

      // إعادة إرسال رمز OTP
      await _supabase.auth.resend(
        type: OtpType.magiclink,
        email: email,
        emailRedirectTo: redirectUrl,
      );

      LoggerService.info(
        'تم إعادة إرسال رمز OTP بنجاح إلى البريد: $email',
        tag: 'OtpAuthService',
      );
    } catch (error) {
      LoggerService.error(
        'خطأ في إعادة إرسال رمز OTP',
        tag: 'OtpAuthService',
        exception: error.toString(),
      );
      rethrow;
    }
  }
}
