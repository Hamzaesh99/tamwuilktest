import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tamwuilktest/Basic Components/1. Welcome Screen/welcome_screen.dart';
import 'package:tamwuilktest/Basic Components/3. Main Screens/home_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:developer';

class AuthStateWidget extends StatefulWidget {
  const AuthStateWidget({super.key});

  @override
  State<AuthStateWidget> createState() => _AuthStateWidgetState();
}

class _AuthStateWidgetState extends State<AuthStateWidget>
    with WidgetsBindingObserver {
  StreamSubscription? _sub;
  AppLinks? _appLinks;

  // إضافة متغير للتايمر الذي سيتحقق من صلاحية الجلسة
  Timer? _sessionCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // إعداد معالجة الروابط العميقة
    _appLinks = AppLinks();
    _sub = _appLinks!.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null && uri.scheme == 'tamwuilk') {
          if (uri.host == 'callback' && uri.path == '/home_screen') {
            if (mounted) {
              Navigator.pushNamed(context, '/home_screen');
              // بدء التايمر للتحقق من صلاحية الجلسة
              _startSessionExpiryCheck();
            }
          }
        }
      },
      onError: (err) {
        log('خطأ في معالجة الروابط العميقة: $err');
      },
    );

    // تحسين التعامل مع تغييرات حالة المصادقة
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        final AuthChangeEvent event = data.event;
        if (event == AuthChangeEvent.signedIn) {
          // تم تسجيل الدخول بنجاح
          if (mounted) {
            setState(() {});
            // بدء التايمر للتحقق من صلاحية الجلسة
            _startSessionExpiryCheck();
          }
        } else if (event == AuthChangeEvent.signedOut) {
          // تم تسجيل الخروج
          if (mounted) setState(() {});
          // إيقاف التايمر عند تسجيل الخروج
          _sessionCheckTimer?.cancel();
        }
      },
      onError: (error) {
        // معالجة الأخطاء
        log('خطأ في حالة المصادقة: $error');
      },
    );

    // التحقق من حالة الجلسة عند بدء التطبيق
    _checkCurrentSession();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _appLinks = null;
    _sessionCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // إعادة بناء الواجهة عند استئناف التطبيق للتأكد من تحديث حالة المصادقة
    if (state == AppLifecycleState.resumed) {
      if (mounted) setState(() {});
    }
  }

  // دالة للتحقق من الجلسة الحالية عند بدء التطبيق
  void _checkCurrentSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      // بدء التايمر للتحقق من صلاحية الجلسة
      _startSessionExpiryCheck();
    }
  }

  // دالة لبدء التايمر للتحقق من صلاحية الجلسة
  void _startSessionExpiryCheck() {
    // إلغاء التايمر الحالي إذا كان موجودًا
    _sessionCheckTimer?.cancel();

    // إنشاء تايمر جديد يتحقق كل دقيقة من صلاحية الجلسة
    _sessionCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkSessionExpiry();
    });

    // التحقق فورًا من صلاحية الجلسة
    _checkSessionExpiry();
  }

  // دالة للتحقق من صلاحية الجلسة
  void _checkSessionExpiry() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      );
      final now = DateTime.now();

      // إذا انتهت صلاحية الجلسة، قم بتسجيل الخروج تلقائيًا
      if (now.isAfter(expiresAt)) {
        log('انتهت صلاحية الجلسة، تسجيل الخروج تلقائيًا');
        Supabase.instance.client.auth.signOut();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام FutureBuilder لتجنب مشاكل التركيز
    return FutureBuilder<Session?>(
      future: Future.value(Supabase.instance.client.auth.currentSession),
      builder: (context, snapshot) {
        // Check if user is authenticated
        final session = snapshot.data;

        if (session != null) {
          // User is logged in, show home screen using Navigator
          return const HomePage();
        } else {
          // User is not logged in, show welcome screen
          return const WelcomeScreen();
        }
      },
    );
  }
}
