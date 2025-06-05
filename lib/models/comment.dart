import 'dart:convert';

class Comment {
  final String? id;
  String userId;
  final String projectId;
  final String content;
  final DateTime createdAt;
  final List<String>? likes;

  Comment({
    this.id,
    required this.userId,
    required this.projectId,
    required this.content,
    DateTime? createdAt,
    this.likes,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'project_id': projectId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      if (likes != null) 'likes': likes,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      userId: map['user_id'] ?? '',
      projectId: map['project_id'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      likes: map['likes'] != null ? List<String>.from(map['likes']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source));

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

  @override
  String toString() {
    return 'Comment(id: $id, userId: $userId, projectId: $projectId, content: $content, createdAt: $createdAt, likes: $likes)';
  }
}
