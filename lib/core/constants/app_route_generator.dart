import 'package:flutter/material.dart';

import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/admin/admin_dasboard_page.dart';

import 'app_routes.dart';

class AppRouteGenerator {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {

      // ========== AUTH ==========
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );

      // ========== USER ==========
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );

      // ========== ADMIN ==========
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardPage(),
        );

      // ========== DEFAULT ==========
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("Halaman tidak ditemukan"),
            ),
          ),
        );
    }
  }
}
