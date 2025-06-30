import 'dart:convert';

class Rating {
  String? id;
  String? userId;
  String? targetId; // يمكن أن يكون معرف مشروع أو معرف مستخدم
  String? targetType; // نوع الهدف: 'project' أو 'user'
  double? value; // قيمة التقييم (مثلاً من 1 إلى 5)
  String? comment; // تعليق اختياري
  DateTime? createdAt;

  Rating({
    this.id,
    this.userId,
    this.targetId,
    this.targetType,
    this.value,
    this.comment,
    this.createdAt,
  });

  Rating copyWith({
    String? id,
    String? userId,
    String? targetId,
    String? targetType,
    double? value,
    String? comment,
    DateTime? createdAt,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      value: value ?? this.value,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'target_id': targetId,
      'target_type': targetType,
      'value': value,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'],
      userId: map['user_id'],
      targetId: map['target_id'],
      targetType: map['target_type'],
      value: map['value']?.toDouble(),
      comment: map['comment'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Rating.fromJson(String source) => Rating.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Rating(id: $id, userId: $userId, targetId: $targetId, targetType: $targetType, value: $value, comment: $comment, createdAt: $createdAt)';
  }
}