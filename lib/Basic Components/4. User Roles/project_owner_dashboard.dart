import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';  // Will be needed when implementing state management
// import '../../core/shared/utils/state_manager.dart';  // Will be needed for user state management

class ProjectOwnerDashboard extends StatefulWidget {
  const ProjectOwnerDashboard({super.key});

  @override
  State<ProjectOwnerDashboard> createState() => _ProjectOwnerDashboardState();
}

class _ProjectOwnerDashboardState extends State<ProjectOwnerDashboard> {
  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context); // Provider seems unused here too, commenting out for now.
    // final currentUser = userProvider.currentUser; // Removed unused variable

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم صاحب المشروع'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ملخص المشاريع
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملخص المشاريع',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'المشاريع النشطة',
                            '0', // سيتم تحديثه لاحقاً
                          ),
                          _buildStatCard(
                            'إجمالي التمويل',
                            '0 ريال', // سيتم تحديثه لاحقاً
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // المشاريع الحالية
              const Text(
                'المشاريع الحالية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // هنا سيتم إضافة قائمة المشاريع الحالية

              const SizedBox(height: 24),

              // طلبات التمويل
              const Text(
                'طلبات التمويل',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // هنا سيتم إضافة قائمة طلبات التمويل
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // إضافة مشروع جديد
          Navigator.pushNamed(context, '/add_project');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(
                (255 * 0.1).round()), // Replaced deprecated withOpacity
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1BC5BD),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
