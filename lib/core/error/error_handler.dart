import 'package:flutter/foundation.dart';
import '../services/logger_service.dart';

/// معالج الأخطاء في التطبيق
class AppErrorHandler {
  static bool _initialized = false;

  /// تهيئة معالج الأخطاء
  static void init() {
    if (_initialized) return;

    // تسجيل معالج الأخطاء غير المتوقعة
    FlutterError.onError = (FlutterErrorDetails details) {
      LoggerService.error(
        'خطأ غير متوقع: ${details.exception}',
        tag: 'AppErrorHandler',
        exception: details.exception,
        stackTrace: details.stack,
      );

      // إعادة رمي الخطأ في وضع التطوير فقط
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    // تسجيل معالج الأخطاء غير المعالجة
    PlatformDispatcher.instance.onError = (error, stack) {
      LoggerService.error(
        'خطأ غير معالج: $error',
        tag: 'AppErrorHandler',
        exception: error,
        stackTrace: stack,
      );

      // إعادة رمي الخطأ في وضع التطوير فقط
      if (kDebugMode) {
        print('خطأ غير معالج: $error');
        print('تتبع المكدس: $stack');
      }

      return true; // منع انتشار الخطأ
    };

    _initialized = true;
  }
}
