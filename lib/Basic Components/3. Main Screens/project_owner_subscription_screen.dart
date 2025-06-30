import 'package:flutter/material.dart';

class ProjectOwnerSubscriptionScreen extends StatelessWidget {
  const ProjectOwnerSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اشتراك صاحب المشروع')),
      body: const Center(
        child: Text('هذه صفحة اشتراك صاحب المشروع. يمكنك تطويرها لاحقاً.'),
      ),
    );
  }
}
