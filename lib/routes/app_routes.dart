import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/';
  static const String createBudget = '/create-budget';
  static const String previewPdf = '/preview-pdf';
  static const String settings = '/settings';
  
  // Transición suave entre pantallas
  static PageRoute<T> fadeRoute<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
