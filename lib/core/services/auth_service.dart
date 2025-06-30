import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'logger_service.dart';
import 'web_auth_service.dart';

/// خدمة المصادقة المسؤولة عن جميع عمليات تسجيل الدخول والخروج
/// وإدارة جلسات المستخدمين في التطبيق
class AuthService {
  // استخدام getter للحصول على مثيل Supabase
  static SupabaseClient get _supabase => Supabase.instance.client;

  // إنشاء مثيل GoogleSignIn مع معرفات العميل الصحيحة
  // نستخدم هذا المثيل في دالة signInWithGoogle
  static GoogleSignIn getGoogleSignIn() {
    return GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId:
          '131667174068-olnqvqhmcim4aqj5gs3e78kvaqvmkg93.apps.googleusercontent.com',
    );
  }

  /// تسجيل الدخول باستخدام Google
  static Future<AuthResponse> signInWithGoogle() async {
    try {
      LoggerService.info(
        'بدء عملية تسجيل الدخول باستخدام Google',
        tag: 'AuthService',
      );

      // استخدام دالة getGoogleSignIn للحصول على مثيل GoogleSignIn
      final GoogleSignIn googleSignIn = getGoogleSignIn();

      // تسجيل الدخول باستخدام Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw 'تم إلغاء عملية تسجيل الدخول';
      }

      // الحصول على تفاصيل المصادقة
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // تسجيل الدخول في Supabase باستخدام رمز المصادقة
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );

      LoggerService.info(
        'تم تسجيل الدخول بنجاح باستخدام Google',
        tag: 'AuthService',
      );

      return response;
    } catch (error) {
      LoggerService.error(
        'خطأ في تسجيل الدخول باستخدام Google: $error',
        tag: 'AuthService',
      );
      rethrow;
    }
  }

  /// تسجيل مستخدم جديد باستخدام البريد الإلكتروني وكلمة المرور
  ///
  /// [email] البريد الإلكتروني للمستخدم
  /// [password] كلمة المرور
  /// [name] اسم المستخدم
  /// [accountType] نوع الحساب (مستثمر أو مقترض)
  /// [emailRedirectTo] رابط إعادة التوجيه بعد تأكيد البريد الإلكتروني (اختياري)
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String accountType,
    String? emailRedirectTo,
  }) async {
    try {
      LoggerService.info(
        'بدء عملية إنشاء حساب جديد: $email',
        tag: 'AuthService',
      );

      // استخدام signInWithOtp بدلاً من signUp لتجنب رسائل تأكيد التسجيل
      final redirectUrl =
          emailRedirectTo ?? 'com.example.tamwuilk://home_screen';

      // إرسال رابط سحري للبريد الإلكتروني
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectUrl,
      );

      // إنشاء بيانات المستخدم التي سيتم تخزينها بعد تسجيل الدخول
      final userData = {'email': email, 'name': name, 'user_role': accountType};

      LoggerService.info(
        'تم إرسال رابط سحري بنجاح: $email',
        tag: 'AuthService',
      );

      return {'success': true, 'user': userData};
    } catch (error) {
      LoggerService.error(
        'خطأ في إرسال الرابط السحري: $error',
        tag: 'AuthService',
      );
      return {
        'success': false,
        'error': 'حدث خطأ أثناء إرسال الرابط السحري',
        'user': null,
      };
    }
  }

  /// تسجيل الدخول باستخدام مزود خدمة خارجي عبر OAuth
  ///
  /// [provider] هو مزود المصادقة (مثل Google أو Facebook)
  /// [redirectTo] هو عنوان URL الذي سيتم إعادة التوجيه إليه بعد المصادقة (اختياري)
  /// [scopes] هي الصلاحيات المطلوبة (اختياري)
  /// [authScreenLaunchMode] هو وضع فتح شاشة المصادقة (اختياري)
  /// [throwOnError] إذا كان true سيتم إلقاء الاستثناءات بدلاً من إرجاع false
  Future<bool> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
    String? scopes,
    LaunchMode? authScreenLaunchMode,
    bool throwOnError = false,
  }) async {
    try {
      LoggerService.info(
        'بدء عملية تسجيل الدخول عبر ${provider.name}...',
        tag: 'AuthService',
      );

      // تحديد عنوان URL الصحيح لإعادة التوجيه
      final String finalRedirectUrl =
          redirectTo ?? 'com.example.tamwuilk://home_screen';

      // تحديد الصلاحيات المطلوبة حسب المزود
      final String finalScopes = scopes ?? _getDefaultScopes(provider);

      // بدء عملية تسجيل الدخول عبر OAuth
      final res = await _supabase.auth.signInWithOAuth(
        provider,
        redirectTo: finalRedirectUrl,
        authScreenLaunchMode:
            authScreenLaunchMode ?? LaunchMode.externalApplication,
        scopes: finalScopes,
      );

      if (!res) {
        final errorMessage =
            'فشل في بدء عملية تسجيل الدخول عبر ${provider.name}';
        LoggerService.error(errorMessage, tag: 'AuthService');
        if (throwOnError) {
          throw AuthException(errorMessage);
        }
        return false;
      }

      LoggerService.info(
        'تم بدء عملية تسجيل الدخول عبر ${provider.name} بنجاح',
        tag: 'AuthService',
      );

      return true;
    } on AuthException catch (e) {
      LoggerService.error(
        'خطأ في المصادقة عبر ${provider.name}: ${e.message}',
        tag: 'AuthService',
        exception: e,
      );
      if (throwOnError) rethrow;
      return false;
    } catch (e) {
      LoggerService.error(
        'خطأ غير متوقع في تسجيل الدخول عبر ${provider.name}: $e',
        tag: 'AuthService',
        exception: e,
      );
      if (throwOnError) {
        throw Exception(
          'حدث خطأ غير متوقع أثناء تسجيل الدخول عبر ${provider.name}',
        );
      }
      return false;
    }
  }

  /// الحصول على الصلاحيات الافتراضية حسب مزود المصادقة
  String _getDefaultScopes(OAuthProvider provider) {
    switch (provider) {
      case OAuthProvider.google:
        return 'email,profile';
      case OAuthProvider.facebook:
        return 'email,public_profile';
      default:
        return '';
    }
  }

  /// تسجيل الدخول باستخدام مزود خارجي
  Future<bool> signInWithExternalProvider(
    BuildContext context,
    String providerUrl,
    String callbackUrlScheme,
  ) async {
    try {
      LoggerService.info(
        'بدء عملية تسجيل الدخول عبر مزود خارجي...',
        tag: 'AuthService',
      );

      // استخدام WebAuthService للمصادقة
      final code = await WebAuthService.authenticate(
        providerUrl: providerUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      // معالجة نتيجة المصادقة
      // التحقق من أن الـ Widget لا يزال مثبتًا في الشجرة قبل استخدام context
      if (context.mounted) {
        WebAuthService.handleAuthResult(context, code);
        return true;
      }
      return false;
    } catch (e) {
      LoggerService.error(
        'خطأ في عملية تسجيل الدخول عبر مزود خارجي: $e',
        tag: 'AuthService',
      );
      return false;
    }
  }

  /// تسجيل الدخول باستخدام حساب Facebook
  /// يستخدم flutter_facebook_auth للمصادقة المباشرة مع Facebook
  /// ثم يقوم بتسجيل الدخول في Supabase باستخدام رمز الوصول
  static Future<Map<String, dynamic>> signInWithFacebook({
    required String userRole,
  }) async {
    try {
      LoggerService.info(
        'بدء عملية تسجيل الدخول عبر فيسبوك...',
        tag: 'AuthService',
      );

      final success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'com.example.tamwuilk://home_screen?user_role=$userRole',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!success) {
        throw 'فشل في بدء عملية تسجيل الدخول عبر Facebook';
      }

      return {'success': true, 'user': null};
    } catch (error) {
      String errorMessage =
          'خطأ في تسجيل الدخول عبر Facebook: ${error.toString()}';

      LoggerService.error(
        errorMessage,
        tag: 'AuthService',
        exception: error.toString(),
      );

      return {'success': false, 'error': errorMessage, 'user': null};
    }
  }

  /// Handles native Google Sign-In flow.
  /// This function is intended for platforms where google_sign_in is used directly.
  Future<Map<String, dynamic>> signInWithGoogleNative() async {
    try {
      ///
      /// Web Client ID that you registered with Google Cloud.
      const webClientId =
          '131667174068-c7akeavsim0oe2njklindvb96n0bbtra.apps.googleusercontent.com'; // Placeholder

      const androidClientId =
          '131667174068-olnqvqhmcim4aqj5gs3e78kvaqvmkg93.apps.googleusercontent.com'; // Placeholder

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: androidClientId, // Use iosClientId for iOS
        serverClientId: webClientId, // Use webClientId for web
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in process
        return {
          'success': false,
          'user': null,
          'error': 'Google Sign-In cancelled',
        };
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // Sign in with Supabase using the ID token
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        LoggerService.warning(
          'signInWithIdToken did not return a user.',
          tag: 'AuthService',
        );
        return {
          'success': false,
          'user': null,
          'error': 'Google Sign-In failed: User not returned.',
        };
      }

      // You might want to fetch additional user profile data here if needed
      // Similar to what was done in _fetchUserProfileAndFormat

      return {
        'success': true,
        'user': {
          'id': response.user!.id,
          'email': response.user!.email,
          // Add other user data from response.user or fetched profile
        },
        'error': null,
      };
    } on AuthException catch (e) {
      LoggerService.error(
        'Error during native Google Sign-In (AuthException)',
        tag: 'AuthService',
        exception: e.message,
      );
      return {'success': false, 'error': e.message, 'user': null};
    } catch (e) {
      LoggerService.error(
        'Unexpected error during native Google Sign-In',
        tag: 'AuthService',
        exception: e.toString(),
      );
      return {
        'success': false,
        'error': 'Unexpected error during Google Sign-In: ${e.toString()}',
        'user': null,
      };
    }
  }
}
