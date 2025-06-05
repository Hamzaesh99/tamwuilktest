import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'email_verification_dialog.dart';

class EmailVerificationHandler {
  /// التحقق من رابط تأكيد البريد الإلكتروني
  static Future<void> handleEmailVerification(dynamic redirectUrl) async {
    if (redirectUrl == null) return;
    
    Uri uri;
    try {
      // استخراج معلومات التحقق من الرابط
      if (redirectUrl is String) {
        uri = Uri.parse(redirectUrl);
      } else if (redirectUrl is Uri) {
        uri = redirectUrl;
      } else {
        throw ArgumentError('نوع الرابط غير مدعوم');
      }
      
      final params = uri.queryParameters;
      final type = params['type'];

      // التحقق من نوع الرابط
      if (type == 'signup' || type == 'magiclink') {
        // محاولة تسجيل الدخول باستخدام الرابط السحري
        final _ = await Supabase.instance.client.auth.getSessionFromUrl(
          uri,
        );

        // عرض مربع حوار التأكيد إذا نجحت العملية
        await Get.dialog(
          EmailVerificationDialog(),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      // عرض رسالة خطأ
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء التحقق من البريد الإلكتروني',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
