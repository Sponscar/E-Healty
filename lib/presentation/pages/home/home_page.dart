import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/user_card.dart';
import '../../widgets/tips_kesehatan_card.dart';
import '../../widgets/aktivitas_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ========== SATU DIALOG UNTUK LOGOUT & BACK ==========
  Future<bool> _confirmExitOrLogout(
      BuildContext context, AuthProvider auth) async {

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari akun / aplikasi?",
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),

            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya, Keluar"),
          ),
        ],
      ),
    );

    // Jika user tekan YA
    if (result == true) {
      auth.logout();

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.login,
      );

      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return WillPopScope(
      // Saat tekan tombol BACK
      onWillPop: () => _confirmExitOrLogout(context, auth),

      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),

        appBar: const CustomAppBar(title: "E-Healthy"),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ========== USER CARD ==========
              UserCard(
                auth: auth,

                // Saat tekan logout di card
                onLogout: () => _confirmExitOrLogout(context, auth),
              ),

              const SizedBox(height: 20),

              const Text(
                "Menu Utama",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // ========== TIPS KESEHATAN ==========
              TipsKesehatanCard(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.tipsKesehatan,
                  );
                },
              ),

              const SizedBox(height: 12),

              // ========== AKTIVITAS SEHAT ==========
              AktivitasCard(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.aktivitasSehat,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
