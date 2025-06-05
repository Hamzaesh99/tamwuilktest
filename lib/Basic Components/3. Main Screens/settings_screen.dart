import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/shared/utils/user_provider.dart';
import '../../../Routing/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('إدارة الحساب'),
            ),
            const ListTile(
              leading: Icon(Icons.notifications),
              title: Text('الإشعارات'),
            ),
            const ListTile(
              leading: Icon(Icons.security),
              title: Text('الأمان والخصوصية'),
            ),
            const ListTile(
              leading: Icon(Icons.help),
              title: Text('المساعدة والدعم'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
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
            ),
          ],
        ),
      ),
    );
  }
}
