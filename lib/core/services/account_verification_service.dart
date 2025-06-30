import 'package:supabase_flutter/supabase_flutter.dart';
import 'logger_service.dart';

/// خدمة التحقق من نوع الحساب
/// تتحقق من نوع الحساب المخزن في قاعدة البيانات وتمنع تسجيل الدخول بنوع مختلف
class AccountVerificationService {
  // استخدام getter للحصول على مثيل Supabase
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// التحقق من نوع الحساب أو إنشاء ملف تعريف جديد إذا لم يكن موجودًا
  ///
  /// [accountType] نوع الحساب المطلوب التحقق منه (investor أو project_owner)
  /// يتحقق من وجود ملف تعريف للمستخدم الحالي ويقارن نوع الحساب المخزن
  /// إذا لم يكن هناك ملف تعريف، يقوم بإنشاء واحد جديد
  /// إذا كان هناك ملف تعريف ولكن بنوع حساب مختلف، يرمي استثناءً
  static Future<void> checkOrCreateProfile(String accountType) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      LoggerService.error(
        'محاولة التحقق من نوع الحساب بدون تسجيل دخول',
        tag: 'AccountVerificationService',
      );
      throw Exception("لم يتم تسجيل الدخول");
    }

    LoggerService.info(
      'التحقق من نوع الحساب للمستخدم: ${user.id}',
      tag: 'AccountVerificationService',
    );

    try {
      // إنشاء جدول profiles إذا لم يكن موجوداً
      try {
        await _supabase.rpc('create_profiles_table_if_not_exists');
      } catch (e) {
        LoggerService.warning(
          'خطأ في إنشاء جدول profiles: $e',
          tag: 'AccountVerificationService',
        );
        // نتجاهل الخطأ ونستمر
      }

      // البحث عن ملف تعريف المستخدم
      final profile = await _supabase
          .from('profiles')
          .select('user_role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        // أول مرة يتم تسجيل المستخدم - نحفظ النوع
        LoggerService.info(
          'إنشاء ملف تعريف جديد للمستخدم: ${user.id} بنوع حساب: $accountType',
          tag: 'AccountVerificationService',
        );

        try {
          // محاولة إنشاء ملف تعريف باستخدام upsert
          await _supabase.from('profiles').upsert({
            'id': user.id,
            'email': user.email,
            'user_role': accountType,
            // تجنب استخدام حقول التاريخ التي قد تسبب مشاكل مع ذاكرة التخزين المؤقت للمخطط
          });
        } catch (e) {
          LoggerService.warning(
            'خطأ في إنشاء ملف التعريف باستخدام upsert: $e',
            tag: 'AccountVerificationService',
          );

          try {
            // محاولة إنشاء ملف تعريف باستخدام insert
            await _supabase.from('profiles').insert({
              'id': user.id,
              'email': user.email,
              'user_role': accountType,
              // تجنب استخدام حقول التاريخ التي قد تسبب مشاكل مع ذاكرة التخزين المؤقت للمخطط
            });
          } catch (insertError) {
            // إذا فشل الإدراج بسبب مشكلة في عمود created_at
            if (insertError is PostgrestException &&
                insertError.message.contains("created_at")) {
              LoggerService.warning(
                'خطأ في عمود created_at، محاولة إنشاء ملف تعريف بدون حقول التاريخ: $insertError',
                tag: 'AccountVerificationService',
              );
              // محاولة أخيرة بدون أي حقول إضافية
              await _supabase.from('profiles').insert({
                'id': user.id,
                'email': user.email,
                'user_role': accountType,
              });
            } else {
              // إعادة رمي الخطأ إذا لم يكن متعلقًا بعمود created_at
              rethrow;
            }
          }
        }

        LoggerService.info(
          'تم إنشاء ملف تعريف بنجاح للمستخدم: ${user.id}',
          tag: 'AccountVerificationService',
        );
      } else {
        // التحقق من تطابق نوع الحساب
        final storedType = profile['user_role'];
        if (storedType != accountType) {
          LoggerService.warning(
            'محاولة تسجيل دخول بنوع حساب مختلف. المخزن: $storedType، المطلوب: $accountType',
            tag: 'AccountVerificationService',
          );

          throw Exception(
            "البريد الإلكتروني هذا مسجل كـ '$storedType'، لا يمكنك تسجيل الدخول كـ '$accountType'",
          );
        }

        LoggerService.info(
          'تم التحقق من نوع الحساب بنجاح للمستخدم: ${user.id}',
          tag: 'AccountVerificationService',
        );
      }
    } catch (error) {
      LoggerService.error(
        'خطأ في التحقق من نوع الحساب: $error',
        tag: 'AccountVerificationService',
      );
      rethrow;
    }
  }
}
