import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart';
import 'logger_service.dart';

/// خدمة إدارة الملفات الشخصية للمستخدمين
/// تتعامل مع جدول profiles في Supabase
class ProfileService {
  // استخدام getter للحصول على مثيل Supabase
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// إنشاء ملف شخصي جديد للمستخدم بعد التسجيل
  ///
  /// [userId] معرف المستخدم
  /// [accountType] نوع الحساب (investor أو project_owner)
  /// [name] اسم المستخدم (اختياري)
  /// [email] البريد الإلكتروني للمستخدم (اختياري)
  static Future<bool> createProfile({
    required String userId,
    required String accountType,
    String? name,
    String? email,
  }) async {
    try {
      LoggerService.info(
        'إنشاء ملف شخصي جديد للمستخدم: $userId',
        tag: 'ProfileService',
      );

      // التحقق من صحة نوع الحساب
      if (accountType != 'investor' && accountType != 'project_owner') {
        throw 'نوع الحساب غير صالح. يجب أن يكون "investor" أو "project_owner"';
      }

      // إنشاء ملف شخصي جديد في جدول profiles
      await _supabase.from('profiles').insert({
        'id': userId,
        'user_id': userId,
        'name': name,
        'email': email,
        'role': accountType,
        'created_at': DateTime.now().toIso8601String(),
      });

      LoggerService.info(
        'تم إنشاء الملف الشخصي بنجاح للمستخدم: $userId',
        tag: 'ProfileService',
      );

      return true;
    } catch (error) {
      LoggerService.error(
        'خطأ في إنشاء الملف الشخصي: $error',
        tag: 'ProfileService',
      );
      return false;
    }
  }

  /// الحصول على نوع حساب المستخدم
  ///
  /// [userId] معرف المستخدم
  static Future<String?> getAccountType(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

      return response['role'] as String?;
    } catch (error) {
      LoggerService.error(
        'خطأ في الحصول على نوع الحساب: $error',
        tag: 'ProfileService',
      );
      return null;
    }
  }

  /// تحديث الملف الشخصي للمستخدم
  ///
  /// [userId] معرف المستخدم
  /// [data] البيانات المراد تحديثها
  static Future<bool> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _supabase.from('profiles').update(data).eq('id', userId);

      LoggerService.info(
        'تم تحديث الملف الشخصي بنجاح للمستخدم: $userId',
        tag: 'ProfileService',
      );

      return true;
    } catch (error) {
      LoggerService.error(
        'خطأ في تحديث الملف الشخصي: $error',
        tag: 'ProfileService',
      );
      return false;
    }
  }

  /// الحصول على الملف الشخصي الكامل للمستخدم
  ///
  /// [userId] معرف المستخدم
  static Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromMap(response);
    } catch (error, stackTrace) {
      LoggerService.error(
        'خطأ في الحصول على الملف الشخصي: $error',
        tag: 'ProfileService',
        exception: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
