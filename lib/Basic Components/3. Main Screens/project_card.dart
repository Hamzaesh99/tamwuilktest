import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tamwuilktest/core/shared/utils/user_role_manager.dart';
import 'package:tamwuilktest/core/shared/models/project_model.dart';
import 'package:tamwuilktest/Basic Components/3. Main Screens/project_detail_screen.dart';
import 'package:tamwuilktest/core/shared/utils/user_provider.dart';
import 'package:tamwuilktest/core/shared/models/user_model.dart' as user_model;
import 'package:tamwuilktest/core/models/app_user.dart';

class ProjectCard extends StatelessWidget {
  final String projectId;
  final String projectName;
  final Project? project; // إضافة معلومات المشروع كاملة

  const ProjectCard({
    super.key,
    required this.projectId,
    required this.projectName,
    this.project,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    // استخدام UserRoleManager للتحقق من دور المستخدم
    final bool isInvestor = UserRoleManager.isInvestor(
      _convertToUserModel(currentUser),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المشروع (إذا كانت متوفرة)
          if (project?.imageUrl != null && project!.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                project!.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // وصف المشروع المختصر (إذا كان متوفرًا)
                if (project?.description != null)
                  Text(
                    project!.description.length > 100
                        ? '${project!.description.substring(0, 100)}...'
                        : project!.description,
                    style: const TextStyle(color: Color(0xFF616161)),
                  ),
                const SizedBox(height: 12),
                // معلومات التمويل (إذا كانت متوفرة)
                if (project != null)
                  LinearProgressIndicator(
                    value: project!.fundingGoal > 0
                        ? project!.currentFunding / project!.fundingGoal
                        : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                  ),
                if (project != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(project!.currentFunding / project!.fundingGoal * 100).toStringAsFixed(1)}%',
                        ),
                        Text(
                          '${project!.currentFunding} / ${project!.fundingGoal} ريال',
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر عرض التفاصيل
                    ElevatedButton(
                      onPressed: () => _viewProjectDetails(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('عرض التفاصيل'),
                    ),
                    // زر تقديم العرض (للمستثمرين فقط)
                    if (isInvestor)
                      ElevatedButton(
                        onPressed: () => _submitOffer(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('تقديم عرض'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // عرض تفاصيل المشروع
  void _viewProjectDetails(BuildContext context) {
    if (project != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectDetailScreen(
            project: project!,
            currentUser: _convertToUserModel(userProvider.currentUser),
          ),
        ),
      );
    }
  }

  // Helper method to convert AppUser to User model
  user_model.User? _convertToUserModel(AppUser? appUser) {
    if (appUser == null) return null;

    return user_model.User(
      id: appUser.id,
      name: '', // Default empty name
      email: appUser.email,
      userRole: appUser.userRole ?? 'guest',
      createdAt: DateTime.now(), // Default to current time
    );
  }

  // عرض نافذة تقديم العرض
  void _submitOffer(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // التحقق من تسجيل الدخول
    if (userProvider.currentUser == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    // التحقق من أن المستخدم مستثمر
    if (!UserRoleManager.isInvestor(
      _convertToUserModel(userProvider.currentUser),
    )) {
      _showInvestorOnlyDialog(context);
      return;
    }

    // إذا كان المشروع متوفر، انتقل إلى صفحة التفاصيل مع التمرير إلى قسم تقديم العرض
    if (project != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectDetailScreen(
            project: project!,
            currentUser: _convertToUserModel(userProvider.currentUser),
            initialTabIndex: 1, // افتراض أن تبويب العروض هو الثاني
          ),
        ),
      );
    } else {
      // إذا لم تكن معلومات المشروع متوفرة، اعرض نافذة منبثقة بسيطة
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تقديم عرض'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('يرجى إدخال تفاصيل العرض الخاص بك'),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'قيمة العرض (ريال)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'رسالة',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                // تنفيذ منطق إرسال العرض هنا
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرسال العرض بنجاح')),
                );
              },
              child: const Text('إرسال'),
            ),
          ],
        ),
      );
    }
  }

  // عرض رسالة تنبيه بضرورة تسجيل الدخول
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الدخول مطلوب'),
        content: const Text('يرجى تسجيل الدخول أولاً لتتمكن من تقديم عرض.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  // عرض رسالة تنبيه بأن هذه الميزة للمستثمرين فقط
  void _showInvestorOnlyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('للمستثمرين فقط'),
        content: const Text('عذراً، هذه الميزة متاحة للمستثمرين فقط.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
