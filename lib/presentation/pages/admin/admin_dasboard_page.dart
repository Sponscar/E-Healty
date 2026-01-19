import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();

              if (!context.mounted) return;

              Navigator.pushReplacementNamed(
                context,
                AppRoutes.login,
              );
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== INFO ADMIN =====
            Card(
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings,
                    color: Colors.blue),
                title: Text(
                  "Halo, ${user?.name ?? 'Admin'}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user?.email ?? ""),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Menu Admin",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // ===== MENU 1 : KELOLA TIPS =====
            _buildMenuCard(
              context,
              title: "Kelola Tips Kesehatan",
              icon: Icons.health_and_safety,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.manageTips,
                );
              },
            ),

            // ===== MENU 2 : KELOLA AKTIVITAS =====
            _buildMenuCard(
              context,
              title: "Kelola Aktivitas Sehat",
              icon: Icons.directions_run,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.aktivitasSehat,
                );
              },
            ),

            // ===== MENU 3 : DATA USER (opsional) =====
            _buildMenuCard(
              context,
              title: "Data Pengguna",
              icon: Icons.people,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fitur belum dibuat"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
