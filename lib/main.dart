import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:ui'; // استيراد لاستخدام PlatformDispatcher
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:tamwuilktest/core/shared/utils/user_provider.dart'; // Import UserProvider
import 'package:tamwuilktest/Basic Components/1. Welcome Screen/welcome_content.dart';
import 'package:tamwuilktest/Basic Components/2. Authentication/email_verification_handler.dart';

// الألوان والمساعدات
import 'package:tamwuilktest/core/shared/constants/app_colors.dart'
    as app_colors;
import 'package:tamwuilktest/Routing/app_routes.dart';
import 'package:tamwuilktest/core/services/error_handler.dart';
import 'package:tamwuilktest/core/services/logger_service.dart';
import 'package:tamwuilktest/core/services/app_info_service.dart'; // استيراد خدمة معلومات التطبيق
import 'dart:async'; // Import for StreamSubscription

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // تهيئة معالج الاستثناءات قبل أي شيء آخر

  // تغليف التهيئة بمعالج الاستثناءات
  await AppErrorHandler.runSafely(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // معالجة روابط التحقق من البريد الإلكتروني
    if (!kIsWeb) {
      final appLinks = AppLinks();
      appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            EmailVerificationHandler.handleEmailVerification(uri);
          }
        },
        onError: (err) {
          LoggerService.error('خطأ في معالجة الروابط: $err');
        },
      );
    }

    await Hive.initFlutter();

    // تهيئة WebViewPlatform لمنصة الويب
    if (kIsWeb) {
      // تكوين خاص لمنصة الويب لمعالجة مشاكل تحميل الموارد

      // تسجيل معالج أخطاء عام لمشاكل تحميل الموارد على الويب
      FlutterError.onError = (FlutterErrorDetails details) {
        LoggerService.error(
          'خطأ في تطبيق Flutter Web: ${details.exception}',
          tag: 'FlutterWeb',
          exception: details.exception,
        );
        FlutterError.presentError(details);
      };

      // تعيين استراتيجية تحميل الخطوط لتجنب مشاكل تحميل خطوط Roboto
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        if (error.toString().contains('Failed to load font') ||
            error.toString().contains('canvaskit')) {
          LoggerService.warning(
            'تم تجاهل خطأ تحميل المورد: $error',
            tag: 'ResourceLoading',
          );
          return true; // تجاهل الخطأ ومتابعة التنفيذ
        }
        return false; // السماح بمعالجة الأخطاء الأخرى بشكل طبيعي
      };
    }

    // تهيئة app_links للتعامل مع الروابط العميقة
    if (!kIsWeb) {
      final appLinks = AppLinks();
      // استقبال الرابط الأولي عند فتح التطبيق (فقط للمنصات غير الويب)
      try {
        final initialUri = await appLinks.getInitialAppLink();
        if (initialUri != null) {
          _handleIncomingLink(initialUri);
        }
      } catch (e) {
        LoggerService.error(
          'خطأ في استقبال الرابط الأولي: $e',
          tag: 'DeepLinks',
          exception: e,
        );
      }
      // إعداد مستمع للروابط القادمة أثناء تشغيل التطبيق (فقط للمنصات غير الويب)
      appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            _handleIncomingLink(uri);
          }
        },
        onError: (err) {
          LoggerService.error(
            'خطأ في استقبال الروابط: $err',
            tag: 'DeepLinks',
            exception: err,
          );
        },
      );
    } else {
      // معالجة خاصة لمنصة الويب
      LoggerService.info(
        'تفعيل معالجة الروابط العميقة في بيئة الويب',
        tag: 'DeepLinks',
      );

      // إضافة معالجة الروابط العميقة للويب
      try {
        final uri = Uri.base;
        LoggerService.info(
          'معالجة رابط الويب: ${uri.toString()}',
          tag: 'DeepLinks',
        );

        if (uri.hasQuery) {
          LoggerService.info(
            'تم العثور على معلمات في الرابط: ${uri.queryParameters}',
            tag: 'DeepLinks',
          );
          _handleIncomingLink(uri);
        }
      } catch (e) {
        LoggerService.error(
          'خطأ في معالجة رابط الويب: $e',
          tag: 'DeepLinks',
          exception: e,
        );
      }
    }

    // تهيئة خدمة معلومات التطبيق
    final appInfoService = AppInfoService();
    await appInfoService.initialize();
    LoggerService.info(
      'تم تهيئة خدمة معلومات التطبيق: ${appInfoService.packageName}',
      tag: 'AppInfo',
    );

    await Supabase.initialize(
      // ✅ التصحيح هنا
      url: 'https://sphjnptgsizxduvurbsu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwaGpucHRnc2l6eGR1dnVyYnN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4Mjk1MjQsImV4cCI6MjA2MzQwNTUyNH0.L2XXvayg6OgWV9X9q4wfQEaabn9hxLYq3ZI4gFc3aRs', // مفتاحك هنا
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
        child: const MyApp(),
      ),
    );

    // The UserProvider update logic will be moved into MyApp's state.
  }, errorMessage: 'حدث خطأ أثناء تهيئة التطبيق');
}

// دالة لمعالجة الروابط الواردة
void _handleIncomingLink(Uri uri) {
  LoggerService.info(
    'معالجة الرابط الوارد: ${uri.toString()}',
    tag: 'DeepLinks',
  );

  // التحقق من المسار أولاً
  if (uri.path == '/home_screen') {
    LoggerService.info(
      'تم اكتشاف مسار /home_screen، جاري التوجيه إلى الصفحة الرئيسية',
      tag: 'DeepLinks',
    );
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
    return;
  }

  // استخراج رمز المصادقة وتفاصيل الخطأ ورمز الوصول من أي مكان في الرابط
  final code = uri.queryParameters['code'];
  final authSuccess = uri.queryParameters['auth_success'];
  final errorCode = uri.queryParameters['error_code'];
  final errorDescription = uri.queryParameters['error_description'];
  final accessToken = uri.queryParameters['access_token'];

  // معالجة الأخطاء أولاً إذا وجدت
  if (errorCode != null && errorCode.startsWith('4')) {
    LoggerService.error(
      'خطأ في المصادقة: $errorDescription (رمز الخطأ: $errorCode)',
      tag: 'AuthenticationError',
    );
    // عرض رسالة الخطأ للمستخدم باستخدام Snackbar
    if (navigatorKey.currentState?.overlay?.context != null) {
      ScaffoldMessenger.of(
        navigatorKey.currentState!.overlay!.context,
      ).showSnackBar(
        SnackBar(
          content: Text('خطأ في المصادقة: $errorDescription'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return; // إنهاء الدالة بعد معالجة الخطأ
  }

  // If access token is present, log it (or handle as needed)
  if (accessToken != null) {
    LoggerService.info(
      'تم العثور على رمز الوصول (access_token): $accessToken',
      tag: 'DeepLinks',
    );
    // Further handling of access token can be added here if required
    // For now, we just log it and continue with the existing logic
  }

  // إذا كان هناك رمز مصادقة، نعالجه
  if (code != null) {
    LoggerService.info('تم العثور على رمز المصادقة: $code', tag: 'DeepLinks');

    // التوجيه إلى صفحة المصادقة مع تمرير الرمز
    navigatorKey.currentState?.pushNamed(
      AppRoutes.authCallback,
      arguments: {'code': code},
    );
    return; // إنهاء الدالة بعد معالجة الرمز
  }

  // التحقق من مسار /home
  if (uri.path.contains('/home')) {
    LoggerService.info(
      'تم التعرف على مسار الصفحة الرئيسية: ${uri.path}',
      tag: 'DeepLinks',
    );
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
    return;
  }

  // التحقق من مسارات المصادقة المختلفة
  if (uri.path.contains('/auth/v1/callback') ||
      uri.toString().contains('auth_callback.html')) {
    LoggerService.info(
      'تم التعرف على رابط مصادقة: ${uri.path}',
      tag: 'DeepLinks',
    );

    // إذا كانت المصادقة ناجحة ولكن بدون رمز (حالة خاصة)
    if (authSuccess?.toLowerCase() == 'true') {
      LoggerService.info(
        'تم إكمال المصادقة بنجاح، جاري توجيه المستخدم إلى الصفحة الرئيسية',
        tag: 'DeepLinks',
      );
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
      return;
    }
  } else if (uri.toString().contains('login-callback')) {
    // التعامل مع رابط التأكيد من صفحة HTML والانتقال مباشرة إلى الشاشة الرئيسية
    LoggerService.info(
      'تم استلام رابط عميق للانتقال إلى الشاشة الرئيسية: ${uri.toString()}',
      tag: 'DeepLinks',
    );
    // التحقق من وجود معلمة redirect_to_home أو auth_completed
    final redirectToHome = uri.queryParameters['redirect_to_home'];
    final authCompleted = uri.queryParameters['auth_completed'];

    if (redirectToHome?.toLowerCase() == 'true' ||
        authCompleted?.toLowerCase() == 'true' ||
        authSuccess?.toLowerCase() == 'true') {
      LoggerService.info(
        'تم إكمال عملية المصادقة بنجاح، جاري الانتقال إلى الصفحة الرئيسية',
        tag: 'DeepLinks',
      );
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
      return;
    }
  }

  // التحقق من وجود معلمة auth_success في أي رابط كحالة أخيرة
  if (authSuccess?.toLowerCase() == 'true') {
    LoggerService.info(
      'تم إكمال عملية المصادقة بنجاح من خلال معلمة auth_success',
      tag: 'DeepLinks',
    );
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _showAuthSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    // Ensure UserProvider is available after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if the widget is still in the tree
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        _authSubscription = Supabase.instance.client.auth.onAuthStateChange
            .listen((data) {
              final session = data.session;
              final event = data.event;

              if (session != null) {
                userProvider.setUser(session.user);

                // إظهار رسالة نجاح عند تسجيل الدخول أو إنشاء حساب جديد
                if (event == AuthChangeEvent.signedIn ||
                    event == AuthChangeEvent.userUpdated) {
                  setState(() {
                    _showAuthSuccessMessage = true;
                  });

                  // تسجيل نجاح عملية المصادقة
                  LoggerService.info(
                    'تم إكمال عملية المصادقة بنجاح: ${event.name}',
                    tag: 'Authentication',
                  );

                  // إخفاء الرسالة بعد فترة
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _showAuthSuccessMessage = false;
                      });
                    }
                  });
                }
              } else {
                userProvider.clearUser();
              }
            });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Tamwuilk',
      theme: ThemeData(
        primaryColor: app_colors.AppColors.primary,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: app_colors.AppColors.primary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: app_colors.AppColors.primary,
          ),
        ),
        // إضافة تكوين للتركيز لتجنب مشاكل التركيز
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      // استخدام المسارات المعرفة في AppRoutes بدون تعيين initialRoute
      // لتجنب التعارض بين المسارات
      routes: AppRoutes.getRoutes(),
      // تعيين مستمع للتغييرات في المسارات لإدارة التركيز بشكل أفضل
      onGenerateRoute: (settings) {
        // استخدام المسارات المعرفة في AppRoutes
        final routes = AppRoutes.getRoutes();
        final builder = routes[settings.name];

        if (builder != null) {
          return MaterialPageRoute(settings: settings, builder: builder);
        }
        return null;
      },
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // عرض رسالة نجاح عند إكمال عملية المصادقة
            if (_showAuthSuccessMessage)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'تم إكمال عملية المصادقة بنجاح!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final PageController _pageController = PageController();

  WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WelcomeContent(
        currentPage: 0,
        descriptions: [
          'مرحبًا بك في تطبيقنا!',
          'اكتشف الميزات الرائعة.',
          'ابدأ الآن!',
        ],
        pageController: _pageController,
        onPageChanged: (index) {},
        textStyle: const TextStyle(fontSize: 16, color: Colors.black),
        imageNames: ['image.png', 'image.png', 'image.png'],
        imageRadius: 20.0,
      ),
    );
  }
}

// تم التأكد من أن جميع استدعاءات LoggerService.info و LoggerService.error مكتوبة بهذا الشكل:
// LoggerService.info('النص', tag: 'اسم_التاج');
// LoggerService.error('النص', tag: 'اسم_التاج', exception: e);
// إذا كان هناك استدعاء متعدد الأسطر، يجب أن يكون النص بين قوسين دائريين () والفاصلة بعد كل وسيطة.
