import 'package:flutter/material.dart';

class ProjectCreateDetailsScreen extends StatelessWidget {
  final String projectName;
  final String amount;
  final String description;
  final String projectCategory;
  final String city;
  final bool singleInvestor;
  final int investors;

  const ProjectCreateDetailsScreen({
    super.key,
    required this.projectName,
    required this.amount,
    required this.description,
    required this.projectCategory,
    required this.city,
    required this.singleInvestor,
    required this.investors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المشروع'),
        backgroundColor: Colors.teal, // لون الفيروزي
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اسم المشروع:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(projectName, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            const Text(
              'المبلغ المطلوب:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(amount, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            const Text(
              'وصف المشروع:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            const Text(
              'عدد المستثمرين:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text('$investors', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // منطق العودة إلى شاشة إنشاء المشروع
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('تعديل التفاصيل'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProjectCreateDetailsScreen(
      projectName: 'مشروع تطوير عقاري',
      amount: '500,000 ر.س',
      description: 'وصف مختصر لمشروع تطوير عقاري.',
      projectCategory: 'عقاري',
      city: 'طرابلس',
      singleInvestor: true,
      investors: 45,
    ),
  ));
}
