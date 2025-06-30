import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/project.dart';
import '../models/offer.dart';
import '../models/comment.dart';
import '../models/subscription.dart';
import '../models/rating.dart';
import '../models/report.dart';
import '../models/statistic.dart';
import '../core/services/error_handler.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;
  // ==================== المصادقة ====================

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<AuthResponse> signIn(String email, String password) async {
    final result = await AppErrorHandler.runSafely<AuthResponse>(
      () => supabase.auth.signInWithPassword(email: email, password: password),
      defaultValue: AuthResponse(user: null, session: null),
      errorMessage:
          'فشل تسجيل الدخول. يرجى التحقق من بيانات الاعتماد الخاصة بك.',
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

  // ==================== التقييمات ====================

  /// الحصول على تقييمات مشروع معين
  Future<List<Rating>> getProjectRatings(String projectId) async {
    final result = await AppErrorHandler.runSafely<List<Rating>>(
      () async {
        final response = await supabase
            .from('ratings')
            .select()
            .eq('target_id', projectId)
            .eq('target_type', 'project')
            .order('created_at', ascending: false);
        return (response as List).map((data) => Rating.fromMap(data)).toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على تقييمات المشروع.',
    );
    return result!;
  }

  /// الحصول على تقييمات مستخدم معين
  Future<List<Rating>> getUserRatings(String userId) async {
    final result = await AppErrorHandler.runSafely<List<Rating>>(
      () async {
        final response = await supabase
            .from('ratings')
            .select()
            .eq('target_id', userId)
            .eq('target_type', 'user')
            .order('created_at', ascending: false);
        return (response as List).map((data) => Rating.fromMap(data)).toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على تقييمات المستخدم.',
    );
    return result!;
  }

  /// إضافة تقييم جديد
  Future<Rating?> addRating(Rating rating) async {
    final user = getCurrentUser();
    if (user == null) return null;

    // التأكد من أن المستخدم هو صاحب التقييم
    rating.userId = user.id;
    rating.createdAt = DateTime.now();

    return await AppErrorHandler.runSafely<Rating?>(
      () async {
        // التحقق مما إذا كان المستخدم قد قام بالتقييم مسبقاً
        final existingRating = await supabase
            .from('ratings')
            .select()
            .eq('user_id', user.id)
            .eq('target_id', rating.targetId as Object)
            .eq('target_type', rating.targetType as Object)
            .maybeSingle();

        if (existingRating != null) {
          // تحديث التقييم الموجود
          final response = await supabase
              .from('ratings')
              .update({
                'value': rating.value,
                'comment': rating.comment,
                'created_at': rating.createdAt?.toIso8601String(),
              })
              .eq('id', existingRating['id'])
              .select()
              .single();
          return Rating.fromMap(response);
        } else {
          // إنشاء تقييم جديد
          final response = await supabase
              .from('ratings')
              .insert(rating.toMap())
              .select()
              .single();
          return Rating.fromMap(response);
        }
      },
      defaultValue: null,
      errorMessage: 'فشل في إضافة التقييم.',
    );
  }

  /// حذف تقييم
  Future<bool> deleteRating(String ratingId) async {
    final result = await AppErrorHandler.runSafely<bool>(
      () async {
        await supabase.from('ratings').delete().eq('id', ratingId);
        return true;
      },
      defaultValue: false,
      errorMessage: 'فشل في حذف التقييم.',
    );
    return result!;
  }

  /// حساب متوسط التقييم لكيان معين (مشروع أو مستخدم)
  Future<double> getAverageRating(String targetId, String targetType) async {
    final result = await AppErrorHandler.runSafely<double>(
      () async {
        final response = await supabase
            .from('ratings')
            .select('value')
            .eq('target_id', targetId)
            .eq('target_type', targetType);

        if ((response as List).isEmpty) return 0.0;

        double sum = 0.0;
        for (var item in response) {
          sum += (item['value'] as num).toDouble();
        }
        return sum / response.length;
      },
      defaultValue: 0.0,
      errorMessage: 'فشل في حساب متوسط التقييم.',
    );
    return result!;
  }

  // ==================== التقارير ====================

  /// الحصول على جميع التقارير
  Future<List<Report>> getAllReports() async {
    final result = await AppErrorHandler.runSafely<List<Report>>(
      () async {
        final response = await supabase
            .from('reports')
            .select()
            .order('created_at', ascending: false);
        return (response as List).map((data) => Report.fromMap(data)).toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على التقارير.',
    );
    return result!;
  }

  /// الحصول على تقارير كيان معين (مشروع أو مستخدم أو تعليق)
  Future<List<Report>> getEntityReports(
    String targetId,
    String targetType,
  ) async {
    final result = await AppErrorHandler.runSafely<List<Report>>(
      () async {
        final response = await supabase
            .from('reports')
            .select()
            .eq('target_id', targetId)
            .eq('target_type', targetType)
            .order('created_at', ascending: false);
        return (response as List).map((data) => Report.fromMap(data)).toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على تقارير الكيان.',
    );
    return result!;
  }

  /// إنشاء تقرير جديد
  Future<Report?> createReport(Report report) async {
    final user = getCurrentUser();
    if (user == null) return null;

    // التأكد من أن المستخدم هو صاحب التقرير
    report.userId = user.id;
    report.createdAt = DateTime.now();
    report.status = 'pending'; // حالة التقرير الافتراضية: قيد الانتظار

    return await AppErrorHandler.runSafely<Report?>(
      () async {
        final response = await supabase
            .from('reports')
            .insert(report.toMap())
            .select()
            .single();
        return Report.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في إنشاء التقرير.',
    );
  }

  /// تحديث حالة تقرير
  Future<Report?> updateReportStatus(String reportId, String status) async {
    return await AppErrorHandler.runSafely<Report?>(
      () async {
        final response = await supabase
            .from('reports')
            .update({
              'status': status,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', reportId)
            .select()
            .single();
        return Report.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في تحديث حالة التقرير.',
    );
  }

  // ==================== الإحصائيات ====================

  /// الحصول على إحصائية معينة
  Future<Statistic?> getStatistic(
    String entityId,
    String entityType,
    String metricName,
  ) async {
    return await AppErrorHandler.runSafely<Statistic?>(
      () async {
        final response = await supabase
            .from('statistics')
            .select()
            .eq('entity_id', entityId)
            .eq('entity_type', entityType)
            .eq('metric_name', metricName)
            .maybeSingle();

        if (response == null) return null;
        return Statistic.fromMap(response);
      },
      defaultValue: null,
      errorMessage: 'فشل في الحصول على الإحصائية.',
    );
  }

  /// الحصول على جميع إحصائيات كيان معين
  Future<List<Statistic>> getEntityStatistics(
    String entityId,
    String entityType,
  ) async {
    final result = await AppErrorHandler.runSafely<List<Statistic>>(
      () async {
        final response = await supabase
            .from('statistics')
            .select()
            .eq('entity_id', entityId)
            .eq('entity_type', entityType);
        return (response as List)
            .map((data) => Statistic.fromMap(data))
            .toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على إحصائيات الكيان.',
    );
    return result!;
  }

  /// زيادة قيمة إحصائية معينة
  Future<Statistic?> incrementStatistic(
    String entityId,
    String entityType,
    String metricName, {
    int incrementBy = 1,
    Map<String, dynamic>? additionalData,
  }) async {
    return await AppErrorHandler.runSafely<Statistic?>(
      () async {
        // التحقق مما إذا كانت الإحصائية موجودة بالفعل
        final existingStat = await supabase
            .from('statistics')
            .select()
            .eq('entity_id', entityId)
            .eq('entity_type', entityType)
            .eq('metric_name', metricName)
            .maybeSingle();

        if (existingStat != null) {
          // تحديث الإحصائية الموجودة
          final currentCount = (existingStat['count'] as num).toInt();
          final updatedData = additionalData ?? existingStat['additional_data'];

          final response = await supabase
              .from('statistics')
              .update({
                'count': currentCount + incrementBy,
                'additional_data': updatedData,
                'last_updated': DateTime.now().toIso8601String(),
              })
              .eq('id', existingStat['id'])
              .select()
              .single();
          return Statistic.fromMap(response);
        } else {
          // إنشاء إحصائية جديدة
          final newStat = Statistic(
            entityId: entityId,
            entityType: entityType,
            metricName: metricName,
            count: incrementBy,
            additionalData: additionalData,
            lastUpdated: DateTime.now(),
          );

          final response = await supabase
              .from('statistics')
              .insert(newStat.toMap())
              .select()
              .single();
          return Statistic.fromMap(response);
        }
      },
      defaultValue: null,
      errorMessage: 'فشل في زيادة قيمة الإحصائية.',
    );
  }

  /// تعيين قيمة إحصائية معينة
  Future<Statistic?> setStatistic(
    String entityId,
    String entityType,
    String metricName,
    int count, {
    Map<String, dynamic>? additionalData,
  }) async {
    return await AppErrorHandler.runSafely<Statistic?>(
      () async {
        // التحقق مما إذا كانت الإحصائية موجودة بالفعل
        final existingStat = await supabase
            .from('statistics')
            .select()
            .eq('entity_id', entityId)
            .eq('entity_type', entityType)
            .eq('metric_name', metricName)
            .maybeSingle();

        if (existingStat != null) {
          // تحديث الإحصائية الموجودة
          final response = await supabase
              .from('statistics')
              .update({
                'count': count,
                'additional_data':
                    additionalData ?? existingStat['additional_data'],
                'last_updated': DateTime.now().toIso8601String(),
              })
              .eq('id', existingStat['id'])
              .select()
              .single();
          return Statistic.fromMap(response);
        } else {
          // إنشاء إحصائية جديدة
          final newStat = Statistic(
            entityId: entityId,
            entityType: entityType,
            metricName: metricName,
            count: count,
            additionalData: additionalData,
            lastUpdated: DateTime.now(),
          );

          final response = await supabase
              .from('statistics')
              .insert(newStat.toMap())
              .select()
              .single();
          return Statistic.fromMap(response);
        }
      },
      defaultValue: null,
      errorMessage: 'فشل في تعيين قيمة الإحصائية.',
    );
  }

  // ==================== البحث المتقدم والتصفية والفرز ====================

  /// بحث متقدم في المشاريع
  Future<List<Project>> searchProjects({
    String? searchQuery,
    List<String>? categories,
    double? minFundingAmount,
    double? maxFundingAmount,
    String? status,
    String? sortBy,
    bool ascending = false,
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await AppErrorHandler.runSafely<List<Project>>(
      () async {
        var query = supabase.from('projects').select();

        // تطبيق البحث النصي إذا تم توفيره
        if (searchQuery != null && searchQuery.isNotEmpty) {
          query = query.or(
            'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%',
          );
        }

        // تطبيق تصفية الفئات إذا تم توفيرها
        if (categories != null && categories.isNotEmpty) {
          // استخدام containedBy للبحث في مصفوفة الفئات
          query = query.containedBy('categories', categories);
        }

        // تطبيق تصفية مبلغ التمويل إذا تم توفيره
        if (minFundingAmount != null) {
          query = query.gte('funding_amount', minFundingAmount);
        }
        if (maxFundingAmount != null) {
          query = query.lte('funding_amount', maxFundingAmount);
        }

        // تطبيق تصفية الحالة إذا تم توفيرها
        if (status != null && status.isNotEmpty) {
          query = query.eq('status', status);
        }

        // تطبيق الفرز إذا تم توفيره
        if (sortBy != null && sortBy.isNotEmpty) {
          PostgrestFilterBuilder<PostgrestList> sortedQuery =
              query.order(sortBy, ascending: ascending)
                  as PostgrestFilterBuilder<PostgrestList>;
          query = sortedQuery;
        } else {
          // الفرز الافتراضي حسب تاريخ الإنشاء
          PostgrestFilterBuilder<PostgrestList> sortedQuery =
              query.order('created_at', ascending: false)
                  as PostgrestFilterBuilder<PostgrestList>;
          query = sortedQuery;
        }

        // تطبيق الحد والإزاحة للصفحات
        PostgrestFilterBuilder<PostgrestList> rangedQuery =
            query.range(offset, offset + limit - 1)
                as PostgrestFilterBuilder<PostgrestList>;
        query = rangedQuery;

        final response = await query;
        return (response as List).map((data) => Project.fromMap(data)).toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في البحث عن المشاريع.',
    );
    return result!;
  }

  /// بحث متقدم في المستخدمين
  Future<List<UserProfile>> searchUsers({
    String? searchQuery,
    List<String>? roles,
    String? sortBy,
    bool ascending = false,
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await AppErrorHandler.runSafely<List<UserProfile>>(
      () async {
        dynamic query = supabase.from('profiles').select();

        // تطبيق البحث النصي إذا تم توفيره
        if (searchQuery != null && searchQuery.isNotEmpty) {
          query = query.or(
            'full_name.ilike.%$searchQuery%,bio.ilike.%$searchQuery%',
          );
        }

        // تطبيق تصفية الأدوار إذا تم توفيرها
        if (roles != null && roles.isNotEmpty) {
          query = query.in_('role', roles);
        }

        // تطبيق الفرز إذا تم توفيره
        if (sortBy != null && sortBy.isNotEmpty) {
          query = query.order(sortBy, ascending: ascending);
        } else {
          // الفرز الافتراضي حسب تاريخ الإنشاء
          query = query.order('created_at', ascending: false);
        }

        // تطبيق الحد والإزاحة للصفحات
        query = query.range(offset, offset + limit - 1);

        final response = await query;
        return (response as List)
            .map((data) => UserProfile.fromMap(data))
            .toList();
      },
      defaultValue: [],
      errorMessage: 'فشل في البحث عن المستخدمين.',
    );
    return result!;
  }

  /// الحصول على عدد نتائج البحث في المشاريع
  Future<int> getProjectsSearchCount({
    String? searchQuery,
    List<String>? categories,
    double? minFundingAmount,
    double? maxFundingAmount,
    String? status,
  }) async {
    final result = await AppErrorHandler.runSafely<int>(
      () async {
        var query = supabase.from('projects').select('id');

        // تطبيق البحث النصي إذا تم توفيره
        if (searchQuery != null && searchQuery.isNotEmpty) {
          query = query.or(
            'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%',
          );
        }

        // تطبيق تصفية الفئات إذا تم توفيرها
        if (categories != null && categories.isNotEmpty) {
          query = query.containedBy('categories', categories);
        }

        // تطبيق تصفية مبلغ التمويل إذا تم توفيره
        if (minFundingAmount != null) {
          query = query.gte('funding_amount', minFundingAmount);
        }
        if (maxFundingAmount != null) {
          query = query.lte('funding_amount', maxFundingAmount);
        }

        // تطبيق تصفية الحالة إذا تم توفيرها
        if (status != null && status.isNotEmpty) {
          query = query.eq('status', status);
        }

        final count = await query.count();
        return (count as Map<String, dynamic>)['count'] as int;
      },
      defaultValue: 0,
      errorMessage: 'فشل في الحصول على عدد نتائج البحث في المشاريع.',
    );
    return result!;
  }

  /// الحصول على عدد نتائج البحث في المستخدمين
  Future<int> getUsersSearchCount({
    String? searchQuery,
    List<String>? roles,
  }) async {
    final result = await AppErrorHandler.runSafely<int>(
      () async {
        var query = supabase.from('profiles').select('id');

        // تطبيق البحث النصي إذا تم توفيره
        if (searchQuery != null && searchQuery.isNotEmpty) {
          query = query.or(
            'full_name.ilike.%$searchQuery%,bio.ilike.%$searchQuery%',
          );
        }

        // تطبيق تصفية الأدوار إذا تم توفيرها
        if (roles != null && roles.isNotEmpty) {
          query = query.inFilter('role', roles as List<Object>);
        }

        final response = await query.count();
        return (response as Map<String, dynamic>)['count'] as int;
      },
      defaultValue: 0,
      errorMessage: 'فشل في الحصول على عدد نتائج البحث في المستخدمين.',
    );
    return result!;
  }

  // ==================== إدارة الملفات ====================

  /// رفع ملف إلى تخزين Supabase
  Future<String?> uploadFile({
    required String bucketName,
    required String filePath,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    final result = await AppErrorHandler.runSafely<String?>(
      () async {
        final user = getCurrentUser();
        if (user == null) return null;

        // إنشاء اسم ملف فريد باستخدام معرف المستخدم والطابع الزمني
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileExt = filePath.split('.').last;
        final uniqueFilePath = '${user.id}_$timestamp.$fileExt';

        // رفع الملف إلى تخزين Supabase
        final response = await supabase.storage
            .from(bucketName)
            .uploadBinary(
              uniqueFilePath,
              fileBytes,
              fileOptions: FileOptions(contentType: contentType, upsert: true),
            );

        // إرجاع رابط الملف
        if (response.isNotEmpty) {
          final fileUrl = supabase.storage
              .from(bucketName)
              .getPublicUrl(uniqueFilePath);
          return fileUrl;
        }
        return null;
      },
      defaultValue: null,
      errorMessage: 'فشل في رفع الملف.',
    );
    return result;
  }

  /// حذف ملف من تخزين Supabase
  Future<bool> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    final result = await AppErrorHandler.runSafely<bool>(
      () async {
        await supabase.storage.from(bucketName).remove([filePath]);
        return true;
      },
      defaultValue: false,
      errorMessage: 'فشل في حذف الملف.',
    );
    return result!;
  }

  /// الحصول على قائمة الملفات في مجلد معين
  Future<List<FileObject>> listFiles({
    required String bucketName,
    String? folderPath,
  }) async {
    final result = await AppErrorHandler.runSafely<List<FileObject>>(
      () async {
        final response = await supabase.storage
            .from(bucketName)
            .list(path: folderPath);
        return response;
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على قائمة الملفات.',
    );
    return result!;
  }

  /// إنشاء رابط مؤقت للملف (صالح لفترة محددة)
  Future<String?> createSignedUrl({
    required String bucketName,
    required String filePath,
    required int expiresIn, // بالثواني
  }) async {
    final result = await AppErrorHandler.runSafely<String?>(
      () async {
        final response = await supabase.storage
            .from(bucketName)
            .createSignedUrl(filePath, expiresIn);
        return response;
      },
      defaultValue: null,
      errorMessage: 'فشل في إنشاء رابط مؤقت للملف.',
    );
    return result;
  }

  /// تحميل ملف من تخزين Supabase
  Future<Uint8List?> downloadFile({
    required String bucketName,
    required String filePath,
  }) async {
    final result = await AppErrorHandler.runSafely<Uint8List?>(
      () async {
        final response = await supabase.storage
            .from(bucketName)
            .download(filePath);
        return response;
      },
      defaultValue: null,
      errorMessage: 'فشل في تحميل الملف.',
    );
    return result;
  }

  // ==================== تتبع نشاط المستخدم ====================

  /// تسجيل نشاط المستخدم
  Future<void> logUserActivity({
    required String activityType,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? additionalData,
  }) async {
    final user = getCurrentUser();
    if (user == null) return;

    await AppErrorHandler.runSafely<void>(
      () async {
        await supabase.from('user_activities').insert({
          'user_id': user.id,
          'activity_type': activityType,
          'target_id': targetId,
          'target_type': targetType,
          'additional_data': additionalData,
          'created_at': DateTime.now().toIso8601String(),
        });
      },
      defaultValue: null,
      errorMessage: 'فشل في تسجيل نشاط المستخدم.',
    );
  }

  /// الحصول على أنشطة المستخدم
  Future<List<Map<String, dynamic>>> getUserActivities({
    String? userId,
    String? activityType,
    String? targetId,
    String? targetType,
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await AppErrorHandler.runSafely<List<Map<String, dynamic>>>(
      () async {
        dynamic query = supabase.from('user_activities').select();

        // تطبيق تصفية معرف المستخدم إذا تم توفيره
        if (userId != null && userId.isNotEmpty) {
          query = query.eq('user_id', userId);
        } else {
          // إذا لم يتم توفير معرف المستخدم، استخدم المستخدم الحالي
          final currentUser = getCurrentUser();
          if (currentUser != null) {
            query = query.eq('user_id', currentUser.id);
          }
        }

        // تطبيق تصفية نوع النشاط إذا تم توفيره
        if (activityType != null && activityType.isNotEmpty) {
          query = query.eq('activity_type', activityType);
        }

        // تطبيق تصفية معرف الهدف إذا تم توفيره
        if (targetId != null && targetId.isNotEmpty) {
          query = query.eq('target_id', targetId);
        }

        // تطبيق تصفية نوع الهدف إذا تم توفيره
        if (targetType != null && targetType.isNotEmpty) {
          query = query.eq('target_type', targetType);
        }

        // ترتيب النتائج حسب تاريخ الإنشاء (الأحدث أولاً)
        query = query.order('created_at', ascending: false);

        // تطبيق الحد والإزاحة للصفحات
        query = query.range(offset, offset + limit - 1);

        final response = await query;
        return (response as List).cast<Map<String, dynamic>>();
      },
      defaultValue: [],
      errorMessage: 'فشل في الحصول على أنشطة المستخدم.',
    );
    return result!;
  }
}
