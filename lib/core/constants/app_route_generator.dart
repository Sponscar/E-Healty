import 'package:flutter/material.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/profile/profile_page.dart';

import '../../presentation/pages/tips_kesehatan/tips_kesehatan_list_page.dart';
import '../../presentation/pages/tips_kesehatan/tips_kesehatan_detail_page.dart';

import '../../presentation/pages/aktivitas_sehat/aktivitas_page.dart';
import '../../presentation/pages/aktivitas_sehat/add_aktivitas_page.dart';

import '../../presentation/pages/admin/admin_dasboard_page.dart';
import '../../presentation/pages/admin/manage_tips_page.dart';

import 'app_routes.dart';

class AppRouteGenerator {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      // ===== TIPS KESEHATAN =====
      case AppRoutes.tipsKesehatan:
        return MaterialPageRoute(
          builder: (_) => const TipsKesehatanListPage(),
        );

      case AppRoutes.tipsKesehatanDetail:
        final id = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => TipsKesehatanDetailPage(id: id),
        );

      // ===== AKTIVITAS =====
      case AppRoutes.aktivitasSehat:
        return MaterialPageRoute(
          builder: (_) => const AktivitasSehatPage(),
        );

      case AppRoutes.addAktivitas:
        return MaterialPageRoute(
          builder: (_) => const AddAktivitasPage(),
        );

      // ===== ADMIN =====
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardPage(),
        );

      case AppRoutes.manageTips:
        return MaterialPageRoute(
          builder: (_) => const ManageTipsPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route tidak ditemukan")),
          ),
        );
    }
  }
}
