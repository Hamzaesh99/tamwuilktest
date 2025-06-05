import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthExample extends StatefulWidget {
  const GoogleAuthExample({super.key});

  @override
  State<GoogleAuthExample> createState() => _GoogleAuthExampleState();
}

class _GoogleAuthExampleState extends State<GoogleAuthExample> {
  bool _isLoading = false;
  String _status = '';

  // دالة تسجيل الدخول باستخدام Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _status = 'جاري بدء عملية تسجيل الدخول...';
    });

    try {
      // استدعاء دالة المصادقة من Supabase
      // ملاحظة: تأكد من أن عنوان إعادة التوجيه يتطابق مع ما هو مسجل في لوحة تحكم Supabase
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.example.tamwuilk://home_screen',
      );

      // التحقق من نجاح بدء عملية المصادقة
      if (response) {
        setState(() {
          _status =
              'تم بدء عملية المصادقة بنجاح. انتظار استكمال المستخدم للعملية...';
        });
      } else {
        setState(() {
          _status = 'فشل في بدء عملية تسجيل الدخول';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'حدث خطأ: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مثال المصادقة مع Google')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // زر تسجيل الدخول باستخدام Google
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: Image.asset(
                  'assets/images/google.png',
                  width: 24,
                  height: 24,
                ),
                label: Text(
                  _isLoading
                      ? 'جاري التحميل...'
                      : 'تسجيل الدخول باستخدام Google',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // عرض حالة المصادقة
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // معلومات توضيحية
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملاحظات هامة:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. تأكد من أن عنوان إعادة التوجيه (tamwuilk://login-callback) متطابق في:',
                        style: TextStyle(fontSize: 14),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Text(
                          '- ملف AndroidManifest.xml\n- كود Flutter (redirectTo)\n- إعدادات Supabase (Site URL + Redirect URL)',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2. يجب تكوين مشروع Google Cloud Platform وإضافة Client ID في إعدادات Supabase.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
