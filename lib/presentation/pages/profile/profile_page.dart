import 'dart:convert';
import 'dart:io';
import 'package:e_healty/presentation/widgets/avatar_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = context.read<AuthProvider>().user;

    nameController.text = user?.name ?? '';
    phoneController.text = user?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ============ PICK FOTO ============
  Future<void> _pickImage(AuthProvider auth) async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      // 🔥 KONVERSI KE BASE64
      final bytes = await File(image.path).readAsBytes();
      final base64String = base64Encode(bytes);

      await auth.updatePhotoBase64(base64String);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Foto profil berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal update foto: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============ VALIDASI SIMPLE ============
  bool _validate() {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama dan No HP tidak boleh kosong"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,   // ← MENGHILANGKAN TOMBOL BACK
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== AVATAR =====
           ProfileAvatar(
              photoPath: user?.photoPath,
              photoBase64: user?.photoBase64,
              onTap: () => _pickImage(auth),
            ),


            const SizedBox(height: 20),

            Text(
              user?.email ?? "-",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "No HP",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // ===== BUTTON SIMPAN =====
            auth.isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    text: "Simpan Perubahan",
                    onPressed: () async {
                      if (!_validate()) return;

                      await auth.updateProfile(
                        name: nameController.text,
                        phone: phoneController.text,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profil berhasil diperbarui"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 12),

            // ===== KEMBALI =====
            CustomButton(
              text: "Kembali ke Home",
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.home,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
