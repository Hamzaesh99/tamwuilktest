import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Routing/app_routes.dart';
import 'package:tamwuilktest/core/services/logger_service.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String _errorMessage = '';

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

        await client.auth.exchangeCodeForSession(code);

        LoggerService.info('تم إنشاء جلسة المستخدم بنجاح', tag: 'AuthCallback');

        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSuccess = true;
          });

          // توجيه المستخدم تلقائيًا إلى الصفحة الرئيسية بعد فترة قصيرة
          Future.delayed(const Duration(seconds: 2), () {
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.teal)
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isSuccess) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text(
            'تم إكمال عملية المصادقة بنجاح!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'جاري توجيهك إلى الصفحة الرئيسية...',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'تم تسجيل الدخول بنجاح!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'مرحباً بك في تطبيق تمويلك',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _navigateToHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 80),
          const SizedBox(height: 20),
          const Text(
            'فشل تسجيل الدخول',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () =>
                AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
}
