import 'package:flutter/foundation.dart';

/// خدمة تسجيل مخصصة للتطبيق
/// توفر واجهة موحدة للتسجيل مع إمكانية تعطيل التسجيل في بيئة الإنتاج
class LoggerService {
  // مستويات التسجيل
  static const int _kDebugLevel = 0;
  static const int _kInfoLevel = 1;
  static const int _kWarningLevel = 2;
  static const int _kErrorLevel = 3;

  // المستوى الحالي للتسجيل (يمكن تغييره حسب البيئة)
  static int _currentLevel = kDebugMode ? _kDebugLevel : _kInfoLevel;

  /// تعيين مستوى التسجيل
  static void setLogLevel(int level) {
    _currentLevel = level;
  }

  /// تسجيل رسالة تصحيح
  static void debug(String message, {String? tag}) {
    if (_currentLevel <= _kDebugLevel) {
      _log('DEBUG', message, tag: tag);
    }
  }

  /// تسجيل رسالة معلومات
  static void info(String message, {String? tag}) {
    if (_currentLevel <= _kInfoLevel) {
      _log('INFO', message, tag: tag);
    }
  }

  /// تسجيل رسالة تحذير
  static void warning(String message, {String? tag}) {
    if (_currentLevel <= _kWarningLevel) {
      _log('WARNING', message, tag: tag);
    }
  }

  /// تسجيل رسالة خطأ
  static void error(String message,
      {String? tag, Object? exception, StackTrace? stackTrace}) {
    if (_currentLevel <= _kErrorLevel) {
      _log('ERROR', message, tag: tag);
      if (exception != null) {
        _log('ERROR', 'Exception: $exception', tag: tag);
      }
      if (stackTrace != null) {
        _log('ERROR', 'StackTrace: $stackTrace', tag: tag);
      }
    }
  }

  /// دالة التسجيل الداخلية
  static void _log(String level, String message, {String? tag}) {
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
    final String tagStr = tag != null ? '[$tag]' : '';

    if (kDebugMode) {
      debugPrint('$formattedDate [$level] $tagStr $message');
    }
  }

  /// تنسيق الرقم إلى خانتين
  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
