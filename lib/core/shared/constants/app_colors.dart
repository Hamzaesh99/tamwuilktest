import 'package:flutter/material.dart';

/// Colores usados en toda la aplicación
class AppColors {
  // Colores principales
  static const Color primary = Color(0xFF03DAC6); // Removed extra parenthesis
  static const Color secondary = Color.fromARGB(255, 240, 245, 244);
  static const Color accent = Color(0xFFFFA726);

  // Colores de fondo
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color darkBackground = Color(0xFF121212);

  // Colores de texto
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;

  // Estados y feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF2196F3);

  // Estados de botones
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = Color(0xFF757575);
  static const Color buttonDisabled = Color(0xFFBDBDBD);

  // Otros colores útiles
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x40000000);

  // Colores para funcionalidades específicas
  static const Color investmentGreen = Color(0xFF4CAF50);
  static const Color projectBlue = Color(0xFF2196F3);
  static const Color entrepreneurOrange = Color(0xFFFF9800);
}
