/// نموذج بيانات المستخدم
class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final bool isPremium;
  final List<String> favoriteProjects;
  final List<String> investedProjects;
  final DateTime createdAt;
  final Map<String, dynamic> settings;
  final String
      accountType; // حقل جديد لنوع الحساب (investor, project_owner, guest)
  final String
      userRole; // حقل لدور المستخدم (investor, entrepreneur, guest, etc.)

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.isPremium = false,
    this.favoriteProjects = const [],
    this.investedProjects = const [],
    required this.createdAt,
    this.settings = const {},
    this.accountType =
        'investor', // قيمة افتراضية (investor, project_owner, guest)
    this.userRole = 'investor', // قيمة افتراضية لدور المستخدم
  });

  // إنشاء نسخة من المستخدم مع تحديث بعض الحقول
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    bool? isPremium,
    List<String>? favoriteProjects,
    List<String>? investedProjects,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
    String? accountType,
    String? userRole,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
      favoriteProjects: favoriteProjects ?? this.favoriteProjects,
      investedProjects: investedProjects ?? this.investedProjects,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
      accountType: accountType ?? this.accountType,
      userRole: userRole ?? this.userRole,
    );
  }

  // تحويل المستخدم إلى Map لتخزينه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'isPremium': isPremium,
      'favoriteProjects': favoriteProjects,
      'investedProjects': investedProjects,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'settings': settings,
      'accountType': accountType, // إضافة نوع الحساب إلى الخريطة
    };
  }

  // إنشاء مستخدم من Map مستلم من Firestore
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      isPremium: map['isPremium'] ?? false,
      favoriteProjects: List<String>.from(map['favoriteProjects'] ?? []),
      investedProjects: List<String>.from(map['investedProjects'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      accountType:
          map['accountType'] ?? 'investor', // قراءة نوع الحساب من الخريطة
    );
  }
}
