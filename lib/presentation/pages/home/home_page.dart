import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/user_card.dart';
import '../../widgets/tips_kesehatan_card.dart';
import '../../widgets/aktivitas_card.dart';
import '../../../core/widgets/custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        await auth.loadUser(auth.user!.uid);
      }
    });
  }

  Future<bool> _confirmExitOrLogout(
    BuildContext context,
    AuthProvider auth,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Konfirmasi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Apakah Anda yakin ingin keluar dari akun / aplikasi?",
                  style: TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Batal",
                        backgroundColor: Colors.blueAccent,
                        onPressed: () =>
                            Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "Ya, Keluar",
                        backgroundColor: Colors.red,
                        onPressed: () =>
                            Navigator.pop(context, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      auth.logout();
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return WillPopScope(
      onWillPop: () => _confirmExitOrLogout(context, auth),
      child: Scaffold(
        backgroundColor: AppColors.offWhite,

        appBar: const CustomAppBar(title: "E-Healthy"),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserCard(
                auth: auth,
                onLogout: () =>
                    _confirmExitOrLogout(context, auth),
              ),

              const SizedBox(height: 20),

              const Text(
                "Menu Utama",
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: 12),

              TipsKesehatanCard(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.tipsKesehatan,
                  );
                },
              ),

              const SizedBox(height: 12),

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
