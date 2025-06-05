import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// معالج الأخطاء المخصص للتطبيق
class AppErrorHandler {
  /// تنفيذ عملية مع معالجة الأخطاء بشكل آمن
  static Future<T?> runSafely<T>(
    Future<T> Function() operation, {
    T? defaultValue,
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } on AuthException catch (e, stackTrace) {
      // معالجة أخطاء المصادقة
      _handleError(
        technicalMessage: 'خطأ في المصادقة: ${e.message}',
        userMessage: errorMessage ?? 'حدث خطأ أثناء المصادقة',
        error: e,
        stackTrace: stackTrace,
      );
    } on PostgrestException catch (e, stackTrace) {
      // معالجة أخطاء قاعدة البيانات
      _handleError(
        technicalMessage: 'خطأ في قاعدة البيانات: ${e.message}',
        userMessage: errorMessage ?? 'حدث خطأ أثناء الوصول إلى قاعدة البيانات',
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      // معالجة الأخطاء العامة
      _handleError(
        technicalMessage: e.toString(),
        userMessage: errorMessage ?? 'حدث خطأ غير متوقع',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return defaultValue;
  }

  /// معالجة الخطأ وتسجيله
  static void _handleError({
    required String technicalMessage,
    required String userMessage,
    required Object error,
    required StackTrace stackTrace,
  }) {
    // تسجيل الخطأ التقني للتتبع
    debugPrint('خطأ تقني: $technicalMessage');
    debugPrint('تتبع المكدس: $stackTrace');

    // يمكن إضافة منطق إضافي هنا مثل:
    // - إرسال الخطأ إلى خدمة تتبع الأخطاء
    // - تخزين الخطأ محلياً للتحليل
    // - إرسال إشعار للمستخدم

    // رمي استثناء مع رسالة مناسبة للمستخدم
    throw Exception(userMessage);
  }
}
