import 'package:flutter/material.dart';
import '../../../Routing/app_routes.dart';

/// شاشة النجاح بعد المصادقة عبر JavaScript
class JsSuccessScreen extends StatefulWidget {
  const JsSuccessScreen({super.key});

  @override
  State<JsSuccessScreen> createState() => _JsSuccessScreenState();
}

class _JsSuccessScreenState extends State<JsSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _handleSuccess();
  }

  Future<void> _handleSuccess() async {
    // تأخير قصير للسماح بتحديث الواجهة
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      // التوجيه إلى الصفحة الرئيسية
      AppRoutes.navigateAndRemoveUntil(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'تم تسجيل الدخول بنجاح',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'جاري التوجيه إلى الصفحة الرئيسية...',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.green),
          ],
        ),
      ),
    );
  }
}
