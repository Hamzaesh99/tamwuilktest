import 'dart:convert';

class Offer {
  final String? id;
  String investorId;
  final String projectId;
  final double amount;
  final String? message;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  Offer({
    this.id,
    required this.investorId,
    required this.projectId,
    required this.amount,
    this.message,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'investor_id': investorId,
      'project_id': projectId,
      'amount': amount,
      if (message != null) 'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'],
      investorId: map['investor_id'] ?? '',
      projectId: map['project_id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      message: map['message'],
      status: map['status'] ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Offer.fromJson(String source) => Offer.fromMap(json.decode(source));

  Offer copyWith({
    String? id,
    String? investorId,
    String? projectId,
    double? amount,
    String? message,
    String? status,
    DateTime? createdAt,
  }) {
    return Offer(
      id: id ?? this.id,
      investorId: investorId ?? this.investorId,
      projectId: projectId ?? this.projectId,
      amount: amount ?? this.amount,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Offer(id: $id, investorId: $investorId, projectId: $projectId, amount: $amount, message: $message, status: $status, createdAt: $createdAt)';
  }
}
