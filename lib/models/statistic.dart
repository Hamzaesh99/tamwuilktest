import 'dart:convert';

class Statistic {
  String? id;
  String? entityId; // معرف الكيان (مشروع، مستخدم، إلخ)
  String? entityType; // نوع الكيان ('project', 'user', إلخ)
  String? metricName; // اسم المقياس (مثل 'views', 'likes', 'offers', إلخ)
  int? count; // العدد أو القيمة
  Map<String, dynamic>? additionalData; // بيانات إضافية (مثل توزيع حسب الوقت)
  DateTime? lastUpdated;

  Statistic({
    this.id,
    this.entityId,
    this.entityType,
    this.metricName,
    this.count,
    this.additionalData,
    this.lastUpdated,
  });

  Statistic copyWith({
    String? id,
    String? entityId,
    String? entityType,
    String? metricName,
    int? count,
    Map<String, dynamic>? additionalData,
    DateTime? lastUpdated,
  }) {
    return Statistic(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      metricName: metricName ?? this.metricName,
      count: count ?? this.count,
      additionalData: additionalData ?? this.additionalData,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_id': entityId,
      'entity_type': entityType,
      'metric_name': metricName,
      'count': count,
      'additional_data': additionalData,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  factory Statistic.fromMap(Map<String, dynamic> map) {
    return Statistic(
      id: map['id'],
      entityId: map['entity_id'],
      entityType: map['entity_type'],
      metricName: map['metric_name'],
      count: map['count']?.toInt(),
      additionalData: map['additional_data'] != null
          ? Map<String, dynamic>.from(map['additional_data'])
          : null,
      lastUpdated: map['last_updated'] != null
          ? DateTime.parse(map['last_updated'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Statistic.fromJson(String source) => Statistic.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Statistic(id: $id, entityId: $entityId, entityType: $entityType, metricName: $metricName, count: $count, additionalData: $additionalData, lastUpdated: $lastUpdated)';
  }

  // طريقة مساعدة لزيادة العدد
  void increment([int amount = 1]) {
    count = (count ?? 0) + amount;
    lastUpdated = DateTime.now();
  }
}