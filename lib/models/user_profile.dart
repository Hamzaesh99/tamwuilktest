import 'dart:convert';

class UserProfile {
  final String id;
  final String userId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? bio;
  final String? city;
  final String role;
  final DateTime createdAt;
  final List<String> interests;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.id,
    required this.userId,
    this.name,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.bio,
    this.city,
    required this.role,
    DateTime? createdAt,
    List<String>? interests,
    this.preferences,
  }) : createdAt = createdAt ?? DateTime.now(),
       interests = interests ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'bio': bio,
      'city': city,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'interests': interests,
      'preferences': preferences,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phone_number'],
      avatarUrl: map['avatar_url'],
      bio: map['bio'],
      city: map['city'],
      role: map['role'] ?? 'user',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      interests: List<String>.from(map['interests'] ?? []),
      preferences: map['preferences'],
    );
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? bio,
    String? city,
    String? role,
    DateTime? createdAt,
    List<String>? interests,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserProfile(id: $id, userId: $userId, name: $name, email: $email, '
        'phoneNumber: $phoneNumber, avatarUrl: $avatarUrl, bio: $bio, '
        'city: $city, role: $role, createdAt: $createdAt, '
        'interests: $interests, preferences: $preferences)';
  }
}
