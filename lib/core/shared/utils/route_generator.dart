import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // You can add your routing logic here based on settings.name
    // For now, we'll just return a basic route.
    return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('Route not found for ${settings.name}'))));
  }
}