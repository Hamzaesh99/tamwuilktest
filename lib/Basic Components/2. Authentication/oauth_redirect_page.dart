import 'dart:async';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

/// صفحة إعادة التوجيه بعد المصادقة عبر OAuth
class OAuthRedirectPage extends StatefulWidget {
  const OAuthRedirectPage({super.key});

  @override
  State<OAuthRedirectPage> createState() => _OAuthRedirectPageState();
}

class _OAuthRedirectPageState extends State<OAuthRedirectPage> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _handleAuth();
  }

  void _handleAuth() {
    final uri = Uri.base;
    final code = uri.queryParameters['code'];

    if (code != null && code.isNotEmpty) {
      // محاكاة تأخير المصادقة
      Timer(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        // إعادة التوجيه للصفحة الرئيسية بعد 3 ثواني
        Timer(const Duration(seconds: 3), () {
          html.window.location.href = '/';
        });
      });
    } else {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _error = 'لم يتم العثور على رمز المصادقة';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF40E0D0), Colors.white],
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading) ...[
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(strokeWidth: 6),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'جاري المصادقة...',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF40E0D0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'يرجى الانتظار بينما نقوم بإكمال عملية تسجيل الدخول',
                      textAlign: TextAlign.center,
                    ),
                  ] else if (_isSuccess) ...[
                    const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Color(0xFF40E0D0),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'تم تسجيل الدخول بنجاح!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF40E0D0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'مرحباً بك في تمويلك. سيتم توجيهك للصفحة الرئيسية.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () => html.window.location.href = '/',
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF40E0D0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 28,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      child: const Text('العودة للرئيسية'),
                    ),
                  ] else ...[
                    const SizedBox(height: 25),
                    const Text(
                      'حدث خطأ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _error ?? 'حدث خطأ أثناء العملية',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed:
                          () =>
                              html.window.location.href =
                                  '/web/OAuth/index.html',
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF40E0D0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 28,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
