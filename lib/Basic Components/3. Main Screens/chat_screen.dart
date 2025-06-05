import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

// تعريف الكلاسات المفقودة
class RecordConfig {
  final String? path;
  final int? bitRate;
  final int? sampleRate;

  RecordConfig({this.path, this.bitRate, this.sampleRate});
}

// تعريف للمشغل الصوتي
enum PlayerState { playing, paused, stopped, completed }

class PlayerMode {
  static const lowLatency = 'lowLatency';
  static const mediaPlayer = 'mediaPlayer';
}

class AudioRecorder {
  Future<void> start(RecordConfig config, {String? path}) async {
    // تنفيذ وهمي لبدء التسجيل
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<String?> stop() async {
    // تنفيذ وهمي لإيقاف التسجيل
    return 'recorded_audio.m4a';
  }

  void dispose() {
    // تنظيف الموارد
  }
}

class AudioPlayer {
  Stream<PlayerState> get onPlayerStateChanged =>
      Stream.fromIterable([PlayerState.stopped]);
  Stream<Duration> get onDurationChanged =>
      Stream.fromIterable([Duration.zero]);
  Stream<Duration> get onPositionChanged =>
      Stream.fromIterable([Duration.zero]);

  Future<void> setPlayerMode(String mode) async {
    // تنفيذ وهمي لضبط وضع المشغل
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> play(UrlSource source) async {
    // تنفيذ وهمي لتشغيل الصوت
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> pause() async {
    // تنفيذ وهمي لإيقاف الصوت مؤقتاً
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> stop() async {
    // تنفيذ وهمي لإيقاف الصوت
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> seek(Duration position) async {
    // تنفيذ وهمي للانتقال إلى موضع محدد في الملف الصوتي
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> dispose() async {
    // تنظيف الموارد
    return Future.delayed(Duration(milliseconds: 100));
  }
}

class UrlSource {
  final String url;

  UrlSource(this.url);
}

class ImageSource {
  static const gallery = 'gallery';
  static const camera = 'camera';
}

class ImagePicker {
  Future<XFile?> pickImage({required String source}) async {
    // تنفيذ وهمي لالتقاط صورة
    return null;
  }
}

class Permission {
  static final microphone = _Permission('microphone');

  static Future<PermissionStatus> request() async {
    // تنفيذ وهمي لطلب الإذن
    return PermissionStatus.granted;
  }
}

class _Permission {
  final String name;

  _Permission(this.name);

  Future<PermissionStatus> request() async {
    // تنفيذ وهمي لطلب الإذن
    return PermissionStatus.granted;
  }
}

class PermissionStatus {
  final bool isGranted;

  const PermissionStatus(this.isGranted);

  static const granted = PermissionStatus(true);
  static const denied = PermissionStatus(false);
}

class Supabase {
  static final instance = Supabase._();
  final SupabaseClient client = SupabaseClient();

  Supabase._();
}

class SupabaseClient {
  final SupabaseAuth auth = SupabaseAuth();
  final SupabaseStorage storage = SupabaseStorage();

  SupabaseQueryBuilder from(String table) {
    return SupabaseQueryBuilder(table);
  }
}

class SupabaseAuth {
  final User? currentUser = User(
    id: 'user_id',
    name: 'User Name',
    email: 'user@example.com',
  );
}

class SupabaseStorage {
  StorageBucket from(String bucket) {
    return StorageBucket(bucket);
  }
}

class StorageBucket {
  final String bucket;

  StorageBucket(this.bucket);

  Future<void> uploadBinary(String path, Uint8List bytes) {
    return Future.value();
  }

  String getPublicUrl(String path) {
    return 'https://example.com/$bucket/$path';
  }
}

class SupabaseQueryBuilder {
  final String table;

  SupabaseQueryBuilder(this.table);

  Future<List<Map<String, dynamic>>> select([String? columns]) {
    return Future.value([]);
  }

  SupabaseQueryBuilder eq(String field, dynamic value) {
    return this;
  }

  SupabaseQueryBuilder order(String field, {bool ascending = true}) {
    return this;
  }

  Future<void> delete() {
    return Future.value();
  }

  Future<void> insert(Map<String, dynamic> data) {
    return Future.value();
  }
}

class Provider {
  static T of<T>(BuildContext context, {bool listen = true}) {
    // تنفيذ وهمي للحصول على مزود الحالة
    return UserProvider() as T;
  }
}

Future<Directory> getTemporaryDirectory() async {
  // تنفيذ وهمي للحصول على الدليل المؤقت
  return Directory('temp');
}

class Directory {
  final String path;

  Directory(this.path);
}

class XFile {
  final String path;

  XFile(this.path);

  Future<Uint8List> readAsBytes() async {
    // تنفيذ وهمي لقراءة الملف كبايتات
    return Uint8List(0);
  }

  String get name => path.split('/').last;
}

class XTypeGroup {
  final String label;
  final List<String> extensions;

  XTypeGroup({required this.label, required this.extensions});
}

Future<XFile?> openFile({List<XTypeGroup>? acceptedTypeGroups}) async {
  // تنفيذ وهمي لفتح ملف
  return null;
}

// تعريف فئة الألوان مباشرة في الملف لتجنب مشاكل الاستيراد
class AppColors {
  static const Color primary = Color(0xFF5E35B1);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color accent = Color(0xFFFFC107);
}

// --- Data Models ---

enum MessageType { text, image, audio, file }

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? fileName;
  final MessageType type;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.fileName,
    this.type = MessageType.text,
  });
}

class ChatUser {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String imageUrl;
  final bool isOnline;
  final int unreadCount;

  ChatUser({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.imageUrl,
    this.isOnline = false,
    this.unreadCount = 0,
  });
}

// تعريف نموذج المستخدم مباشرة في الملف لتجنب مشاكل الاستيراد
class User {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});
}

// تعريف مدير حالة المستخدم مباشرة في الملف
class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}

// --- Main Chat Screen Widget ---

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  // متغير للاستخدام الوهمي فقط - نستخدمه في التعليقات فقط
  // final _supabase = Supabase.instance.client;
  String _selectedChatId = '';
  int _selectedUserIndex = 0;
  bool _isRecording = false;
  late final recorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();
  final List<ChatUser> _chatUsers = [
    ChatUser(
      id: 'user1',
      name: 'سارة الأحمد',
      lastMessage: 'متصل الآن',
      time: '09:45',
      imageUrl: 'assets/images/c1.png',
      isOnline: true,
      unreadCount: 3,
    ),
    ChatUser(
      id: 'user2',
      name: 'محمد العلي',
      lastMessage: 'هل مناقشة المشروع تمت؟',
      time: 'أمس',
      imageUrl: 'assets/images/c2.png',
      isOnline: true,
      unreadCount: 0,
    ),
    ChatUser(
      id: 'user3',
      name: 'نورة السعيد',
      lastMessage: 'موعد الاجتماع القادم؟',
      time: 'الثلاثاء',
      imageUrl: 'assets/images/c3.png',
      isOnline: false,
      unreadCount: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedChatId = widget.chatId;
    // Find the initial user index based on chatId if it's not 'chat_list'
    if (_selectedChatId != 'chat_list') {
      _selectedUserIndex = _chatUsers.indexWhere(
        (user) => user.id == _selectedChatId,
      );
      if (_selectedUserIndex == -1) {
        _selectedUserIndex = 0; // Default if not found
      }
      _loadMessages();
    } else {
      _selectedUserIndex = 0; // Default index
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    recorder.dispose();
    super.dispose();
  }

  // --- Message Loading ---

  Future<void> _loadMessages() async {
    if (_selectedChatId == 'chat_list' || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // استخدام بيانات وهمية للرسائل
      final response = [
        {
          'content': 'مرحباً بك في المحادثة!',
          'sender_id': 'other_user',
          'created_at':
              DateTime.now().subtract(Duration(minutes: 30)).toString(),
          'type': 'text',
          'file_name': null,
        },
        {
          'content': 'شكراً لك',
          'sender_id': user.id,
          'created_at':
              DateTime.now().subtract(Duration(minutes: 25)).toString(),
          'type': 'text',
          'file_name': null,
        },
        {
          'content': 'كيف يمكنني مساعدتك اليوم؟',
          'sender_id': 'other_user',
          'created_at':
              DateTime.now().subtract(Duration(minutes: 20)).toString(),
          'type': 'text',
          'file_name': null,
        },
      ];

      if (!mounted) return; // Check mounted again after await

      setState(() {
        _messages =
            (response as List)
                .map(
                  (msg) => ChatMessage(
                    text: msg['content'] ?? '', // Handle potential null content
                    isMe: msg['sender_id'] == user.id,
                    time: DateTime.parse(msg['created_at']).toString(),
                    type: _getMessageTypeFromString(msg['type']),
                    imageUrl: msg['type'] == 'image' ? msg['content'] : null,
                    audioUrl: msg['type'] == 'audio' ? msg['content'] : null,
                    fileUrl: msg['type'] == 'file' ? msg['content'] : null,
                    fileName: msg['file_name'],
                  ),
                )
                .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading messages: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  MessageType _getMessageTypeFromString(String? typeString) {
    switch (typeString) {
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

  // --- Chat Selection & Deletion ---

  void _selectChat(String chatId, int userIndex) {
    if (!mounted) return;
    setState(() {
      _selectedChatId = chatId;
      _selectedUserIndex = userIndex;
      _messages = []; // Clear messages for the new chat
    });
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      // تنفيذ وهمي لحذف المحادثة
      // لا نحتاج للاتصال بقاعدة البيانات في هذا المثال
      await Future.delayed(Duration(milliseconds: 300));
    } catch (e) {
      rethrow;
    }
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_chatUsers[_selectedUserIndex].name),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Add a chat list drawer/section to use _selectChat and _deleteChat
          if (_selectedChatId == 'chat_list')
            Expanded(
              child: ListView.builder(
                itemCount: _chatUsers.length,
                itemBuilder: (context, index) {
                  final user = _chatUsers[index];
                  return Dismissible(
                    key: Key(user.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.startToEnd,
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm"),
                            content: const Text(
                              "Are you sure you want to delete this chat?",
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text("CANCEL"),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text("DELETE"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      _deleteChat(user.id);
                      setState(() {
                        _chatUsers.removeAt(index);
                      });
                    },
                    child: ChatUserTile(
                      user: user,
                      isSelected: _selectedUserIndex == index,
                      onTap: () => _selectChat(user.id, index),
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageItem(message);
                        },
                      ),
            ),
          _buildMessageInput(),
        ],
      ),
      // Add a drawer toggle button
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'المحادثات',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chatUsers.length,
                itemBuilder: (context, index) {
                  final user = _chatUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(user.imageUrl),
                    ),
                    title: Text(user.name),
                    subtitle: Text(
                      user.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing:
                        user.unreadCount > 0
                            ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                user.unreadCount.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                            : null,
                    onTap: () {
                      _selectChat(user.id, index);
                      Navigator.of(context).pop(); // Close drawer
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Delete Chat"),
                              content: const Text(
                                "Are you sure you want to delete this conversation?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("CANCEL"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteChat(user.id);
                                    Navigator.of(context).pop();
                                    setState(() {
                                      // If we're viewing this chat, go back to first chat
                                      if (_selectedChatId == user.id) {
                                        _selectChat(_chatUsers[0].id, 0);
                                      }
                                    });
                                  },
                                  child: const Text("DELETE"),
                                ),
                              ],
                            ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: message.isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: TextStyle(
                fontSize: 12,
                color: message.isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _showAttachmentOptions,
          ),
          IconButton(
            icon: const Icon(Icons.emoji_emotions),
            onPressed: _showEmojiPicker,
          ),
          GestureDetector(
            onLongPress: _startRecording,
            onLongPressEnd: (_) => _stopRecording(),
            child: IconButton(
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: _isRecording ? Colors.red : null,
              ),
              onPressed: null, // Disabled for single tap
            ),
          ),
          Expanded(
            child: Directionality(
              // Wrap TextField with Directionality
              textDirection: TextDirection.rtl, // Set text direction to RTL
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالتك هنا...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _sendMessage();
              _scrollToBottom();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isMe: true, time: DateTime.now().toString()),
      );
      _messageController.clear();
    });

    try {
      // تنفيذ وهمي لإرسال الرسالة
      await Future.delayed(Duration(milliseconds: 300));

      // إضافة رد وهمي بعد فترة قصيرة
      if (mounted) {
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _messages.add(
                ChatMessage(
                  text: 'شكراً لرسالتك! سنرد عليك قريباً.',
                  isMe: false,
                  time: DateTime.now().toString(),
                ),
              );
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    }
  }

  // --- Emoji Picker ---

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SizedBox(
            child: emoji_picker.EmojiPicker(
              onEmojiSelected: (category, emoji) {
                _messageController.text += emoji.emoji;
              },
            ),
          ),
   );
  }

  // --- Media Handling ---

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          // Ensure options are visible
          child: Wrap(
            // Use Wrap for better layout
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: const Text('File'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
              // Add other options like Video, Location etc. if needed
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null && mounted) {
        _uploadAndSendMedia(
          fileBytes: await image.readAsBytes(),
          fileName: image.name,
          type: MessageType.image,
          bucket: 'images',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File picking is not supported on web platform'),
          ),
        );
        return;
      }

      final XTypeGroup typeGroup = XTypeGroup(
        label: 'files',
        extensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
      );

      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null && mounted) {
        final bytes = await file.readAsBytes();
        _uploadAndSendMedia(
          fileBytes: bytes,
          fileName: file.name,
          type: MessageType.file,
          bucket: 'files',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _startRecording() async {
    if (!mounted) return;

    final hasPermission = await Permission.microphone.request();
    if (!hasPermission.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
      return;
    }

    try {
      // Get temp directory
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await recorder.start(RecordConfig(), path: filePath);
      setState(() => _isRecording = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error starting recording: $e')));
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!mounted) return;

    try {
      final path = await recorder.stop();
      setState(() => _isRecording = false);

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await _uploadAndSendMedia(
            fileBytes: await file.readAsBytes(),
            fileName: path.split('/').last,
            type: MessageType.audio,
            bucket: 'audio',
          );
          // Optionally delete the local file after upload
          await file.delete();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error stopping recording: $e')));
      }
    }
  }

  Future<void> _uploadAndSendMedia({
    required Uint8List fileBytes,
    required String fileName,
    required MessageType type,
    required String bucket, // e.g., 'images', 'files', 'audio'
  }) async {
    if (!mounted) return;
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user == null) return;

    final String fileExtension = path.extension(fileName);
    final String uniqueFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${user.id}$fileExtension';

    try {
      // تنفيذ وهمي لرفع الملف
      await Future.delayed(Duration(milliseconds: 500));

      // إنشاء عنوان URL وهمي للملف
      final mediaUrl = 'https://example.com/$bucket/$uniqueFileName';

      // إرسال الرسالة
      _sendMediaMessage(
        mediaUrl: mediaUrl,
        fileName:
            type == MessageType.file || type == MessageType.audio
                ? fileName
                : null, // Only send filename for files/audio
        type: type,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error uploading ${type.toString().split('.').last}: $e',
            ),
          ),
        );
      }
    }
  }

  // Add missing method for sending media messages
  Future<void> _sendMediaMessage({
    String? text,
    String? mediaUrl,
    String? fileName,
    required MessageType type,
  }) async {
    if (!mounted) return;
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user == null || mediaUrl == null) return;

    final now = DateTime.now();
    final time = now.toIso8601String();

    setState(() {
      _messages.add(
        ChatMessage(
          text: text ?? '',
          isMe: true,
          time: time,
          type: type,
          imageUrl: type == MessageType.image ? mediaUrl : null,
          audioUrl: type == MessageType.audio ? mediaUrl : null,
          fileUrl: type == MessageType.file ? mediaUrl : null,
          fileName: fileName,
        ),
      );
    });

    try {
      // تنفيذ وهمي لحفظ الرسالة
      await Future.delayed(Duration(milliseconds: 300));

      // إضافة رد وهمي بعد فترة قصيرة
      if (mounted) {
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _messages.add(
                ChatMessage(
                  text: 'تم استلام الملف بنجاح!',
                  isMe: false,
                  time: DateTime.now().toString(),
                  type: MessageType.text,
                ),
              );
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send media: $e')));
        setState(() {
          _messages.removeLast();
        });
      }
    }
  }

  // Add helper method for scrolling to bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }
}

// --- Supporting Widgets (Ensure these are defined *outside* _ChatScreenState) ---

class ChatUserTile extends StatelessWidget {
  final ChatUser user;
  final bool isSelected;
  final VoidCallback onTap;

  const ChatUserTile({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Wrap with InkWell for tap effect
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ), // Adjusted padding
        color:
            isSelected
                ? Colors.blue.withAlpha(26) // Opacity 0.1
                : Colors.transparent, // Highlight selected
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(user.imageUrl),
                ),
                if (user.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.lastMessage,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user.time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                if (user.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ), // Adjusted padding
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      user.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final String? imageUrl;
  final String? audioUrl;
  final String? fileUrl;
  final String? fileName;
  final MessageType type;

  const MessageBubble({
    super.key, // Use super parameter
    required this.message,
    required this.isMe,
    required this.time,
    this.imageUrl,
    this.audioUrl,
    this.fileUrl,
    this.fileName,
    required this.type, // Make type required
  });

  @override
  Widget build(BuildContext context) {
    // Format time string (assuming ISO format)
    String timeFormatted = '';
    try {
      final dateTime = DateTime.parse(time);
      timeFormatted =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'; // HH:MM
    } catch (_) {
      timeFormatted = time.substring(11, 16); // Fallback if parse fails
    }

    return Align(
      // Use Align for proper left/right alignment
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ), // Max width constraint
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ), // Margin around bubble
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ), // Padding inside bubble
        decoration: BoxDecoration(
          color:
              isMe
                  ? AppColors.primary.withAlpha(230) // Opacity 0.9
                  : Colors.grey[200], // Use primary color for 'me'
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // Opacity 0.05
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content start
          mainAxisSize: MainAxisSize.min, // Fit content size
          children: [
            // Content based on type
            _buildContent(context),
            const SizedBox(height: 4),
            // Time stamp aligned to the end
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeFormatted,
                style: TextStyle(
                  color:
                      isMe
                          ? Colors.white.withAlpha(179)
                          : Colors.grey[600], // Opacity 0.7
                  fontSize: 10, // Smaller font size for time
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (type) {
      case MessageType.text:
        return Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        );

      case MessageType.image:
        if (imageUrl == null) return const SizedBox.shrink();
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl!,
            // Consider adding width/height constraints or AspectRatio
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              );
            },
            errorBuilder:
                (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
          ),
        );

      case MessageType.audio:
        if (audioUrl == null) return const SizedBox.shrink();
        // Use the dedicated AudioPlayerButton widget
        return AudioPlayerButton(audioUrl: audioUrl!, isMe: isMe);

      case MessageType.file:
        if (fileUrl == null) return const SizedBox.shrink();
        return InkWell(
          // Make file tappable
          onTap: () {
            /*  */
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                color: isMe ? Colors.white : AppColors.primary,
                size: 30,
              ),
              const SizedBox(width: 8),
              Flexible(
                // Allow text to wrap
                child: Text(
                  fileName ?? 'File', // Show filename or default
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
    }
  }
}

// --- Audio Player Button Widget (Stateful) ---

class AudioPlayerButton extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const AudioPlayerButton({
    super.key,
    required this.audioUrl,
    required this.isMe,
  });

  @override
  State<AudioPlayerButton> createState() => _AudioPlayerButtonState();
}

class _AudioPlayerButtonState extends State<AudioPlayerButton> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;
  bool get _isStopped => _playerState == PlayerState.stopped;
  bool get _isCompleted => _playerState == PlayerState.completed;

  @override
  void initState() {
    super.initState();
    // Set player mode for low latency (good for short audio)
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _initAudioPlayerListeners();
  }

  void _initAudioPlayerListeners() {
    // Use streams directly for state updates
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen(
      (state) {
        if (mounted) setState(() => _playerState = state);
        if (state == PlayerState.completed && mounted) {
          setState(
            () => _position = Duration.zero,
          ); // Reset position on completion
        }
      },
      onError: (msg) {
        if (mounted) setState(() => _playerState = PlayerState.stopped);
        // Handle error
      },
    );

    _durationSubscription = _audioPlayer.onDurationChanged.listen((
      newDuration,
    ) {
      if (mounted) setState(() => _duration = newDuration);
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((
      newPosition,
    ) {
      if (mounted) setState(() => _position = newPosition);
    });
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // If completed or stopped, play from start. If paused, resume.
        await _audioPlayer.play(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      // Handle playback error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error playing audio: $e")));
      }
    }
  }

  @override
  void dispose() {
    // Cancel stream subscriptions
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose(); // Dispose the player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isMe
            ? Colors.white
            : AppColors.primary; // Adjusted colors for bubble context

    return Row(
      mainAxisSize: MainAxisSize.min, // Take minimum space needed
      children: [
        IconButton(
          icon: Icon(
            _isPlaying
                ? Icons.pause_circle_filled_outlined
                : Icons.play_circle_filled_outlined,
            size: 30,
          ),
          color: color,
          onPressed: _playPause,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(), // Remove extra padding
        ),
        const SizedBox(width: 8),
        // Progress Indicator and Time
        Expanded(
          // Allow slider and text to take available space
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_duration > Duration.zero)
                SliderTheme(
                  // Customize slider appearance
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12.0,
                    ),
                    thumbColor: color,
                    activeTrackColor: color,
                    inactiveTrackColor: color.withAlpha(77), // Opacity 0.3
                    overlayColor: color.withAlpha(51), // Opacity 0.2
                  ),
                  child: Slider(
                    value: _position.inMilliseconds.toDouble().clamp(
                      0.0,
                      _duration.inMilliseconds.toDouble(),
                    ),
                    min: 0.0,
                    max: _duration.inMilliseconds.toDouble(),
                    onChanged: (value) async {
                      final newPosition = Duration(milliseconds: value.toInt());
                      await _audioPlayer.seek(newPosition);
                      // Optionally resume playback after seek
                      if (_isPaused || _isStopped || _isCompleted) {
                        await _playPause();
                      }
                    },
                  ),
                ),
              if (_duration > Duration.zero)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ), // Padding for time text
                  child: Text(
                    '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withAlpha(204),
                    ), // Opacity 0.8
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

// --- Audio Player Widget (within MessageBubble or similar) ---

class _AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool isMe;

  const _AudioPlayerWidget({required this.audioUrl, required this.isMe});

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration? _duration;
  Duration? _position;

  // Corrected types to StreamSubscription?
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;
  bool get _isStopped => _playerState == PlayerState.stopped;
  bool get _isCompleted => _playerState == PlayerState.completed;

  @override
  void initState() {
    super.initState();
    // Set player mode for low latency (good for short audio)
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _initAudioPlayerListeners();
  }

  void _initAudioPlayerListeners() {
    // Use streams directly for state updates
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen(
      (state) {
        if (mounted) setState(() => _playerState = state);
        if (state == PlayerState.completed && mounted) {
          setState(
            () => _position = Duration.zero,
          ); // Reset position on completion
        }
      },
      onError: (msg) {
        if (mounted) setState(() => _playerState = PlayerState.stopped);
        // Handle error
        // Use a logging framework instead of print
        // logger.info('Audio Player Error: $msg');
      },
    );

    _durationSubscription = _audioPlayer.onDurationChanged.listen((
      newDuration,
    ) {
      if (mounted) setState(() => _duration = newDuration);
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((
      newPosition,
    ) {
      if (mounted) setState(() => _position = newPosition);
    });
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // If completed or stopped, play from start. If paused, resume.
        await _audioPlayer.play(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      // Handle playback error
      // Use a logging framework instead of print
      // logger.info('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error playing audio: $e")));
      }
    }
  }

  @override
  void dispose() {
    // Cancel stream subscriptions
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose(); // Dispose the player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isMe
            ? Colors.white
            : AppColors.primary; // Adjusted colors for bubble context

    return Row(
      mainAxisSize: MainAxisSize.min, // Take minimum space needed
      children: [
        IconButton(
          icon: Icon(
            _isPlaying
                ? Icons.pause_circle_filled_outlined
                : Icons.play_circle_filled_outlined,
            size: 30,
          ),
          color: color,
          onPressed: _playPause,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(), // Remove extra padding
        ),
        const SizedBox(width: 8),
        // Progress Indicator and Time
        Expanded(
          // Allow slider and text to take available space
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_duration! > Duration.zero)
                SliderTheme(
                  // Customize slider appearance
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12.0,
                    ),
                    thumbColor: color,
                    activeTrackColor: color,
                    inactiveTrackColor: color.withValues(alpha: 0.3),
                    overlayColor: color.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _position!.inMilliseconds.toDouble().clamp(
                      0.0,
                      _duration!.inMilliseconds.toDouble(),
                    ),
                    min: 0.0,
                    max: _duration!.inMilliseconds.toDouble(),
                    onChanged: (value) async {
                      final newPosition = Duration(milliseconds: value.toInt());
                      await _audioPlayer.seek(newPosition);
                      // Optionally resume playback after seek
                      if (_isPaused || _isStopped || _isCompleted) {
                        await _playPause();
                      }
                    },
                  ),
                ),
              if (_duration! > Duration.zero)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ), // Padding for time text
                  child: Text(
                    '${_formatDuration(_position!)} / ${_formatDuration(_duration!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
