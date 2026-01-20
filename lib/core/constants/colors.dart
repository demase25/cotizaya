import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - Azul profundo profesional
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  
  // Secondary / Action - Verde éxito
  static const Color secondary = Color(0xFF22C55E);
  static const Color secondaryDark = Color(0xFF16A34A);
  static const Color secondaryLight = Color(0xFF4ADE80);
  
  // Background - Gris muy claro
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  
  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF1E3A8A);
  
  // Budget status colors
  static const Color pending = Color(0xFFEF4444); // Rojo para pendiente
  static const Color paid = Color(0xFF22C55E); // Verde para cobrado
  
  // App specific colors (legacy - mantener para compatibilidad)
  static const Color greenPrimary = Color(0xFF22C55E);
  static const Color greenDark = Color(0xFF16A34A);
  static const Color redPending = Color(0xFFEF4444);
  static const Color blueHeader = Color(0xFF1E3A8A);
  static const Color blueDark = Color(0xFF1E3A8A);
}
