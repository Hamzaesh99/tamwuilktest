import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tamwuilktest/core/shared/models/project_model.dart';
import 'package:tamwuilktest/core/shared/models/offer_model.dart';
import 'package:tamwuilktest/core/shared/models/comment_model.dart';

import 'package:tamwuilktest/core/models/app_user.dart';
import 'error_handler.dart';
import 'logger_service.dart';

/// خدمة لتغليف استدعاءات Supabase بمعالجة الاستثناءات وتطبيق صلاحيات RLS
class SupabaseService {
  /// الحصول على مثيل Supabase
  static SupabaseClient get client => Supabase.instance.client;

  /// الحصول على معرف المستخدم الحالي
  static String? get currentUserId => client.auth.currentUser?.id;

  /// التحقق مما إذا كان المستخدم مسجل الدخول
  static bool get isAuthenticated => currentUserId != null;

  /// تنفيذ استعلام قراءة من Supabase مع معالجة الاستثناءات
  static Future<List<Map<String, dynamic>>> select(
    String table, {
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final result = await AppErrorHandler.runSafely(
      () async {
        // بدء الاستعلام
        dynamic query = client.from(table).select(columns);

        // إضافة الفلاتر إذا وجدت
        if (filters != null) {
          filters.forEach((key, value) {
            query = query.eq(key, value);
          });
        }

        // إضافة الترتيب إذا وجد
        if (orderBy != null) {
          query = query.order(orderBy);
        }

        // إضافة الحد إذا وجد
        if (limit != null) {
          query = query.limit(limit);
        }

        // إضافة الإزاحة إذا وجدت
        if (offset != null) {
          query = query.range(offset, offset + (limit ?? 20) - 1);
        }

        // تنفيذ الاستعلام
        final response = await query;
        return List<Map<String, dynamic>>.from(response);
      },
      defaultValue: <Map<String, dynamic>>[],
      errorMessage: 'حدث خطأ أثناء استعلام البيانات من Supabase',
    );

    return result ?? <Map<String, dynamic>>[];
  }

  /// تنفيذ استعلام إدراج في Supabase مع معالجة الاستثناءات
  static Future<Map<String, dynamic>?> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    return await AppErrorHandler.runSafely(() async {
      final response = await client.from(table).insert(data).select();
      if (response.isNotEmpty) {
        return Map<String, dynamic>.from(response.first);
      }
      return <String, dynamic>{}; // إرجاع قيمة فارغة بدلاً من رمي استثناء
    }, errorMessage: 'حدث خطأ أثناء إدراج البيانات في Supabase');
  }

  /// تنفيذ استعلام تحديث في Supabase مع معالجة الاستثناءات
  static Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> filters,
  }) async {
    final result = await AppErrorHandler.runSafely(
      () async {
        // بدء الاستعلام
        dynamic query = client.from(table).update(data);

        // إضافة الفلاتر
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });

        // تنفيذ الاستعلام وجلب النتائج
        final response = await query.select();
        return List<Map<String, dynamic>>.from(response);
      },
      defaultValue: <Map<String, dynamic>>[],
      errorMessage: 'حدث خطأ أثناء تحديث البيانات في Supabase',
    );

    return result ?? <Map<String, dynamic>>[];
  }

  /// تنفيذ استعلام حذف في Supabase مع معالجة الاستثناءات
  static Future<bool> delete(
    String table, {
    required Map<String, dynamic> filters,
  }) async {
    final result = await AppErrorHandler.runSafely(
      () async {
        // بدء الاستعلام
        dynamic query = client.from(table).delete();

        // إضافة الفلاتر
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });

        // تنفيذ الاستعلام
        await query;
        return true;
      },
      defaultValue: false,
      errorMessage: 'حدث خطأ أثناء حذف البيانات من Supabase',
    );

    return result ?? false;
  }

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور مع معالجة الاستثناءات
  static Future<AuthResponse?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    return await AppErrorHandler.runSafely(() async {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    }, errorMessage: 'حدث خطأ أثناء تسجيل الدخول');
  }

  /// تسجيل الدخول باستخدام مزود خارجي مع معالجة الاستثناءات
  static Future<bool> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
  }) async {
    final result = await AppErrorHandler.runSafely(
      () async {
        return await client.auth.signInWithOAuth(
          provider,
          redirectTo: redirectTo,
          authScreenLaunchMode: LaunchMode.externalApplication,
        );
      },
      defaultValue: false,
      errorMessage: 'حدث خطأ أثناء تسجيل الدخول باستخدام $provider',
    );

    return result ?? false;
  }

  /// تسجيل الخروج مع معالجة الاستثناءات
  static Future<void> signOut() async {
    await AppErrorHandler.runSafely(() async {
      await client.auth.signOut();
    }, errorMessage: 'حدث خطأ أثناء تسجيل الخروج');
  }

  // ==================== وظائف إدارة المستخدمين ====================

  /// جلب معلومات المستخدم الحالي
  static Future<AppUser?> getCurrentUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', currentUserId!)
          .single();

      return AppUser.fromMap(response);
    } catch (e) {
      LoggerService.error(
        'خطأ في جلب ملف المستخدم: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return null;
    }
  }

  /// تحديث ملف المستخدم
  static Future<bool> updateUserProfile(AppUser user) async {
    if (!isAuthenticated) return false;

    try {
      await client.from('profiles').upsert(user.toMap(), onConflict: 'id');
      return true;
    } catch (e) {
      LoggerService.error(
        'خطأ في تحديث ملف المستخدم: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return false;
    }
  }

  /// تسجيل مستخدم جديد وإنشاء ملف شخصي له
  static Future<AuthResponse?> registerUser({
    required String email,
    required String password,
    required String name,
    required String userRole,
  }) async {
    try {
      // تسجيل المستخدم في نظام المصادقة
      final authResponse = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        // إنشاء ملف شخصي للمستخدم
        await client.from('profiles').insert({
          'id': authResponse.user!.id,
          'email': email,
          'name': name,
          'user_role': userRole,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return authResponse;
    } catch (e) {
      LoggerService.error(
        'خطأ في تسجيل المستخدم: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return null;
    }
  }

  /// جلب دور المستخدم الحالي
  static Future<String?> getCurrentUserRole() async {
    if (!isAuthenticated) return null;

    try {
      final response = await client
          .from('profiles')
          .select('user_role')
          .eq('id', currentUserId!)
          .single();

      return response['user_role'] as String?;
    } catch (e) {
      LoggerService.error(
        'خطأ في جلب دور المستخدم: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return null;
    }
  }

  // ==================== وظائف إدارة المشاريع ====================

  /// جلب جميع المشاريع
  static Future<List<Project>> getAllProjects({
    String? category,
    String? status,
    String? orderBy,
    int? limit,
  }) async {
    try {
      dynamic query = client.from('projects').select();

      if (category != null) {
        query = query.eq('category', category);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      if (orderBy != null) {
        query = query.order(orderBy);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(
        response,
      ).map((data) => Project.fromMap(data)).toList();
    } catch (e) {
      LoggerService.error(
        'خطأ في جلب المشاريع: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return [];
    }
  }

  /// جلب مشاريع المستخدم الحالي
  static Future<List<Project>> getUserProjects() async {
    if (!isAuthenticated) return [];

    try {
      final response = await client
          .from('projects')
          .select()
          .eq('owner_id', currentUserId!)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(
        response,
      ).map((data) => Project.fromMap(data)).toList();
    } catch (e) {
      LoggerService.error(
        'خطأ في جلب مشاريع المستخدم: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return [];
    }
  }

  /// إنشاء مشروع جديد
  static Future<Project?> createProject(Project project) async {
    if (!isAuthenticated) return null;

    try {
      // التأكد من تعيين معرف المالك للمستخدم الحالي
      final projectData = project
          .copyWith(ownerId: currentUserId!, createdAt: DateTime.now())
          .toMap();

      final response = await client
          .from('projects')
          .insert(projectData)
          .select();

      if (response.isNotEmpty) {
        return Project.fromMap(response.first);
      }
      return null;
    } catch (e) {
      LoggerService.error(
        'خطأ في إنشاء المشروع: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return null;
    }
  }

  /// تحديث مشروع
  static Future<bool> updateProject(Project project) async {
    if (!isAuthenticated) return false;

    try {
      // التحقق من أن المستخدم هو مالك المشروع (سيتم التحقق أيضًا بواسطة RLS)
      await client
          .from('projects')
          .update(project.toMap())
          .eq('id', project.id)
          .eq('owner_id', currentUserId!);

      return true;
    } catch (e) {
      LoggerService.error(
        'خطأ في تحديث المشروع: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return false;
    }
  }

  /// حذف مشروع
  static Future<bool> deleteProject(String projectId) async {
    if (!isAuthenticated) return false;

    try {
      // التحقق من أن المستخدم هو مالك المشروع (سيتم التحقق أيضًا بواسطة RLS)
      await client
          .from('projects')
          .delete()
          .eq('id', projectId)
          .eq('owner_id', currentUserId!);

      return true;
    } catch (e) {
      LoggerService.error(
        'خطأ في حذف المشروع: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return false;
    }
  }

  // ==================== وظائف إدارة العروض ====================

  /// جلب العروض المقدمة على مشروع معين
  static Future<List<Offer>> getProjectOffers(String projectId) async {
    try {
      dynamic query = client
          .from('offers')
          .select()
          .eq('project_id', projectId);

      // إذا كان المستخدم مسجل الدخول وليس مالك المشروع، فقط اعرض عروضه
      final userRole = await getCurrentUserRole();
      if (isAuthenticated && userRole == 'investor') {
        query = query.eq('investor_id', currentUserId!);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(
        response,
      ).map((data) => Offer.fromMap(data)).toList();
    } catch (e) {
      LoggerService.error(
        'خطأ في جلب عروض المشروع: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return [];
    }
  }

  /// إنشاء عرض جديد
  static Future<Offer?> createOffer(Offer offer) async {
    if (!isAuthenticated) return null;

    try {
      // التأكد من تعيين معرف المستثمر للمستخدم الحالي
      final offerData = offer
          .copyWith(investorId: currentUserId!, createdAt: DateTime.now())
          .toMap();

      final response = await client.from('offers').insert(offerData).select();

      if (response.isNotEmpty) {
        return Offer.fromMap(response.first);
      }
      return null;
    } catch (e) {
      LoggerService.error(
        'خطأ في إنشاء العرض: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return null;
    }
  }

  /// تحديث حالة العرض (قبول/رفض)
  static Future<bool> updateOfferStatus(
    String offerId,
    String newStatus,
  ) async {
    if (!isAuthenticated) return false;

    try {
      await client
          .from('offers')
          .update({'status': newStatus})
          .eq('id', offerId);

      return true;
    } catch (e) {
      LoggerService.error(
        'خطأ في تحديث حالة العرض: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return false;
    }
  }

  // ==================== وظائف إدارة التعليقات ====================

  /// جلب تعليقات مشروع معين
  static Future<List<Comment>> getProjectComments(String projectId) async {
    try {
      final response = await client
          .from('comments')
          .select()
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(
        response,
      ).map((data) => Comment.fromMap(data)).toList();
    } catch (e) {
      LoggerService.error(
        'خطأ في جلب تعليقات المشروع: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return [];
    }
  }

  /// إضافة تعليق جديد
  static Future<Comment?> addComment(String projectId, String content) async {
    if (!isAuthenticated) return null;

    try {
      final commentData = {
        'user_id': currentUserId!,
        'project_id': projectId,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
        'likes': [],
      };

      final response = await client
          .from('comments')
          .insert(commentData)
          .select();

      if (response.isNotEmpty) {
        return Comment.fromMap(response.first);
      }
      return null;
    } catch (e) {
      LoggerService.error(
        'خطأ في إضافة تعليق: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return null;
    }
  }

  /// حذف تعليق
  static Future<bool> deleteComment(String commentId) async {
    if (!isAuthenticated) return false;

    try {
      await client
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', currentUserId!);

      return true;
    } catch (e) {
      LoggerService.error(
        'خطأ في حذف التعليق: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return false;
    }
  }

  /// إضافة إعجاب لتعليق
  static Future<bool> likeComment(String commentId) async {
    if (!isAuthenticated) return false;

    try {
      // جلب التعليق الحالي
      final response = await client
          .from('comments')
          .select('likes')
          .eq('id', commentId)
          .single();

      // تحديث قائمة الإعجابات
      List<String> likes = List<String>.from(response['likes'] ?? []);
      if (!likes.contains(currentUserId!)) {
        likes.add(currentUserId!);

        await client
            .from('comments')
            .update({'likes': likes})
            .eq('id', commentId);
      }

      return true;
    } catch (e) {
      LoggerService.error(
        'خطأ في إضافة إعجاب للتعليق: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return false;
    }
  }

  // ==================== وظائف إدارة الاشتراكات ====================

  /// التحقق من حالة اشتراك المستخدم
  static Future<bool> checkUserSubscription() async {
    if (!isAuthenticated) return false;

    try {
      final response = await client
          .from('subscriptions')
          .select()
          .eq('user_id', currentUserId!)
          .eq('status', 'active')
          .lte('end_date', DateTime.now().toIso8601String())
          .maybeSingle();

      return response != null;
    } catch (e) {
      LoggerService.error(
        'خطأ في التحقق من حالة الاشتراك: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return false;
    }
  }

  /// إنشاء اشتراك جديد
  static Future<bool> createSubscription(
    String plan,
    int durationMonths,
  ) async {
    if (!isAuthenticated) return false;

    try {
      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month + durationMonths, now.day);

      await client.from('subscriptions').insert({
        'user_id': currentUserId!,
        'plan': plan,
        'start_date': now.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': 'active',
      });

      // تحديث حالة المستخدم إلى مشترك
      await client
          .from('profiles')
          .update({'is_premium': true})
          .eq('id', currentUserId!);

      return true;
    } catch (e) {
      LoggerService.error(
        'خطأ في إنشاء اشتراك: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return false;
    }
  }

  /// إلغاء اشتراك
  static Future<bool> cancelSubscription() async {
    if (!isAuthenticated) return false;

    try {
      await client
          .from('subscriptions')
          .update({'status': 'cancelled'})
          .eq('user_id', currentUserId!)
          .eq('status', 'active');

      // تحديث حالة المستخدم إلى غير مشترك
      await client
          .from('profiles')
          .update({'is_premium': false})
          .eq('id', currentUserId!);

      return true;
    } catch (e) {
      LoggerService.error(
        'خطأ في إلغاء الاشتراك: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return false;
    }
  }

  // ==================== وظائف رفع الملفات ====================

  /// رفع صورة إلى تخزين Supabase
  static Future<String?> uploadImage(
    List<int> fileBytes,
    String fileName,
    String folder,
  ) async {
    if (!isAuthenticated) return null;

    try {
      final String path = '$folder/$currentUserId/$fileName';
      await client.storage
          .from('images')
          .uploadBinary(path, Uint8List.fromList(fileBytes));

      // إرجاع رابط الصورة
      final imageUrl = client.storage.from('images').getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      LoggerService.error(
        'خطأ في رفع الصورة: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return null;
    }
  }

  /// حذف صورة من تخزين Supabase
  static Future<bool> deleteImage(String imageUrl) async {
    if (!isAuthenticated) return false;

    try {
      // استخراج المسار من الرابط
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final path = pathSegments.sublist(2).join('/');

      await client.storage.from('images').remove([path]);
      return true;
    } catch (e) {
      LoggerService.error(
        'خطأ في حذف الصورة: $e',
        tag: 'SupabaseService',
        exception: e,
      );
      return false;
    }
  }
}
