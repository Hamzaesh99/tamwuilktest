import 'package:flutter/material.dart';
import '../../../Routing/app_routes.dart'; // Assuming AppRoutes is needed for navigation
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/shared/utils/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder user data - replace with actual data fetching logic
    const String userName = 'اسم المستخدم';
    const String userEmail = 'user.email@example.com';
    const String profileImageUrl =
        'assets/images/icon.png'; // Placeholder image

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Edit Profile functionality not implemented yet.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Profile Picture
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(profileImageUrl),
              backgroundColor: Colors.grey[200], // Placeholder background
            ),
          ),
          const SizedBox(height: 16.0),
          // User Name
          Center(
            child: Text(
              userName,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          // User Email
          Center(
            child: Text(
              userEmail,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24.0),
          // Placeholder for additional sections (e.g., Projects, Settings)
          Card(
            elevation: 2.0,
            child: ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('مشاريعي'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'My Projects functionality not implemented yet.',
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            elevation: 2.0,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('الإعدادات'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                AppRoutes.navigateTo(context, AppRoutes.settings);
              },
            ),
          ),
          Card(
            elevation: 2.0,
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('الإشعارات'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                AppRoutes.navigateTo(context, AppRoutes.notifications);
              },
            ),
          ),
          const SizedBox(height: 24.0),
          // Logout Button
          ElevatedButton(
            onPressed: () async {
              // تنفيذ تسجيل الخروج
              await Supabase.instance.client.auth.signOut();

              // مسح بيانات المستخدم من UserProvider
              if (context.mounted) {
                Provider.of<UserProvider>(context, listen: false).clearUser();

                // عرض رسالة نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
                );

                // الانتقال إلى شاشة الترحيب
                AppRoutes.navigateAndRemoveUntil(context, AppRoutes.welcome);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Button color
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
