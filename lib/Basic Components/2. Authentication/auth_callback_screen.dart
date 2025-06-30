import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../Routing/app_routes.dart';
import 'package:tamwuilktest/core/services/logger_service.dart';
import 'package:tamwuilktest/core/shared/utils/user_provider.dart'
    as user_provider;
import '../../../core/shared/widgets/auth_success_message.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String _errorMessage = '';

  // إضافة متغير للتحكم في الكود المستخدم للمصادقة
  String? code;

  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      final client = Supabase.instance.client;
      String? code;

      // التحقق من وجود الرمز في المعلمات المرسلة
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('code')) {
        code = args['code'] as String;
        LoggerService.info(
          'تم استلام رمز المصادقة من المعلمات: $code',
          tag: 'AuthCallback',
        );
      } else {
        // محاولة استخراج الرمز من عنوان URL
        final uri = Uri.parse(Uri.base.toString());
        code = uri.queryParameters['code'];

        LoggerService.info(
          'معالجة رابط إعادة التوجيه: ${uri.toString()}',
          tag: 'AuthCallback',
        );
      }

      if (code != null) {
        LoggerService.info(
          'تم العثور على رمز المصادقة: $code',
          tag: 'AuthCallback',
        );

        // تبادل الرمز للحصول على جلسة
        await client.auth.exchangeCodeForSession(code);

        // تحديث بيانات المستخدم في UserProvider
        final authUser = client.auth.currentUser;
        if (authUser != null) {
          // استيراد مزود المستخدم
          if (!mounted) return; // Add mounted check before using context
          final userProvider = Provider.of<user_provider.UserProvider>(
            context,
            listen: false,
          );
          await userProvider.setUser(authUser);
          LoggerService.info(
            'تم تحديث بيانات المستخدم بعد تأكيد البريد الإلكتروني',
            tag: 'AuthCallback',
          );
        }

        LoggerService.info('تم إنشاء جلسة المستخدم بنجاح', tag: 'AuthCallback');

        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSuccess = true;
          });

          // توجيه المستخدم تلقائيًا إلى الصفحة الرئيسية بعد فترة قصيرة
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _navigateToHome();
            }
          });
        }
        return;
      }

      // في حالة عدم وجود رمز أو فشل إنشاء الجلسة
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _errorMessage = 'فشل في معالجة رابط المصادقة';
        });
      }
    } catch (error) {
      LoggerService.error(
        'خطأ في معالجة رابط المصادقة: $error',
        tag: 'AuthCallback',
        exception: error,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _errorMessage = 'حدث خطأ أثناء المصادقة: $error';
        });
      }
    }
  }

  void _navigateToHome() {
    AppRoutes.navigateAndRemoveUntil(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF40E0D0), Colors.white],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _isLoading
                  ? _buildLoadingContent()
                  : _isSuccess
                  ? _buildSuccessContent()
                  : _buildErrorContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF40E0D0)),
            strokeWidth: 6,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'جاري المصادقة...',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF40E0D0),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'يرجى الانتظار بينما نقوم بإكمال عملية تسجيل الدخول',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AuthSuccessMessage(
          message: 'تم تسجيل الدخول بنجاح! مرحباً بك في تطبيق تمويلك',
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _navigateToHome,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF40E0D0),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'الذهاب إلى الصفحة الرئيسية',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 60),
        const SizedBox(height: 24),
        const Text(
          'فشل تسجيل الدخول',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () =>
              AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF40E0D0),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'العودة إلى تسجيل الدخول',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
