import 'dart:convert';

class Project {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String? imageUrl;
  final double fundingGoal;
  final double currentFunding;
  final String status; // pending, active, funded, completed
  String ownerId;
  final DateTime createdAt;
  final String city;
  final bool singleInvestor;
  final List<String>? investors;

  Project({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.fundingGoal,
    this.currentFunding = 0.0,
    this.status = 'pending',
    required this.ownerId,
    DateTime? createdAt,
    required this.city,
    this.singleInvestor = false,
    this.investors,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'category': category,
      if (imageUrl != null) 'image_url': imageUrl,
      'funding_goal': fundingGoal,
      'current_funding': currentFunding,
      'status': status,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'city': city,
      'single_investor': singleInvestor,
      if (investors != null) 'investors': investors,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['image_url'],
      fundingGoal: (map['funding_goal'] ?? 0.0).toDouble(),
      currentFunding: (map['current_funding'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      ownerId: map['owner_id'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      city: map['city'] ?? '',
      singleInvestor: map['single_investor'] ?? false,
      investors: map['investors'] != null
          ? List<String>.from(map['investors'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Project.fromJson(String source) =>
      Project.fromMap(json.decode(source));

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

  @override
  String toString() {
    return 'Project(id: $id, title: $title, description: $description, category: $category, imageUrl: $imageUrl, fundingGoal: $fundingGoal, currentFunding: $currentFunding, status: $status, ownerId: $ownerId, createdAt: $createdAt, city: $city, singleInvestor: $singleInvestor, investors: $investors)';
  }
}
