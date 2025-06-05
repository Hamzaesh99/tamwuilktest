import 'dart:convert';

class Subscription {
  final String? id;
  String userId;
  final String plan;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // active, cancelled

  Subscription({
    this.id,
    required this.userId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'plan': plan,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      userId: map['user_id'] ?? '',
      plan: map['plan'] ?? '',
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'])
          : DateTime.now(),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'])
          : DateTime.now().add(Duration(days: 30)),
      status: map['status'] ?? 'active',
    );
  }

  String toJson() => json.encode(toMap());

  factory Subscription.fromJson(String source) =>
      Subscription.fromMap(json.decode(source));

  Subscription copyWith({
    String? id,
    String? userId,
    String? plan,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Subscription(id: $id, userId: $userId, plan: $plan, startDate: $startDate, endDate: $endDate, status: $status)';
  }

  /// التحقق مما إذا كان الاشتراك نشطًا حاليًا
  bool get isActive {
    final now = DateTime.now();
    return status == 'active' &&
        now.isAfter(startDate) &&
        now.isBefore(endDate);
  }

  /// حساب عدد الأيام المتبقية في الاشتراك
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}
