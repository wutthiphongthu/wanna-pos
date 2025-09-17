import 'package:flutter/material.dart';
import '../../features/sales/presentation/pages/sales_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String sales = '/sales';
  static const String members = '/members';
  static const String stock = '/stock';
  static const String payment = '/payment';
  static const String loyalty = '/loyalty';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == home) {
      return MaterialPageRoute(
        builder: (_) => const SalesPage(),
      );
    } else if (settings.name == sales) {
      return MaterialPageRoute(
        builder: (_) => const SalesPage(),
      );
    } else if (settings.name == members) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Members Page - Coming Soon'),
          ),
        ),
      );
    } else if (settings.name == stock) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Stock Page - Coming Soon'),
          ),
        ),
      );
    } else if (settings.name == payment) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Payment Page - Coming Soon'),
          ),
        ),
      );
    } else if (settings.name == loyalty) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Loyalty Page - Coming Soon'),
          ),
        ),
      );
    } else if (settings.name == settings) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Settings Page - Coming Soon'),
          ),
        ),
      );
    } else if (settings.name == profile) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Profile Page - Coming Soon'),
          ),
        ),
      );
    } else if (settings.name == login) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Login Page - Coming Soon'),
          ),
        ),
      );
    } else if (settings.name == register) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Register Page - Coming Soon'),
          ),
        ),
      );
    } else {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Page Not Found'),
          ),
        ),
      );
    }
  }
}
