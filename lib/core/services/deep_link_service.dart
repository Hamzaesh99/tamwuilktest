import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'package:tamwuilktest/core/services/logger_service.dart';
import 'package:tamwuilktest/Routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// خدمة للتعامل مع الروابط العميقة في التطبيق
class DeepLinkService {
  final GlobalKey<NavigatorState> _navigatorKey;
  StreamSubscription? _linkSubscription;
  final supabase = Supabase.instance.client;
  AppLinks? _appLinks;

  DeepLinkService(this._navigatorKey);

  /// تهيئة خدمة الروابط العميقة
  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    if (kIsWeb) {
      // معالجة خاصة لمنصة الويب
      _handleWebDeepLinks();
      return;
    }

    // استقبال الرابط الأولي عند فتح التطبيق
    try {
      final initialLink = await _appLinks!.getInitialAppLink();
      if (initialLink != null) {
        LoggerService.info(
          'تم استلام رابط أولي: $initialLink',
          tag: 'DeepLinks',
        );
        _handleLink(initialLink.toString());
      }
    } catch (e) {
      LoggerService.error(
        'خطأ في استقبال الرابط الأولي: $e',
        tag: 'DeepLinks',
        exception: e,
      );
    }

    // إعداد مستمع للروابط القادمة أثناء تشغيل التطبيق
    _linkSubscription = _appLinks!.uriLinkStream.listen(
      (Uri? link) {
        if (link != null) {
          LoggerService.info(
            'تم استلام رابط أثناء التشغيل: $link',
            tag: 'DeepLinks',
          );
          _handleLink(link.toString());
        }
      },
      onError: (err) {
        LoggerService.error(
          'خطأ في استقبال الروابط أثناء التشغيل: $err',
          tag: 'DeepLinks',
          exception: err,
        );
      },
    );
  }

  /// معالجة الروابط في منصة الويب
  void _handleWebDeepLinks() {
    LoggerService.info(
      'تهيئة معالجة الروابط العميقة لمنصة الويب',
      tag: 'DeepLinks',
    );

    try {
      _appLinks!.uriLinkStream.listen(
        (Uri? link) async {
          if (link != null) {
            LoggerService.info(
              'تم استلام رابط في الويب: $link',
              tag: 'DeepLinks',
            );
            await _handleLink(link.toString());
          }
        },
        onError: (err) {
          LoggerService.error(
            'خطأ في استقبال الروابط في الويب: $err',
            tag: 'DeepLinks',
            exception: err,
          );
        },
      );
    } catch (e) {
      LoggerService.error(
        'خطأ في تهيئة مستمع الروابط للويب: $e',
        tag: 'DeepLinks',
        exception: e,
      );
    }
  }

  /// معالجة الرابط الوارد
  Future<void> _handleLink(String link) async {
    try {
      final uri = Uri.parse(link);
      LoggerService.info('معالجة الرابط: ${uri.toString()}', tag: 'DeepLinks');

      // التحقق من رابط إعادة التوجيه من المصادقة
      if (uri.scheme == 'tamwuilk' && uri.host == 'home_screen-callback') {
        // استخراج رمز الوصول إذا كان موجوداً
        final accessToken = uri.queryParameters['access_token'];
        if (accessToken != null) {
          // يمكنك تخزين رمز الوصول أو معالجته هنا
          LoggerService.info(
            'تم استلام رمز الوصول من المصادقة',
            tag: 'DeepLinks',
          );
        }

        // التوجيه إلى الشاشة الرئيسية
        _navigatorKey.currentState?.pushReplacementNamed(AppRoutes.home);
        return;
      }

      // التحقق من صحة الرابط
      if (!_isValidLink(uri)) {
        LoggerService.error(
          'رابط غير صالح: ${uri.toString()}',
          tag: 'DeepLinks',
        );
        return;
      }

      // التحقق من نوع الرابط ومعالجته
      if (_isAuthLink(uri)) {
        await _handleAuthLink(uri);
      } else if (_isResetPasswordLink(uri)) {
        await _handleResetPasswordLink(uri);
      } else if (_isVerificationLink(uri)) {
        await _handleVerificationLink(uri);
      } else {
        await _handleGenericLink(uri);
      }
    } catch (e) {
      LoggerService.error(
        'خطأ في معالجة الرابط: $e',
        tag: 'DeepLinks',
        exception: e,
      );
    }
  }

  /// التحقق من صحة الرابط
  bool _isValidLink(Uri uri) {
    return uri.hasScheme && uri.host.isNotEmpty;
  }

  /// التحقق إذا كان الرابط هو رابط مصادقة
  bool _isAuthLink(Uri uri) {
    return uri.path.contains('/auth/v1/callback') ||
        uri.queryParameters.containsKey('access_token') ||
        uri.queryParameters.containsKey('code') ||
        uri.path.contains('/auth/callback') ||
        uri.path.contains('/home_screen-callback');
  }

  /// التحقق إذا كان الرابط هو رابط إعادة تعيين كلمة المرور
  bool _isResetPasswordLink(Uri uri) {
    return uri.path.contains('/reset-password');
  }

  /// التحقق إذا كان الرابط هو رابط تحقق من البريد الإلكتروني
  bool _isVerificationLink(Uri uri) {
    return uri.path.contains('/verify-email');
  }

  /// معالجة رابط المصادقة
  Future<void> _handleAuthLink(Uri uri) async {
    try {
      LoggerService.info(
        'بدء معالجة رابط المصادقة: ${uri.toString()}',
        tag: 'DeepLinks',
      );

      // التحقق من وجود رمز الوصول أو رمز المصادقة
      final accessToken = uri.queryParameters['access_token'];
      final code = uri.queryParameters['code'];

      // التعامل مع رابط Facebook الخاص
      if (uri.path.contains('/home_screen-callback') && code != null) {
        LoggerService.info(
          'معالجة رابط إعادة التوجيه من Facebook: $code',
          tag: 'DeepLinks',
        );

        // توجيه المستخدم إلى صفحة استقبال المصادقة
        await _navigatorKey.currentState?.pushReplacementNamed(
          AppRoutes.authCallback,
          arguments: {'code': code},
        );
        return;
      }

      if (accessToken != null || code != null) {
        Session? session;

        if (accessToken != null) {
          LoggerService.info(
            'محاولة تعيين جلسة مع رمز الوصول',
            tag: 'DeepLinks',
          );
          final res = await supabase.auth.setSession(accessToken);
          session = res.session;
        } else if (code != null) {
          LoggerService.info(
            'محاولة تبادل الرمز للحصول على جلسة',
            tag: 'DeepLinks',
          );
          final response = await supabase.auth.exchangeCodeForSession(code);
          session = response.session;
        }

        if (session != null) {
          LoggerService.info(
            'تم إنشاء الجلسة بنجاح، جاري التوجيه للصفحة الرئيسية',
            tag: 'DeepLinks',
          );
          await _navigatorKey.currentState?.pushReplacementNamed(
            AppRoutes.home,
          );
          return;
        }
      }

      LoggerService.error(
        'فشل في معالجة رابط المصادقة: لم يتم العثور على رمز صالح',
        tag: 'DeepLinks',
      );
    } catch (e) {
      LoggerService.error(
        'خطأ في معالجة رابط المصادقة: $e',
        tag: 'DeepLinks',
        exception: e,
      );
    }
  }

  /// معالجة رابط إعادة تعيين كلمة المرور
  Future<void> _handleResetPasswordLink(Uri uri) async {
    try {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];

      if (token == null || token.isEmpty) {
        throw Exception('الرمز غير موجود أو غير صالح');
      }

      LoggerService.info(
        'معالجة رابط إعادة تعيين كلمة المرور للبريد: $email',
        tag: 'DeepLinks',
      );

      if (_navigatorKey.currentState == null) {
        throw Exception('NavigatorState غير متوفر');
      }

      await _navigatorKey.currentState!.pushNamedAndRemoveUntil(
        AppRoutes.resetPassword,
        (route) => false, // إزالة كل الشاشات السابقة من المكدس
        arguments: {
          'token': token,
          'email': email ?? '', // إرسال البريد الإلكتروني إذا كان متوفرًا
        },
      );

      LoggerService.info(
        'تم التوجيه إلى صفحة إعادة تعيين كلمة المرور بنجاح',
        tag: 'DeepLinks',
      );
    } catch (e) {
      LoggerService.error(
        'فشل في معالجة رابط إعادة تعيين كلمة المرور: $e',
        tag: 'DeepLinks',
        exception: e,
      );
      rethrow;
    }
  }

  /// معالجة رابط التحقق من البريد الإلكتروني
  Future<void> _handleVerificationLink(Uri uri) async {
    try {
      final token = uri.queryParameters['token'];
      if (token == null || token.isEmpty) {
        throw Exception('رمز التحقق غير موجود أو غير صالح');
      }

      LoggerService.info(
        'معالجة رابط التحقق من البريد الإلكتروني',
        tag: 'DeepLinks',
      );

      if (_navigatorKey.currentState == null) {
        throw Exception('NavigatorState غير متوفر');
      }

      await _navigatorKey.currentState!.pushNamed(
        AppRoutes.verifyEmail,
        arguments: {'token': token},
      );

      LoggerService.info(
        'تم التوجيه إلى صفحة التحقق من البريد الإلكتروني بنجاح',
        tag: 'DeepLinks',
      );
    } catch (e) {
      LoggerService.error(
        'فشل في معالجة رابط التحقق من البريد الإلكتروني: $e',
        tag: 'DeepLinks',
        exception: e,
      );
      rethrow;
    }
  }

  /// معالجة الروابط العامة
  Future<void> _handleGenericLink(Uri uri) async {
    // يمكن إضافة منطق لمعالجة أنواع أخرى من الروابط
    LoggerService.info('معالجة رابط عام: $uri', tag: 'DeepLinks');

    // مثال: التوجيه إلى صفحة معينة بناءً على المسار
    if (uri.path.contains('/product/')) {
      final productId = uri.pathSegments.last;
      await _navigatorKey.currentState?.pushNamed(
        AppRoutes.productDetails,
        arguments: {'productId': productId},
      );
    }
  }

  /// الحصول على عنوان إعادة التوجيه المناسب للمنصة الحالية
  String _getRedirectUrl() {
    // استخدام عنوان مختلف للويب
    final redirectUrl = kIsWeb
        ? '${Uri.base.origin}/auth-callback'
        : 'com.example.tamwuilk://home_screen';

    return redirectUrl;
  }

  /// تسجيل الدخول باستخدام Google
  Future<void> signInWithGoogle() async {
    try {
      final redirectUrl = _getRedirectUrl();

      final authUrl = await supabase.auth.getOAuthSignInUrl(
        provider: OAuthProvider.google,
        redirectTo: redirectUrl,
      );

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'tamwuilk',
      );

      final uri = Uri.parse(result);
      await _handleAuthLink(uri);
    } catch (e) {
      LoggerService.error(
        'خطأ في تسجيل الدخول باستخدام Google: $e',
        tag: 'DeepLinks',
        exception: e,
      );
    }
  }

  /// تسجيل الدخول باستخدام Facebook
  Future<void> signInWithFacebook() async {
    try {
      final redirectUrl = _getRedirectUrl();

      LoggerService.info(
        'بدء عملية تسجيل الدخول باستخدام Facebook',
        tag: 'DeepLinks',
      );

      LoggerService.info(
        'استخدام عنوان إعادة التوجيه: $redirectUrl',
        tag: 'DeepLinks',
      );

      await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: redirectUrl,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      LoggerService.info(
        'تم بدء عملية المصادقة مع Facebook بنجاح',
        tag: 'DeepLinks',
      );
    } catch (e) {
      LoggerService.error(
        'خطأ في تسجيل الدخول باستخدام Facebook: $e',
        tag: 'DeepLinks',
        exception: e,
      );
      rethrow;
    }
  }

  /// إلغاء الاشتراك في مستمع الروابط عند إغلاق التطبيق
  void dispose() {
    _linkSubscription?.cancel();
  }
}
