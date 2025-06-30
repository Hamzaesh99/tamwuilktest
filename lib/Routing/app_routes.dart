import 'package:flutter/material.dart';

// Basic Components Screens
import '../Basic Components/0.Splash Screen/splash_screen.dart';
import '../Basic Components/1. Welcome Screen/welcome_screen.dart';
import '../Basic Components/2. Authentication/login_screen.dart';
import '../Basic Components/2. Authentication/auth_callback_screen.dart';
import '../Basic Components/3. Main Screens/home_screen.dart';
import '../Basic Components/3. Main Screens/explore_screen.dart';
import '../Basic Components/3. Main Screens/chat_screen.dart';
import '../Basic Components/3. Main Screens/notifications_screen.dart';
import '../Basic Components/3. Main Screens/settings_screen.dart';
import '../Basic Components/3. Main Screens/project_create_screen.dart';
import '../Basic Components/3. Main Screens/project_create_details_screen.dart';
import '../Basic Components/3. Main Screens/project_detail_screen.dart';
import '../widgets/auth_state_widget.dart';
import '../Basic Components/3. Main Screens/profile_screen.dart';
import '../Basic Components/3. Main Screens/investor_subscription_screen.dart';
import '../Basic Components/3. Main Screens/project_owner_subscription_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String createProject = '/create-project';
  static const String projectDetails = '/project-details';
  static const String createProjectDetails = '/create-project-details';
  static const String authCallback = '/auth-callback';
  static const String success = '/success';
  static const String auth = '/auth';
  static const String profile = '/profile'; // Add profile route
  static const String jsSuccess =
      '/js-success'; // إضافة مسار صفحة نجاح JavaScript
  static const String verifyEmail = '/verify-email'; // Add verify email route
  static const String productDetails =
      '/product-details'; // Add product details route
  static const String investorSubscription = '/investor-subscription';
  static const String projectOwnerSubscription = '/project-owner-subscription';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      auth: (context) => const AuthStateWidget(),
      home: (context) => HomePage(),
      explore: (context) => const ExploreScreen(),
      chat: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ChatScreen(chatId: args['chatId'] as String);
      },
      notifications: (context) => const NotificationsScreen(),
      settings: (context) => const SettingsScreen(),
      createProject: (context) => const ProjectCreateScreen(),
      projectDetails: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ProjectDetailScreen(project: args['project']);
      },
      createProjectDetails: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ProjectCreateDetailsScreen(
          projectName: args['projectName'] as String,
          amount: args['amount'] as String,
          description: args['description'] as String,
          projectCategory: args['projectCategory'] as String,
          city: args['city'] as String,
          singleInvestor: args['singleInvestor'] as bool,
          investors: args['investors'] as int,
        );
      },

      authCallback: (context) {
        // Assuming AuthCallbackScreen handles the authentication logic
        // and then navigates based on the result.
        // We will modify AuthCallbackScreen to navigate to /success on success.
        return const AuthCallbackScreen();
      },
      profile: (context) => const ProfileScreen(),
      investorSubscription: (context) => const InvestorSubscriptionScreen(),
      projectOwnerSubscription: (context) =>
          const ProjectOwnerSubscriptionScreen(),
    };
  }

  // Helper method to handle navigation with animations
  // Helper method to handle navigation with animations
  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Helper method to replace current screen
  static void navigateReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Helper method to clear stack and navigate
  static void navigateAndRemoveUntil(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }
}
