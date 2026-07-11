import 'package:e_healty/core/utils/image_helper.dart';
import 'package:e_healty/core/widgets/custom_text_field.dart';
import 'package:e_healty/presentation/widgets/avatar_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> _pickImage(AuthProvider auth) async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final base64String = await ImageHelper.compressToBase64(image.path);

      if (base64String == null) {
        throw Exception("Gagal memproses gambar");
      }

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
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  bool _validate() {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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

            CustomTextField(
              controller: nameController,
              label: "Nama",
              icon: Icons.person,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return "Nama tidak boleh kosong";
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            CustomTextField(
              controller: phoneController,
              label: "No HP",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return "No HP tidak boleh kosong";
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

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

            CustomButton(
              text: "Kembali ke Home",
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}
