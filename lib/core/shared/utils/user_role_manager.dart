import 'package:flutter/material.dart';
import 'package:tamwuilktest/core/shared/models/user_model.dart' as user_model;

/// مدير أدوار المستخدمين
/// يستخدم للتحقق من صلاحيات المستخدم بناءً على نوع حسابه
class UserRoleManager {
  /// التحقق مما إذا كان المستخدم زائراً
  static bool isGuest(user_model.User? user) {
    return user == null;
  }

  /// التحقق مما إذا كان المستخدم مستثمرًا
  static bool isInvestor(user_model.User? user) {
    if (user == null) return false;
    return user.userRole == 'investor';
  }

  /// التحقق مما إذا كان المستخدم صاحب مشروع
  static bool isProjectOwner(user_model.User? user) {
    return user?.accountType == 'project_owner';
  }

  /// التحقق من صلاحية المستخدم للوصول إلى ميزة معينة
  /// يمكن استخدامها للتحقق من الصلاحيات في أي مكان في التطبيق
  static bool canAccessFeature(
    BuildContext context,
    user_model.User? user,
    String feature,
  ) {
    // الميزات المتاحة للزوار
    if (feature == 'view_projects' || feature == 'browse_content') {
      return true;
    }

    // إذا كان المستخدم زائراً، عرض رسالة تسجيل الدخول
    if (isGuest(user)) {
      showGuestActionDialog(context);
      return false;
    }

    switch (feature) {
      case 'create_project':
        return isInvestor(user);
      case 'make_offer':
        return isProjectOwner(user);
      case 'view_offers':
      case 'view_products':
        return isInvestor(user);
      case 'chat':
      case 'comment':
        return !isGuest(user);
      default:
        return true;
    }
  }

  /// عرض رسالة خطأ عند عدم توفر الصلاحية
  static void showAccessDeniedMessage(BuildContext context, String feature) {
    String message = 'عذراً، ليس لديك صلاحية للوصول إلى هذه الميزة';

    switch (feature) {
      case 'create_project':
        message = 'عذراً، فقط المستثمرون يمكنهم إنشاء مشاريع';
        break;
      case 'make_offer':
        message = 'عذراً، فقط أصحاب المشاريع يمكنهم تقديم العروض';
        break;
      case 'view_offers':
      case 'view_products':
        message = 'عذراً، فقط المستثمرون يمكنهم الوصول إلى هذه الميزة';
        break;
      case 'chat':
      case 'comment':
        message = 'عذراً، يجب تسجيل الدخول للوصول إلى هذه الميزة';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// عرض نافذة حوار للزوار
  static void showGuestActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنبيه'),
        content: const Text(
          'هذه الميزة متاحة فقط للمستخدمين المسجلين. الرجاء تسجيل الدخول أو إنشاء حساب جديد للاستفادة من جميع مميزات التطبيق.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  /// Verifica si un usuario es un emprendedor
  static bool isEntrepreneur(user_model.User? user) {
    if (user == null) return false;
    return user.userRole == 'entrepreneur';
  }

  /// Verifica si un usuario es un administrador
  static bool isAdmin(user_model.User? user) {
    if (user == null) return false;
    return user.userRole == 'admin';
  }

  /// Verifica si un usuario tiene permisos para ver proyectos
  static bool canViewProjects(user_model.User? user) {
    return user != null; // Cualquier usuario registrado puede ver proyectos
  }

  /// Verifica si un usuario tiene permisos para crear proyectos
  static bool canCreateProjects(user_model.User? user) {
    if (user == null) return false;
    return isEntrepreneur(user) || isAdmin(user);
  }

  /// Verifica si un usuario tiene permisos para invertir en proyectos
  static bool canInvest(user_model.User? user) {
    if (user == null) return false;
    return user.userRole == 'investor' || user.userRole == 'entrepreneur';
  }

  /// Verifica si un usuario tiene permisos para administrar todos los proyectos
  static bool canManageAllProjects(user_model.User? user) {
    if (user == null) return false;
    return isAdmin(user);
  }

  /// Verifica si un usuario puede editar un proyecto específico
  static bool canEditProject(user_model.User? user, String projectOwnerId) {
    if (user == null) return false;
    return user.id == projectOwnerId || isAdmin(user);
  }

  /// Verifica si un usuario puede crear un proyecto
  static bool canCreateProject(user_model.User? user) {
    if (user == null) return false;
    return user.userRole == 'entrepreneur';
  }

  /// Verifica si un usuario puede administrar proyectos
  static bool canManageProjects(user_model.User? user) {
    if (user == null) return false;
    return user.userRole == 'entrepreneur' || user.userRole == 'admin';
  }
}
