import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // بعد ثانيتين انتقل مباشرة إلى شاشة welcome
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // بقية الكود كما هو
    return Scaffold(
      backgroundColor: const Color.fromRGBO(
        8,
        225,
        215,
        1,
      ), // نفس قيمة Colors.teal[400]
      body: Center(
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(128, 38, 166, 154),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/h1.png', fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
