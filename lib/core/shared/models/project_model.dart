/// نموذج بيانات المشروع
class Project {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final double fundingGoal;
  final double currentFunding;
  final String status;
  final String ownerId;
  final DateTime createdAt;
  final String city; // المدينة التي يقع فيها المشروع
  final bool singleInvestor; // هل يقبل المشروع مستثمر واحد فقط
  final List<String> investors; // قائمة معرفات المستثمرين في المشروع

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl = '',
    required this.fundingGoal,
    this.currentFunding = 0.0,
    this.status = 'pending',
    required this.ownerId,
    required this.createdAt,
    this.city = '',
    this.singleInvestor = false,
    this.investors = const [],
  });

  // إنشاء نسخة من المشروع مع تحديث بعض الحقول
  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? imageUrl,
    double? fundingGoal,
    double? currentFunding,
    String? status,
    String? ownerId,
    DateTime? createdAt,
    String? city,
    bool? singleInvestor,
    List<String>? investors,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      fundingGoal: fundingGoal ?? this.fundingGoal,
      currentFunding: currentFunding ?? this.currentFunding,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      city: city ?? this.city,
      singleInvestor: singleInvestor ?? this.singleInvestor,
      investors: investors ?? this.investors,
    );
  }

  // إنشاء مشروع من Map مستلم من Firestore
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      fundingGoal: (map['fundingGoal'] ?? 0.0).toDouble(),
      currentFunding: (map['currentFunding'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      ownerId: map['ownerId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      city: map['city'] ?? '',
      singleInvestor: map['singleInvestor'] ?? false,
      investors: List<String>.from(map['investors'] ?? []),
    );
  }

  // تحويل المشروع إلى Map لتخزينه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'fundingGoal': fundingGoal,
      'currentFunding': currentFunding,
      'status': status,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'city': city,
      'singleInvestor': singleInvestor,
      'investors': investors,
    };
  }

  // حساب نسبة التمويل الحالي
  double get fundingPercentage => (currentFunding / fundingGoal) * 100;

  // التحقق مما إذا كان المشروع قد وصل إلى هدف التمويل
  bool get isFunded => currentFunding >= fundingGoal;
}
