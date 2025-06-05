import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/app_user.dart';
import '../../core/shared/utils/user_provider.dart' as user_provider;
import '../../core/services/auth_service.dart';
import '../../core/shared/constants/app_colors.dart' as app_colors;

/// شاشة تسجيل الدخول
/// تم تعديلها لدعم تسجيل الدخول عبر Magic Link وفيسبوك والدخول كزائر فقط
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // خدمة المصادقة
  final _authService = AuthService();

  // متغيرات الحالة
  bool _isLoading = false;
  String? _selectedAccountType; // للدخول الاجتماعي
  final _magicLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  @override
  void dispose() {
    _magicLinkController.dispose();
    super.dispose();
  }

  /// التحقق من تأكيد البريد الإلكتروني
  Future<void> _checkEmailVerification() async {
    try {
      final Session? session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        await Supabase.instance.client.auth.refreshSession();
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        if (user.emailConfirmedAt != null) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          if (!mounted) return;
          _showEmailVerificationMessage();
        }
      }
    } catch (e) {
      debugPrint('خطأ في التحقق من تأكيد البريد الإلكتروني: ${e.toString()}');
    }
  }

  /// عرض رسالة تأكيد البريد الإلكتروني
  void _showEmailVerificationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'يرجى تأكيد بريدك الإلكتروني للمتابعة. تحقق من صندوق الوارد الخاص بك.',
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 5),
      ),
    );
  }

  /// إرسال رابط سحري لتسجيل الدخول
  Future<void> _sendMagicLink() async {
    final email = _magicLinkController.text.trim();
    if (email.isEmpty || _selectedAccountType == null) {
      _showErrorMessage('يرجى إدخال البريد الإلكتروني واختيار نوع الحساب');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
      );
      if (!mounted) return;
      _showSuccessMessage('تم إرسال رابط سحري إلى بريدك الإلكتروني');
    } on AuthException catch (error) {
      if (!mounted) return;
      _showErrorMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      _showErrorMessage('حدث خطأ غير متوقع: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// تسجيل الدخول باستخدام فيسبوك
  Future<void> _signInWithFacebook() async {
    if (_selectedAccountType == null) {
      _showErrorMessage('يرجى اختيار نوع الحساب لتسجيل الدخول عبر فيسبوك');
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithOAuth(OAuthProvider.facebook);

      if (result) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('جاري تسجيل الدخول عبر فيسبوك...')),
        );
      } else {
        if (!mounted) return;
        _showErrorMessage('فشل في بدء عملية تسجيل الدخول عبر فيسبوك');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      _showErrorMessage('خطأ في المصادقة: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('حدث خطأ أثناء تسجيل الدخول: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// تسجيل الدخول كزائر
  void _loginAsGuest() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تنبيه'),
          content: const Directionality(
            textDirection: TextDirection.rtl,
            child: Text('سيتم الدخول بصلاحيات محدودة'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  Navigator.of(dialogContext).pop();

                  final guestUser = AppUser(
                    id: 'guest_user_id',
                    email: 'guest@tamwuilk.com',
                    userRole: 'guest',
                  );

                  Provider.of<user_provider.UserProvider>(
                    context,
                    listen: false,
                  ).setAppUser(guestUser);

                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/home');
                } catch (e) {
                  if (!mounted) return;
                  _showErrorMessage('حدث خطأ أثناء تسجيل الدخول: $e');
                }
              },
              child: const Text('متابعة'),
            ),
          ],
        );
      },
    );
  }

  /// عرض رسالة خطأ
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// عرض رسالة نجاح
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7F7),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogoSection(),
                  const SizedBox(height: 40),
                  _buildLoginForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء قسم الشعار والعنوان
  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Image(
              image: const AssetImage('assets/images/image.png'),
              errorBuilder:
                  (context, error, stackTrace) => Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: app_colors.AppColors.primary,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        const Text(
          'تمويلك',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: app_colors.AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Tamweelak',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// بناء نموذج تسجيل الدخول المعدل
  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeader(),
          const SizedBox(height: 24),
          _buildMagicLinkField(),
          const SizedBox(height: 16),
          _buildSendMagicLinkButton(),
          const SizedBox(height: 20),
          _buildAccountTypeSelector(),
          const SizedBox(height: 24),
          _buildFacebookSignInButton(),
          const SizedBox(height: 24),
          _buildGuestLoginButton(),
        ],
      ),
    );
  }

  /// بناء عنوان النموذج
  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تسجيل الدخول',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختر طريقة تسجيل الدخول',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// بناء حقل إدخال البريد الإلكتروني للرابط السحري
  Widget _buildMagicLinkField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _magicLinkController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'البريد الإلكتروني',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: app_colors.AppColors.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  /// بناء زر إرسال الرابط السحري
  Widget _buildSendMagicLinkButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendMagicLink,
        style: ElevatedButton.styleFrom(
          backgroundColor: app_colors.AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                : const Text(
                  'تسجيل الدخول عبر الرابط السحري',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  /// بناء حقل اختيار نوع الحساب
  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع الحساب:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('مستثمر'),
                value: 'investor',
                groupValue: _selectedAccountType,
                onChanged: (value) {
                  setState(() {
                    _selectedAccountType = value;
                  });
                },
                activeColor: const Color(0xFF1BC5BD),
              ),
              RadioListTile<String>(
                title: const Text('صاحب مشروع'),
                value: 'project_owner',
                groupValue: _selectedAccountType,
                onChanged: (value) {
                  setState(() {
                    _selectedAccountType = value;
                  });
                },
                activeColor: const Color(0xFF1BC5BD),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// بناء زر تسجيل الدخول بفيسبوك
  Widget _buildFacebookSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _signInWithFacebook,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1877F2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.facebook, size: 24.0),
        label: const Text('تسجيل الدخول باستخدام فيسبوك'),
      ),
    );
  }

  /// بناء زر الدخول كزائر
  Widget _buildGuestLoginButton() {
    return Center(
      child: TextButton(
        onPressed: _loginAsGuest,
        child: const Text(
          'الدخول كزائر',
          style: TextStyle(
            color: app_colors.AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
