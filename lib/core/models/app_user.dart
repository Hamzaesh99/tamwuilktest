/// نموذج المستخدم في التطبيق
class AppUser {
  final String id;
  final String email;
  final String? userRole;

  AppUser({required this.id, required this.email, this.userRole});

  /// إنشاء مستخدم من بيانات Supabase
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      userRole: map['user_role'] as String?,
    );
  }

  /// تحويل المستخدم إلى Map لتخزينه في Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      if (userRole != null) 'user_role': userRole,
    };
  }

  /// نسخ المستخدم مع تحديث بعض الخصائص
  AppUser copyWith({String? id, String? email, String? userRole}) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      userRole: userRole ?? this.userRole,
    );
  }
}
