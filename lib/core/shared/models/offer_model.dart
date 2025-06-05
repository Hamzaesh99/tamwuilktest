/// نموذج بيانات العروض المقدمة على المشاريع
class Offer {
  final String id;
  final String investorId;
  final String projectId;
  final double amount;
  final String message;
  final String status;
  final DateTime createdAt;

  Offer({
    required this.id,
    required this.investorId,
    required this.projectId,
    required this.amount,
    this.message = '',
    this.status = 'pending',
    required this.createdAt,
  });

  // إنشاء نسخة من العرض مع تحديث بعض الحقول
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

  // تحويل العرض إلى Map لتخزينه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'investorId': investorId,
      'projectId': projectId,
      'amount': amount,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // إنشاء عرض من Map مستلم من Firestore
  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'] ?? '',
      investorId: map['investorId'] ?? '',
      projectId: map['projectId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      message: map['message'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

/// حالات العرض المقدم على المشروع
enum OfferStatus {
  pending, // معلق
  accepted, // مقبول
  rejected, // مرفوض
}
