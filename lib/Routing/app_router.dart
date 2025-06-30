import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Basic Components/0.Splash Screen/splash_screen.dart';
import '../../Basic Components/1. Welcome Screen/welcome_screen.dart';
import 'package:tamwuilktest/features/home/presentation/screens/home_screen.dart';
import 'package:tamwuilktest/features/auth/presentation/screens/login_screen.dart';
import 'package:tamwuilktest/features/auth/presentation/screens/register_screen.dart';
import 'package:tamwuilktest/features/profile/presentation/screens/profile_screen.dart';
import 'package:tamwuilktest/features/settings/presentation/screens/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String home = '/home_screen';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('الصفحة غير موجودة: ${state.uri.path}')),
    ),
  );
}
