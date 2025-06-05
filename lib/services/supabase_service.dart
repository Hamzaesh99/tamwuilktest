import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/project.dart';
import '../models/offer.dart';
import '../models/comment.dart';
import '../models/subscription.dart';
import '../core/services/error_handler.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;
  // ==================== المصادقة ====================

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<AuthResponse> signIn(String email, String password) async {
    final result = await AppErrorHandler.runSafely<AuthResponse>(
      () => supabase.auth.signInWithPassword(email: email, password: password),
      defaultValue: AuthResponse(user: null, session: null),
      errorMessage: 'فشل تسجيل الدخول. يرجى التحقق من بيانات الاعتماد الخاصة بك.',
    );
    // Handle the nullable result from runSafely if necessary,
    // though the defaultValue ensures it's not null here.
    return result!;
  }

  /// تسجيل مستخدم جديد
  Future<void> signUp(String email, String password, String role) async {
    await AppErrorHandler.runSafely<void>(
      () async {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null) {
          final userId = response.user!.id;
          await supabase.from('profiles').insert({
            'id': userId,
            'email': email,
            'user_role': role,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      },
      defaultValue: null,
      errorMessage: 'فشل إنشاء حساب جديد. يرجى المحاولة مرة أخرى.',
    );
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await AppErrorHandler.runSafely<void>(
      () => supabase.auth.signOut(),
      defaultValue: null,
      errorMessage: 'حدث خطأ أثناء تسجيل الخروج.',
    );
  }

  /// الحصول على المستخدم الحالي
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// الحصول على دور المستخدم الحالي
  Future<String?> getCurrentUserRole() async {
    final user = getCurrentUser();
    if (user == null) return null;

    return await AppErrorHandler.runSafely<String?>(
      () async {
        final response = await supabase
            .from('profiles')
            .select('user_role')
            .eq('id', user.id)
            .single();
        return response['user_role'] as String?;
      },
      defaultValue: null,
      errorMessage: 'فشل في الحصول على دور المستخدم.',
    );
  }

  /// الحصول على بيانات المستخدم الحالي
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = getCurrentUser();
    if (user == null) return null;

    return await AppErrorHandler.runSafely<UserProfile?>(
      () async {
        final response = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        // Assuming UserProfile.fromMap exists and is correct
        return UserProfile.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في الحصول على بيانات المستخدم.',
    );
  }

  // ==================== المشاريع ====================

  /// الحصول على جميع المشاريع
  Future<List<Project>> getAllProjects() async {
    final result = await AppErrorHandler.runSafely<List<Project>>(
      () async {
        final response = await supabase
            .from('projects')
            .select()
            .order('created_at', ascending: false);
        return (response as List).map((data) => Project.fromMap(data)).toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على قائمة المشاريع.',
    );
    return result!;
  }

  /// الحصول على مشاريع المستخدم الحالي
  Future<List<Project>> getMyProjects() async {
    final user = getCurrentUser();
    if (user == null) return [];

    final result = await AppErrorHandler.runSafely<List<Project>>(
      () async {
        final response = await supabase
            .from('projects')
            .select()
            .eq('owner_id', user.id)
            .order('created_at', ascending: false);
        return (response as List).map((data) => Project.fromMap(data)).toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على مشاريعك.',
    );
    return result!;
  }

  /// الحصول على مشروع بواسطة المعرف
  Future<Project?> getProjectById(String projectId) async {
    return await AppErrorHandler.runSafely<Project?>(
      () async {
        final response = await supabase
            .from('projects')
            .select()
            .eq('id', projectId)
            .single();
        return Project.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في الحصول على بيانات المشروع.',
    );
  }

  /// إنشاء مشروع جديد
  Future<Project?> createProject(Project project) async {
    final user = getCurrentUser();
    if (user == null) return null;

    // التأكد من أن المستخدم هو مالك المشروع
    project.ownerId = user.id;

    return await AppErrorHandler.runSafely<Project?>(
      () async {
        final response = await supabase
            .from('projects')
            .insert(project.toMap())
            .select()
            .single();
        return Project.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في إنشاء المشروع.',
    );
  }

  /// تحديث مشروع
  Future<Project?> updateProject(Project project) async {
    return await AppErrorHandler.runSafely<Project?>(
      () async {
        final response = await supabase
            .from('projects')
            .update(project.toMap())
            .eq('id', project.id!) // Assuming project.id is nullable String
            .select()
            .single();
        return Project.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في تحديث المشروع.',
    );
  }

  /// حذف مشروع
  Future<bool> deleteProject(String projectId) async {
    final result = await AppErrorHandler.runSafely<bool>(
      () async {
        await supabase.from('projects').delete().eq('id', projectId);
        return true;
      },
      defaultValue: false,
      errorMessage: 'فشل في حذف المشروع.',
    );
    return result!;
  }

  // ==================== العروض ====================

  /// الحصول على عروض مشروع معين
  Future<List<Offer>> getProjectOffers(String projectId) async {
    final result = await AppErrorHandler.runSafely<List<Offer>>(
      () async {
        final response = await supabase
            .from('offers')
            .select()
            .eq('project_id', projectId)
            .order('created_at', ascending: false);
        return (response as List).map((data) => Offer.fromMap(data)).toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على عروض المشروع.',
    );
    return result!;
  }

  /// الحصول على عروض المستخدم الحالي
  Future<List<Offer>> getMyOffers() async {
    final user = getCurrentUser();
    if (user == null) return [];

    final result = await AppErrorHandler.runSafely<List<Offer>>(
      () async {
        final response = await supabase
            .from('offers')
            .select()
            .eq('investor_id', user.id)
            .order('created_at', ascending: false);
        return (response as List).map((data) => Offer.fromMap(data)).toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على عروضك.',
    );
    return result!;
  }

  /// تقديم عرض جديد
  Future<Offer?> submitOffer(Offer offer) async {
    final user = getCurrentUser();
    if (user == null) return null;

    // التأكد من أن المستخدم هو المستثمر
    offer.investorId = user.id;

    return await AppErrorHandler.runSafely<Offer?>(
      () async {
        final response = await supabase
            .from('offers')
            .insert(offer.toMap())
            .select()
            .single();
        return Offer.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في تقديم العرض.',
    );
  }

  /// تحديث حالة عرض
  Future<Offer?> updateOfferStatus(String offerId, String status) async {
    return await AppErrorHandler.runSafely<Offer?>(
      () async {
        final response = await supabase
            .from('offers')
            .update({'status': status})
            .eq('id', offerId)
            .select()
            .single();
        return Offer.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في تحديث حالة العرض.',
    );
  }

  // ==================== التعليقات ====================

  /// الحصول على تعليقات مشروع معين
  Future<List<Comment>> getProjectComments(String projectId) async {
    final result = await AppErrorHandler.runSafely<List<Comment>>(
      () async {
        final response = await supabase
            .from('comments')
            .select()
            .eq('project_id', projectId)
            .order('created_at', ascending: false);
        return (response as List).map((data) => Comment.fromMap(data)).toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على تعليقات التعليقات.',
    );
    return result!;
  }

  /// إضافة تعليق جديد
  Future<Comment?> addComment(Comment comment) async {
    final user = getCurrentUser();
    if (user == null) return null;

    // التأكد من أن المستخدم هو صاحب التعليق
    comment.userId = user.id;

    return await AppErrorHandler.runSafely<Comment?>(
      () async {
        final response = await supabase
            .from('comments')
            .insert(comment.toMap())
            .select()
            .single();
        return Comment.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في إضافة التعليق.',
    );
  }

  /// حذف تعليق
  Future<bool> deleteComment(String commentId) async {
    final result = await AppErrorHandler.runSafely<bool>(
      () async {
        await supabase.from('comments').delete().eq('id', commentId);
        return true;
      },
      defaultValue: false,
      errorMessage: 'فشل في حذف التعليق.',
    );
    return result!;
  }

  // ==================== الاشتراكات ====================

  /// الحصول على اشتراك المستخدم الحالي
  Future<Subscription?> getCurrentUserSubscription() async {
    final user = getCurrentUser();
    if (user == null) return null;

    return await AppErrorHandler.runSafely<Subscription?>(
      () async {
        final response = await supabase
            .from('subscriptions')
            .select()
            .eq('user_id', user.id)
            .eq('status', 'active')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (response == null) return null;
        return Subscription.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في الحصول على بيانات الاشتراك.',
    );
  }

  /// إنشاء اشتراك جديد
  Future<Subscription?> createSubscription(Subscription subscription) async {
    final user = getCurrentUser();
    if (user == null) return null;

    // التأكد من أن المستخدم هو صاحب الاشتراك
    subscription.userId = user.id;

    return await AppErrorHandler.runSafely<Subscription?>(
      () async {
        final response = await supabase
            .from('subscriptions')
            .insert(subscription.toMap())
            .select()
            .single();
        return Subscription.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في إنشاء الاشتراك.',
    );
  }

  /// تحديث حالة اشتراك
  Future<Subscription?> updateSubscriptionStatus(
    String subscriptionId,
    String status,
  ) async {
    return await AppErrorHandler.runSafely<Subscription?>(
      () async {
        final response = await supabase
            .from('subscriptions')
            .update({'status': status})
            .eq('id', subscriptionId)
            .select()
            .single();
        return Subscription.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في تحديث حالة الاشتراك.',
    );
  }
}
