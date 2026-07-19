import 'package:e_healty/core/utils/image_helper.dart';
import 'package:e_healty/core/widgets/custom_text_field.dart';
import 'package:e_healty/presentation/widgets/avatar_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tips_kesehatan_provider.dart';
import '../../providers/aktivitas_sehat_provider.dart';
import '../../widgets/custom_app_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;
      
      final user = context.read<AuthProvider>().user;
      nameController.text = user?.name ?? '';
      phoneController.text = user?.phoneNumber ?? '';
      
      // Load stats hanya sekali
      Future.microtask(() {
        context.read<TipsKesehatanProvider>().loadTips();
        context.read<AktivitasSehatProvider>().load(context);
      });
    }
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
    final tipsProvider = context.watch<TipsKesehatanProvider>();
    final aktivitasProvider = context.watch<AktivitasSehatProvider>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: const CustomAppBar(
        title: "Profil Saya",
        automaticallyImplyLeading: false,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  ProfileAvatar(
                    photoPath: user?.photoPath,
                    photoBase64: user?.photoBase64,
                    onTap: () => _pickImage(auth),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    user?.name ?? "User",
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    user?.email ?? "-",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Statistik Saya",
                    style: AppTextStyles.heading2,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.article,
                          count: "${tipsProvider.list.length}",
                          label: "Tips Tersedia",
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
                  ),

                  const SizedBox(height: 24),

                  // Edit Profile Section
                  Text(
                    "Edit Profil",
                    style: AppTextStyles.heading2,
                  ),

                  const SizedBox(height: 12),

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
                      ? const Center(child: CircularProgressIndicator())
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
                    backgroundColor: AppColors.primaryLight,
                    textColor: AppColors.primaryBlue,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(16),
      child: Column(
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
          const SizedBox(height: 12),
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
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
