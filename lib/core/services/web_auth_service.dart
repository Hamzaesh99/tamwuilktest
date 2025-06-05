import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'logger_service.dart';
import '../../../Routing/app_routes.dart';

/// خدمة المصادقة عبر الويب
class WebAuthService {
  /// مصادقة المستخدم باستخدام مزود خارجي
  static Future<String> authenticate({
    required String providerUrl,
    required String callbackUrlScheme,
  }) async {
    try {
      // فتح رابط المصادقة في المتصفح
      final uri = Uri.parse(providerUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'لا يمكن فتح رابط المصادقة';
      }

      // انتظار استجابة المصادقة
      final appLinks = AppLinks();
      final result = await appLinks.uriLinkStream.first;
      // تم إزالة الفحص غير الضروري لـ null لأن Stream.first لا يمكن أن تعيد null
      // إذا كان هناك خطأ، سيتم إلقاء استثناء بدلاً من ذلك

      // استخراج رمز المصادقة من الرابط
      final code = result.queryParameters['code'];
      if (code == null) throw 'لم يتم العثور على رمز المصادقة';

      return code;
    } catch (e) {
      LoggerService.error('خطأ في عملية المصادقة: $e', tag: 'WebAuthService');
      rethrow;
    }
  }

  /// معالجة نتيجة المصادقة
  static Future<void> handleAuthResult(
    BuildContext context,
    String code,
  ) async {
    try {
      // تبادل الرمز مع Supabase للحصول على الجلسة
      final client = Supabase.instance.client;
      final response = await client.auth.getSessionFromUrl(
        Uri.parse(Uri.base.toString()),
      );
      await client.auth.setSession(response.session.accessToken);

      // التوجيه إلى صفحة النجاح
      if (context.mounted) {
        AppRoutes.navigateAndRemoveUntil(context, AppRoutes.success);
      }
    } catch (e) {
      LoggerService.error(
        'خطأ في معالجة نتيجة المصادقة: $e',
        tag: 'WebAuthService',
      );
      if (context.mounted) {
        // عرض رسالة الخطأ للمستخدم
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشلت عملية المصادقة: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // التوجيه إلى صفحة تسجيل الدخول
        AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
      }
    }
  }
}
