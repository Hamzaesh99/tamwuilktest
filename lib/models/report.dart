import 'dart:convert';

class Report {
  String? id;
  String? userId; // معرف المستخدم الذي قدم التقرير
  String? targetId; // معرف الهدف (مشروع، تعليق، مستخدم، إلخ)
  String? targetType; // نوع الهدف ('project', 'comment', 'user', إلخ)
  String? reason; // سبب التقرير
  String? description; // وصف تفصيلي للتقرير
  String? status; // حالة التقرير ('pending', 'reviewed', 'resolved', 'rejected')
  DateTime? createdAt;
  DateTime? updatedAt;

  Report({
    this.id,
    this.userId,
    this.targetId,
    this.targetType,
    this.reason,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Report copyWith({
    String? id,
    String? userId,
    String? targetId,
    String? targetType,
    String? reason,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'target_id': targetId,
      'target_type': targetType,
      'reason': reason,
      'description': description,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      userId: map['user_id'],
      targetId: map['target_id'],
      targetType: map['target_type'],
      reason: map['reason'],
      description: map['description'],
      status: map['status'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Report.fromJson(String source) => Report.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Report(id: $id, userId: $userId, targetId: $targetId, targetType: $targetType, reason: $reason, description: $description, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}