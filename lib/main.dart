import 'dart:async';
//import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tamwuilktest/core/shared/utils/user_provider.dart';
import 'package:tamwuilktest/Routing/app_routes.dart' as app_routes;
import 'package:tamwuilktest/core/services/logger_service.dart';
import 'package:tamwuilktest/core/services/app_info_service.dart';
import 'package:tamwuilktest/core/shared/constants/app_colors.dart'
    as app_colors;
import 'package:tamwuilktest/Basic Components/1. Welcome Screen/welcome_content.dart';
import 'dart:ui';
import 'package:tamwuilktest/core/shared/widgets/auth_success_message.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    if (kIsWeb) {
      FlutterError.onError = (FlutterErrorDetails details) {
        LoggerService.error(
          'خطأ في تطبيق Flutter Web: \u001b[31m[0m${details.exception}',
          tag: 'FlutterWeb',
          exception: details.exception,
        );
        FlutterError.presentError(details);
      };
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        if (error.toString().contains('Failed to load font') ||
            error.toString().contains('canvaskit')) {
          LoggerService.warning(
            'تم تجاهل خطأ تحميل المورد: $error',
            tag: 'ResourceLoading',
          );
          return true;
        }
        return false;
      };
    }

    final appLinks = AppLinks();
    if (!kIsWeb) {
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
      LoggerService.info(
        'تفعيل معالجة الروابط العميقة في بيئة الويب',
        tag: 'DeepLinks',
      );
      try {
        final uri = Uri.base;
        LoggerService.info(
          'معالجة رابط الويب: ${uri.toString()}',
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

    final appInfoService = AppInfoService();
    await appInfoService.initialize();
    LoggerService.info(
      'تم تهيئة خدمة معلومات التطبيق: ${appInfoService.packageName}',
      tag: 'AppInfo',
    );

    await Supabase.initialize(
      url: 'https://sphjnptgsizxduvurbsu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwaGpucHRnc2l6eGR1dnVyYnN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4Mjk1MjQsImV4cCI6MjA2MzQwNTUyNH0.L2XXvayg6OgWV9X9q4wfQEaabn9hxLYq3ZI4gFc3aRs',
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
  } catch (e, stack) {
    LoggerService.error(
      'حدث خطأ أثناء تهيئة التطبيق: $e',
      tag: 'AppInit',
      exception: e,
      stackTrace: stack,
    );
  }
}

Future<void> _handleIncomingLink(Uri uri) async {
  LoggerService.info(
    'معالجة الرابط الوارد: ${uri.toString()}',
    tag: 'DeepLinks',
  );
  if (uri.path == '/home_screen' ||
      uri.path.contains('/home_screen') ||
      uri.toString().contains('home_screen')) {
    LoggerService.info(
      'تم اكتشاف مسار home_screen، جاري التوجيه إلى الصفحة الرئيسية',
      tag: 'DeepLinks',
    );
    if (navigatorKey.currentContext != null) {
      showCustomSuccessMessage(
        navigatorKey.currentContext!,
        'تم تفعيل حسابك بنجاح! استمتع بتجربة تمويلك.',
      );
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        app_routes.AppRoutes.home,
        (route) => false,
      );
    });
    return;
  }
  // ... باقي منطق الروابط العميقة كما هو في الكود الحالي ...
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        _authSubscription = Supabase.instance.client.auth.onAuthStateChange
            .listen((data) {
              final session = data.session;
              final event = data.event;
              if (session != null) {
                userProvider.setUser(session.user);
                if (event == AuthChangeEvent.signedIn ||
                    event == AuthChangeEvent.userUpdated) {
                  setState(() {
                    _showAuthSuccessMessage = true;
                  });
                  LoggerService.info(
                    'تم إكمال عملية المصادقة بنجاح: ${event.name}',
                    tag: 'Authentication',
                  );
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _showAuthSuccessMessage = false;
                      });
                    }
                  });
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (navigatorKey.currentState != null) {
                      navigatorKey.currentState?.pushNamedAndRemoveUntil(
                        app_routes.AppRoutes.home,
                        (route) => false,
                      );
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
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      routes: app_routes.AppRoutes.getRoutes(),
      onGenerateRoute: (settings) {
        final routes = app_routes.AppRoutes.getRoutes();
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
