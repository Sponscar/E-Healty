import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';

class UserCard extends StatelessWidget {
  final AuthProvider auth;
  final VoidCallback onLogout;

  const UserCard({
    super.key,
    required this.auth,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final user = auth.user;

    Widget buildAvatar() {
      try {
        if (user?.photoBase64 != null &&
            user!.photoBase64!.isNotEmpty) {

          return CircleAvatar(
            radius: 28,
            backgroundImage:
                MemoryImage(base64Decode(user.photoBase64!)),
          );
        }
      } catch (e) {
        print("Error load avatar: $e");
      }

      return const CircleAvatar(
        radius: 28,
        backgroundColor: Colors.blue,
        child: Icon(Icons.person, color: Colors.white),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),

      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => _UserActionSheet(
            onProfile: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            onLogout: onLogout,
          ),
        );
      },

      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [

              // ✅ AVATAR DINAMIS
              buildAvatar(),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, ${user?.name ?? '-'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(user?.email ?? '-'),
                  ],
                ),
              ),

              const Icon(Icons.touch_app, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserActionSheet extends StatelessWidget {
  final VoidCallback onProfile;
  final VoidCallback onLogout;

  const _UserActionSheet({
    required this.onProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ListTile(
          title: Text("Menu Akun"),
        ),

        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("Profil Saya"),
          onTap: onProfile,
        ),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout"),
          onTap: onLogout,
        ),
      ],
    );
  }
}
