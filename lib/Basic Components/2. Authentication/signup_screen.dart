import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/app_user.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/shared/constants/app_colors.dart' as app_colors;
import '../../core/shared/utils/user_provider.dart' as user_provider;
import '../../widgets/account_type_selector.dart';

/// شاشة إنشاء حساب جديد
/// تسمح للمستخدم بإنشاء حساب جديد مع اختيار نوع الحساب
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // متغيرات الحالة
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedAccountType = 'investor';

  // وحدات التحكم في الحقول
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// إنشاء حساب جديد
  Future<void> _signUp() async {
    // التحقق من صحة المدخلات
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorMessage('يرجى ملء جميع الحقول المطلوبة');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // إنشاء حساب جديد باستخدام AuthService
      final result = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        accountType: _selectedAccountType,
        emailRedirectTo: 'com.example.tamwuilk://home_screen',
      );

      if (result['success']) {
        // إنشاء ملف شخصي للمستخدم
        await ProfileService.createProfile(
          userId: result['user']['id'],
          accountType: _selectedAccountType,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );

        if (!mounted) return;

        // إنشاء كائن المستخدم وتعيينه في مزود الحالة
        final appUser = AppUser(
          id: result['user']['id'],
          email: result['user']['email'],
          userRole: _selectedAccountType,
        );

        Provider.of<user_provider.UserProvider>(
          context,
          listen: false,
        ).setAppUser(appUser);

        // عرض رسالة نجاح
        _showSuccessMessage(
          'تم إنشاء الحساب بنجاح. يرجى التحقق من بريدك الإلكتروني لتأكيد حسابك.',
        );

        // الانتقال إلى شاشة تسجيل الدخول
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        if (!mounted) return;
        _showErrorMessage(result['error'] ?? 'حدث خطأ أثناء إنشاء الحساب');
      }
    } on AuthException catch (error) {
      _showErrorMessage('خطأ في المصادقة: ${error.message}');
    } catch (error) {
      _showErrorMessage('حدث خطأ غير متوقع: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        duration: const Duration(seconds: 3),
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
                  _buildSignupForm(),
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
              errorBuilder: (context, error, stackTrace) => Icon(
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

  /// بناء نموذج التسجيل
  Widget _buildSignupForm() {
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
          _buildNameField(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 24),
          AccountTypeSelector(
            onAccountTypeSelected: (accountType) {
              setState(() {
                _selectedAccountType = accountType;
              });
            },
            initialAccountType: _selectedAccountType,
          ),
          const SizedBox(height: 24),
          _buildSignupButton(),
          const SizedBox(height: 16),
          _buildLoginLink(),
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
          'إنشاء حساب جديد',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أدخل بياناتك لإنشاء حساب جديد',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  /// بناء حقل إدخال الاسم
  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          hintText: 'الاسم الكامل',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(
            Icons.person_outline,
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

  /// بناء حقل إدخال البريد الإلكتروني
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _emailController,
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

  /// بناء حقل إدخال كلمة المرور
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: 'كلمة المرور',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: app_colors.AppColors.primary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
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

  /// بناء زر إنشاء الحساب
  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: app_colors.AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Text(
                'إنشاء حساب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  /// بناء رابط الانتقال إلى شاشة تسجيل الدخول
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('لديك حساب بالفعل؟', style: TextStyle(color: Colors.grey[600])),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              color: app_colors.AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
