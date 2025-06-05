import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/shared/utils/state_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'ar';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final settings = userProvider.currentUser?.settings;
    if (settings != null) {
      setState(() {
        _notificationsEnabled = settings['notifications_enabled'] ?? true;
        _darkModeEnabled = settings['dark_mode_enabled'] ?? false;
        _selectedLanguage = settings['language'] ?? 'ar';
      });
    }
  }

  void _updateSettings() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserSettings({
      'notifications_enabled': _notificationsEnabled,
      'dark_mode_enabled': _darkModeEnabled,
      'language': _selectedLanguage,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          children: [
            // إعدادات الإشعارات
            ListTile(
              title: const Text('الإشعارات'),
              subtitle: const Text('تفعيل/تعطيل الإشعارات'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _updateSettings();
                },
              ),
            ),
            const Divider(),

            // إعدادات المظهر
            ListTile(
              title: const Text('الوضع الليلي'),
              subtitle: const Text('تفعيل/تعطيل الوضع الليلي'),
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                  _updateSettings();
                },
              ),
            ),
            const Divider(),

            // إعدادات اللغة
            ListTile(
              title: const Text('اللغة'),
              subtitle: Text(_selectedLanguage == 'ar' ? 'العربية' : 'English'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('اختر اللغة'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('العربية'),
                          leading: Radio<String>(
                            value: 'ar',
                            groupValue: _selectedLanguage,
                            onChanged: (value) {
                              setState(() {
                                _selectedLanguage = value!;
                              });
                              _updateSettings();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('English'),
                          leading: Radio<String>(
                            value: 'en',
                            groupValue: _selectedLanguage,
                            onChanged: (value) {
                              setState(() {
                                _selectedLanguage = value!;
                              });
                              _updateSettings();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(),

            // معلومات التطبيق
            const ListTile(
              title: Text('عن التطبيق'),
              subtitle: Text('الإصدار 1.0.0'),
            ),
            const Divider(),

            // سياسة الخصوصية
            ListTile(
              title: const Text('سياسة الخصوصية'),
              onTap: () {
                // التنقل إلى صفحة سياسة الخصوصية
              },
            ),
            const Divider(),

            // شروط الاستخدام
            ListTile(
              title: const Text('شروط الاستخدام'),
              onTap: () {
                // التنقل إلى صفحة شروط الاستخدام
              },
            ),
          ],
        ),
      ),
    );
  }
}
