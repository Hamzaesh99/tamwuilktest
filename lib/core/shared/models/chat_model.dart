/// نموذج بيانات المحادثات بين المستخدمين
class Chat {
  final String id;
  final List<String> participants; // معرفات المستخدمين المشاركين في المحادثة
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<Message> messages; // الرسائل في المحادثة

  const Chat({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.lastMessageAt,
    this.messages = const [],
  });

  // إنشاء نسخة من المحادثة مع تحديث بعض الحقول
  Chat copyWith({
    String? id,
    List<String>? participants,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<Message>? messages,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
    );
  }

  // تحويل المحادثة إلى Map لتخزينها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastMessageAt': lastMessageAt.millisecondsSinceEpoch,
      // لا نخزن الرسائل هنا، بل في مجموعة فرعية منفصلة
    };
  }

  // إنشاء محادثة من Map مستلم من Firestore
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(map['lastMessageAt']),
      messages: [], // الرسائل تُحمل بشكل منفصل
    );
  }
}

/// نموذج بيانات الرسائل في المحادثة
class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final MessageType type; // نوع الرسالة (نص، صورة، صوت، ملف)
  final String? imageUrl; // رابط الصورة إذا كانت الرسالة تحتوي على صورة
  final String? audioUrl; // رابط الملف الصوتي إذا كانت الرسالة صوتية
  final String? fileUrl; // رابط الملف المرفق
  final String? fileName; // اسم الملف المرفق
  final Duration? duration; // مدة المقطع الصوتي إذا كانت الرسالة صوتية
  final List<String> reactions; // تفاعلات المستخدمين مع الرسالة

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.fileName,
    this.duration,
    this.reactions = const [],
  });

  // إنشاء رسالة نصية
  factory Message.text({
    required String id,
    required String chatId,
    required String senderId,
    required String content,
    required DateTime createdAt,
    bool isRead = false,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      createdAt: createdAt,
      type: MessageType.text,
      isRead: isRead,
    );
  }

  // إنشاء رسالة صورة
  factory Message.image({
    required String id,
    required String chatId,
    required String senderId,
    required String imageUrl,
    String content = '',
    required DateTime createdAt,
    bool isRead = false,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      createdAt: createdAt,
      type: MessageType.image,
      imageUrl: imageUrl,
      isRead: isRead,
    );
  }

  // إنشاء رسالة صوتية
  factory Message.audio({
    required String id,
    required String chatId,
    required String senderId,
    required String audioUrl,
    required DateTime createdAt,
    required Duration? duration,
    bool isRead = false,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: 'رسالة صوتية',
      createdAt: createdAt,
      type: MessageType.audio,
      audioUrl: audioUrl,
      isRead: isRead,
      duration: duration,
    );
  }

  // إنشاء رسالة ملف
  factory Message.file({
    required String id,
    required String chatId,
    required String senderId,
    required String fileUrl,
    required String fileName,
    required DateTime createdAt,
    bool isRead = false,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: 'ملف: $fileName',
      createdAt: createdAt,
      type: MessageType.file,
      fileUrl: fileUrl,
      fileName: fileName,
      isRead: isRead,
    );
  }

  // إنشاء نسخة من الرسالة مع تحديث بعض الحقول
  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
    MessageType? type,
    String? imageUrl,
    String? audioUrl,
    String? fileUrl,
    String? fileName,
    List<String>? reactions,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      reactions: reactions ?? this.reactions,
    );
  }

  // تحويل الرسالة إلى Map لتخزينها في Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'type': type.toString(),
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'reactions': reactions,
    };
  }

  // إنشاء رسالة من Map مستلم من Firestore
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isRead: map['isRead'] ?? false,
      type: _getMessageTypeFromString(map['type'] ?? 'text'),
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      reactions:
          map['reactions'] != null ? List<String>.from(map['reactions']) : [],
    );
  }

  // تحويل النص إلى نوع الرسالة
  static MessageType _getMessageTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'MessageType.image':
        return MessageType.image;
      case 'MessageType.audio':
        return MessageType.audio;
      case 'MessageType.file':
        return MessageType.file;
      case 'MessageType.text':
      default:
        return MessageType.text;
    }
  }
}

// أنواع الرسائل المختلفة
enum MessageType {
  text,
  image,
  audio,
  file,
}
