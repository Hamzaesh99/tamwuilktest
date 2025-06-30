import 'package:flutter/material.dart';

class InvestorSubscriptionScreen extends StatelessWidget {
  const InvestorSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اشتراك المستثمر')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'هذه صفحة اشتراك المستثمر. يمكنك تطويرها لاحقاً.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            // تمت إزالة زر الاشتراك
          ],
        ),
      ),
    );
  }
}
