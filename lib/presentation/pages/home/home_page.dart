import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tips_kesehatan_provider.dart';
import '../../providers/aktivitas_sehat_provider.dart';
import '../../widgets/custom_app_bar.dart';
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
      
      // Load data for stats
      context.read<TipsKesehatanProvider>().loadTips();
      context.read<AktivitasSehatProvider>().load(context);
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
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Keluar Aplikasi?",
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  "Apakah Anda yakin ingin keluar dari akun ini?",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          "Batal",
                          style: AppTextStyles.buttonMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Ya, Keluar",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
    final tipsProvider = context.watch<TipsKesehatanProvider>();
    final aktivitasProvider = context.watch<AktivitasSehatProvider>();

    return WillPopScope(
      onWillPop: () => _confirmExitOrLogout(context, auth),
      child: Scaffold(
        backgroundColor: AppColors.offWhite,

        appBar: const CustomAppBar(
          title: "E-Healthy",
          automaticallyImplyLeading: false,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Welcome Card
              _buildWelcomeCard(auth),

              const SizedBox(height: 24),

              // Menu Section
              Text(
                "Menu Utama",
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: 12),

              _buildMenuList(context),

              const SizedBox(height: 24),

              // Quick Stats Section
              Text(
                "Ringkasan",
                style: AppTextStyles.heading2,
              ),

              const SizedBox(height: 12),

              _buildStatsGrid(tipsProvider, aktivitasProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AuthProvider auth) {
    // Build avatar image
    ImageProvider? avatarImage;
    if (auth.user?.photoBase64 != null && auth.user!.photoBase64!.isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(auth.user!.photoBase64!));
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // User avatar di kiri
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? const Icon(Icons.person, size: 32, color: Colors.white)
                  : null,
            ),
          ),

          const SizedBox(width: 16),

          // Info di tengah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo! 👋",
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.user?.name ?? "User",
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Jaga kesehatanmu hari ini!",
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Logout di kanan
          IconButton(
            onPressed: () => _confirmExitOrLogout(context, auth),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    TipsKesehatanProvider tipsProvider,
    AktivitasSehatProvider aktivitasProvider,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.article,
            count: "${tipsProvider.list.length}",
            label: "Tips Kesehatan",
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite,
            count: "${aktivitasProvider.list.length}",
            label: "Aktivitas Saya",
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            count,
            style: AppTextStyles.heading1.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        _buildMenuCard(
          context: context,
          icon: Icons.article,
          title: "Tips Kesehatan",
          subtitle: "Baca tips kesehatan harian",
          color: Colors.green,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.tipsKesehatan);
          },
        ),
        const SizedBox(height: 12),
        _buildMenuCard(
          context: context,
          icon: Icons.favorite,
          title: "Aktivitas Sehat",
          subtitle: "Catat aktivitas sehatmu",
          color: Colors.red,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.aktivitasSehat);
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
