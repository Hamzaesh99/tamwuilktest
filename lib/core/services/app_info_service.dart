import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// خدمة لإدارة معلومات التطبيق
class AppInfoService {
  static final AppInfoService _instance = AppInfoService._internal();
  factory AppInfoService() => _instance;
  AppInfoService._internal();

  PackageInfo? _packageInfo;
  String get packageName => _packageInfo?.packageName ?? 'com.default.tamwuilk';
  String get appName => _packageInfo?.appName ?? 'tamwuilk';
  String get version => _packageInfo?.version ?? '1.0.0';
  String get buildNumber => _packageInfo?.buildNumber ?? '1';

  /// الحصول على عنوان إعادة التوجيه الكامل للمصادقة
  String get redirectUrl =>
      'https://tamwuilkoatuh.liveblog365.com://login-callback';

  /// تهيئة خدمة معلومات التطبيق
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      debugPrint('تم استرجاع معلومات التطبيق: $packageName');
    } catch (e) {
      debugPrint('خطأ في استرجاع معلومات التطبيق: $e');
    }
  }
}
