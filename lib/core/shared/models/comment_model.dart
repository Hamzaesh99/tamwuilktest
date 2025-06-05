/// نموذج بيانات التعليقات على المشاريع
class Comment {
  final String id;
  final String userId;
  final String projectId;
  final String content;
  final DateTime createdAt;
  final List<String> likes; // قائمة معرفات المستخدمين الذين أعجبوا بالتعليق

  const Comment({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.content,
    required this.createdAt,
    this.likes = const [],
  });

  // إنشاء نسخة من التعليق مع تحديث بعض الحقول
  Comment copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? content,
    DateTime? createdAt,
    List<String>? likes,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
    );
  }

  // تحويل التعليق إلى Map لتخزينه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'projectId': projectId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }

  // إنشاء تعليق من Map مستلم من Firestore
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      projectId: map['projectId'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      likes: List<String>.from(map['likes'] ?? []),
    );
  }
}
