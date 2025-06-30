import 'package:flutter/material.dart';
import '../../../Routing/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/shared/utils/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/supabase_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../models/user_profile.dart';
import '../../../core/services/logger_service.dart';
import '../2. Authentication/login_screen.dart';
import '../../../core/shared/widgets/auth_success_message.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  UserProfile? userProfile;
  bool isLoading = true;
  static const String defaultProfileImage = 'assets/images/icon.png';
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  bool isEditing = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  RouteObserver<PageRoute>? _routeObserver;

  @override
  void initState() {
    super.initState();
    _fetchOrCreateProfile().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybePromptProfileCompletion();
        // تحقق من نوع الحساب بعد تحميل الملف الشخصي
        if (userProfile != null &&
            userProfile!.role != 'investor' &&
            userProfile!.role != 'project_owner') {
          _showAccountTypeDialog();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = ModalRoute.of(context)?.navigator?.widget.observers
        .whereType<RouteObserver<PageRoute>>()
        .firstOrNull;
    _routeObserver?.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    // Dispose controllers
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this page
    _fetchOrCreateProfile();
  }

  Future<void> _fetchOrCreateProfile() async {
    debugPrint('بدء تحميل الملف الشخصي...');
    if (!mounted) return;
    // Capture the context before async operations
    final currentContext = context;
    setState(() {
      isLoading = true;
    });
    final userProvider = Provider.of<UserProvider>(
      currentContext,
      listen: false,
    );
    final user = userProvider.currentUser;
    if (user == null) {
      debugPrint('لم يتم العثور على مستخدم.');
      if (!mounted) return;
      setState(() {
        userProfile = null;
        isLoading = false;
      });
      return;
    }
    try {
      final profile = await ProfileService.getProfile(user.id);
      if (profile == null) {
        debugPrint('لا يوجد ملف شخصي، سيتم الإنشاء...');
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'name': user.userRole ?? '',
          'user_role': user.userRole,
          'avatar_url': null,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        final newProfile = await ProfileService.getProfile(user.id);
        if (!mounted) return;
        setState(() {
          userProfile = newProfile;
          isLoading = false;
        });
      } else {
        debugPrint('تم جلب الملف الشخصي بنجاح.');
        if (!mounted) return;
        setState(() {
          userProfile = profile;
          isLoading = false;
        });
      }
    } catch (e, st) {
      debugPrint('حدث خطأ أثناء تحميل الملف الشخصي: $e\n$st');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        userProfile = null;
      });
      // عرض رسالة خطأ واضحة
      // Use a local variable to capture the error
      final error = e;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(content: Text('حدث خطأ أثناء تحميل الملف الشخصي: $error')),
          );
        }
      });
    }
  }

  void _maybePromptProfileCompletion() {
    if (!mounted || userProfile == null) return;
    final phone = userProfile?.phoneNumber ?? '';
    final city = userProfile?.city ?? '';
    final bio = userProfile?.bio ?? '';
    if (phone.isEmpty || city.isEmpty || bio.isEmpty) {
      _showProfileCompletionDialog();
    }
  }

  void _showProfileCompletionDialog() {
    final phoneController = TextEditingController(
      text: userProfile?.phoneNumber ?? '',
    );
    final cityController = TextEditingController(text: userProfile?.city ?? '');
    final bioController = TextEditingController(text: userProfile?.bio ?? '');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('أكمل بيانات ملفك الشخصي'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم الجوال'),
                  textDirection: TextDirection.rtl,
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'المدينة'),
                  textDirection: TextDirection.rtl,
                ),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(labelText: 'نبذة عنك'),
                  maxLines: 2,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Capture the context before async operations
                final currentContext = context;
                final userProvider = Provider.of<UserProvider>(
                  currentContext,
                  listen: false,
                );
                final user = userProvider.currentUser;
                if (user != null) {
                  await ProfileService.updateProfile(user.id, {
                    'phone_number': phoneController.text.trim(),
                    'city': cityController.text.trim(),
                    'bio': bioController.text.trim(),
                  });
                  await _fetchOrCreateProfile();
                  // Check if the widget is still mounted before using the captured context
                  if (!mounted) return;
                  // Use the captured context which is now properly guarded by the mounted check
                  showCustomSuccessMessage(
                    currentContext,
                    'تم تحديث بيانات ملفك الشخصي بنجاح.',
                  );
                }
                if (mounted) {
                  Navigator.of(currentContext).pop();
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showAccountTypeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('نوع الحساب غير صالح'),
        content: const Text('يرجى اختيار نوع الحساب: مستثمر أو صاحب مشروع'),
        actions: [
          TextButton(
            onPressed: () async {
              // Capture the context before async operations
              final currentContext = context;
              final userProvider = Provider.of<UserProvider>(
                currentContext,
                listen: false,
              );
              final user = userProvider.currentUser;
              if (user != null) {
                await Supabase.instance.client
                    .from('profiles')
                    .update({'user_role': 'investor'})
                    .eq('id', user.id);
                await _fetchOrCreateProfile();
                if (!mounted) return;
                Navigator.of(currentContext).pop();
                await _fetchOrCreateProfile();
              }
            },
            child: const Text('مستثمر'),
          ),
          TextButton(
            onPressed: () async {
              // Capture the context before async operations
              final currentContext = context;
              final userProvider = Provider.of<UserProvider>(
                currentContext,
                listen: false,
              );
              final user = userProvider.currentUser;
              if (user != null) {
                await Supabase.instance.client
                    .from('profiles')
                    .update({'user_role': 'project_owner'})
                    .eq('id', user.id);
                await _fetchOrCreateProfile();
                if (!mounted) return;
                Navigator.of(currentContext).pop();
                await _fetchOrCreateProfile();
              }
            },
            child: const Text('صاحب مشروع'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    // Capture the context before async operations
    final currentContext = context;
    final userProvider = Provider.of<UserProvider>(
      currentContext,
      listen: false,
    );
    final user = userProvider.currentUser;
    if (user == null) return;

    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile == null) return;
    if (!mounted) return;

    setState(() {
      isUploading = true;
    });

    try {
      final bytes = await pickedFile.readAsBytes();
      final fileExt = pickedFile.path.split('.').last;
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final supabaseService = SupabaseService();
      final fileUrl = await supabaseService.uploadFile(
        bucketName: 'avatars',
        filePath: fileName,
        fileBytes: bytes,
        contentType: 'image/$fileExt',
      );

      if (fileUrl != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({
              'avatar_url': fileUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', user.id);

        if (!mounted) return;
        setState(() {
          // No need to set avatarUrl directly; just re-fetch profile
        });

        // Show success message without using context after async
        _showMessage(currentContext, 'تم تحديث صورة الملف الشخصي بنجاح');
      } else {
        if (!mounted) return;
        _showMessage(currentContext, 'فشل في رفع الصورة.');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(currentContext, 'خطأ: $e');
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _startEditing() {
    if (userProfile != null) {
      nameController.text = userProfile!.name ?? '';
      phoneController.text = userProfile!.phoneNumber ?? '';
      cityController.text = userProfile!.city ?? '';
      bioController.text = userProfile!.bio ?? '';
    }
    setState(() {
      isEditing = true;
    });
  }

  Future<void> _saveProfileEdits() async {
    if (!mounted) return;
    // Capture the context before async operations
    final currentContext = context;
    final userProvider = Provider.of<UserProvider>(
      currentContext,
      listen: false,
    );
    final user = userProvider.currentUser;
    if (user != null) {
      await ProfileService.updateProfile(user.id, {
        'name': nameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'city': cityController.text.trim(),
        'bio': bioController.text.trim(),
      });
      await _fetchOrCreateProfile();
    }
    if (!mounted) return;
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);

    if (userProvider.isLoadingUser) {
      return Center(child: CircularProgressIndicator());
    }
    if (userProvider.currentUser == null) {
      return LoginScreen();
    }

    final user = userProvider.currentUser;
    LoggerService.info(
      'User in profile_screen: [32m[1m[4m${user?.id ?? 'null'}\n${user?.email ?? 'null'}\n${user?.userRole ?? 'null'}',
      tag: 'ProfileScreen',
    );

    if (user == null) {
      return LoginScreen();
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          await _fetchOrCreateProfile();
        },
        child: Builder(
          builder: (context) {
            if (isLoading || userProvider.isCreatingProfile) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.teal),
                          const SizedBox(height: 16),
                          Text(
                            userProvider.isCreatingProfile
                                ? 'جاري إنشاء ملفك الشخصي...'
                                : 'جاري التحميل...',
                          ),
                          const SizedBox(height: 16),
                          // معالجة حالة التحميل الطويل
                          if (isLoading && !userProvider.isCreatingProfile)
                            const Text(
                              'إذا استمرت هذه الشاشة طويلاً، تحقق من اتصال الإنترنت أو أعد المحاولة لاحقاً.',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            // معالجة حالة فشل جلب البيانات
            if (userProfile == null && !isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'تعذر تحميل بيانات الملف الشخصي.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchOrCreateProfile,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            final String userName =
                userProfile?.name ?? user.userRole ?? 'مستخدم';
            final String userEmail = userProfile?.email ?? user.email;
            final String userId = user.id;
            final String userRole =
                userProfile?.role ?? user.userRole ?? 'غير محدد';
            final String? avatarUrl = userProfile?.avatarUrl;
            final String? phoneNumber = userProfile?.phoneNumber;
            final String? bio = userProfile?.bio;
            final String? city = userProfile?.city;

            ImageProvider profileImageProvider;
            if (avatarUrl != null && avatarUrl.isNotEmpty) {
              profileImageProvider = NetworkImage(avatarUrl);
            } else {
              profileImageProvider = const AssetImage(defaultProfileImage);
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('الملف الشخصي'),
                backgroundColor: Colors.teal,
                actions: [
                  if (!isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _startEditing,
                    ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  // Profile Picture
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: isUploading
                              ? null
                              : () async {
                                  await _pickAndUploadImage();
                                  if (mounted) {
                                    await _fetchOrCreateProfile();
                                  }
                                },
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: profileImageProvider,
                            backgroundColor: Colors.grey[200],
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 22,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isUploading)
                          const Positioned(
                            right: 8,
                            bottom: 8,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // User Name
                  Center(
                    child: isEditing
                        ? TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'الاسم',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8.0),
                  // Account Type Widget
                  Center(child: _AccountTypeWidget(userRole: userRole)),
                  const SizedBox(height: 8.0),
                  // User Email
                  Center(
                    child: Text(
                      userEmail,
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // User ID
                  Center(
                    child: Text(
                      'معرف المستخدم: $userId',
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[500]),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // User Role
                  Center(
                    child: Text(
                      'الدور: $userRole',
                      style: TextStyle(fontSize: 15.0, color: Colors.teal[700]),
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // أزرار الاشتراك حسب نوع الحساب
                  if (userRole == 'investor')
                    ElevatedButton(
                      onPressed: () {
                        // الانتقال إلى نموذج اشتراك المستثمر
                        Navigator.pushNamed(
                          context,
                          AppRoutes.investorSubscription,
                        );
                      },
                      child: const Text('الاشتراك في باقة المستثمر'),
                    ),
                  if (userRole == 'project_owner')
                    ElevatedButton(
                      onPressed: () {
                        // الانتقال إلى نموذج اشتراك صاحب المشروع
                        Navigator.pushNamed(
                          context,
                          AppRoutes.projectOwnerSubscription,
                        );
                      },
                      child: const Text('الاشتراك في باقة أصحاب المشاريع'),
                    ),
                  const SizedBox(height: 8.0),
                  Center(
                    child: isEditing
                        ? TextField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: 'رقم الجوال',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15.0,
                              color: Colors.teal,
                            ),
                          )
                        : (phoneNumber != null && phoneNumber.isNotEmpty)
                        ? Text(
                            'رقم الجوال: $phoneNumber',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.teal[700],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8.0),
                  Center(
                    child: isEditing
                        ? TextField(
                            controller: cityController,
                            decoration: const InputDecoration(
                              labelText: 'المدينة',
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15.0,
                              color: Colors.teal,
                            ),
                          )
                        : (city != null && city.isNotEmpty)
                        ? Text(
                            'المدينة: $city',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.teal[700],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 8.0),
                  Center(
                    child: isEditing
                        ? TextField(
                            controller: bioController,
                            decoration: const InputDecoration(
                              labelText: 'نبذة عنك',
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 15.0,
                              color: Colors.teal,
                            ),
                          )
                        : (bio != null && bio.isNotEmpty)
                        ? Text(
                            'نبذة: $bio',
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.teal[700],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: _saveProfileEdits,
                        child: const Text('حفظ التعديلات'),
                      ),
                    ),
                  const SizedBox(height: 24.0),
                  Card(
                    elevation: 2.0,
                    child: ListTile(
                      leading: const Icon(Icons.folder_open),
                      title: const Text('مشاريعي'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        if (userRole != 'project_owner') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'هذه الميزة متاحة فقط لأصحاب المشاريع',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        // الانتقال إلى صفحة إدارة المشاريع
                        // Navigator.pushNamed(context, AppRoutes.projectManagement);
                      },
                    ),
                  ),
                  Card(
                    elevation: 2.0,
                    child: ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('الإعدادات'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        AppRoutes.navigateTo(context, AppRoutes.settings);
                      },
                    ),
                  ),
                  Card(
                    elevation: 2.0,
                    child: ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('الإشعارات'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        AppRoutes.navigateTo(context, AppRoutes.notifications);
                      },
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );

                      await Supabase.instance.client.auth.signOut();
                      if (!mounted) return;

                      userProvider.clearUser();
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
                      );
                      if (!mounted) return;

                      navigator.pushNamedAndRemoveUntil(
                        AppRoutes.welcome,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }
}

class _AccountTypeWidget extends StatelessWidget {
  final String userRole;
  const _AccountTypeWidget({required this.userRole});

  @override
  Widget build(BuildContext context) {
    String accountType;
    switch (userRole) {
      case 'admin':
        accountType = 'مدير';
        break;
      case 'investor':
        accountType = 'مستثمر';
        break;
      case 'project_owner':
        accountType = 'صاحب مشروع';
        break;
      default:
        accountType = 'مستخدم عادي';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_user, color: Colors.teal, size: 20),
        const SizedBox(width: 6),
        Text(
          'نوع الحساب: $accountType',
          style: const TextStyle(fontSize: 16, color: Colors.teal),
        ),
      ],
    );
  }
}
