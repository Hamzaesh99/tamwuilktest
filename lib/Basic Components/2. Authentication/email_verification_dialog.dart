import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailVerificationDialog extends StatelessWidget {
  const EmailVerificationDialog({super.key});

  /// إنشاء مربع حوار لتأكيد البريد الإلكتروني
  static Future<void> show() {
    return Get.dialog(
      EmailVerificationDialog(),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'تأكيد البريد الإلكتروني',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 50),
          SizedBox(height: 16),
          Text(
            'تم تأكيد بريدك الإلكتروني بنجاح',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              // إغلاق مربع الحوار
              Navigator.of(context).pop();
              // الانتقال إلى الشاشة الرئيسية
              Get.offAllNamed('/home');
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('موافق', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
