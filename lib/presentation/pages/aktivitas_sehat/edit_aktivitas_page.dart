import 'dart:convert';
import 'package:e_healty/core/widgets/custom_text_field.dart';
import 'package:e_healty/data/models/aktivitas_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/utils/network_helper.dart';
import '../../../domain/entities/aktivitas_sehat.dart';
import '../../providers/aktivitas_sehat_provider.dart';
import 'package:e_healty/core/widgets/custom_button.dart';
import '../../widgets/custom_app_bar.dart';

class EditAktivitasPage extends StatefulWidget {
  final AktivitasSehat aktivitas;

  const EditAktivitasPage({
    super.key,
    required this.aktivitas,
  });

  @override
  State<EditAktivitasPage> createState() => _EditAktivitasPageState();
}

class _EditAktivitasPageState extends State<EditAktivitasPage> {
  late TextEditingController judul;
  late TextEditingController desk;

  String? base64Image;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    judul = TextEditingController(text: widget.aktivitas.judul);
    desk = TextEditingController(text: widget.aktivitas.deskripsi);

    base64Image = widget.aktivitas.imageBase64;
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image == null) return;

      final base64 =
          await ImageHelper.compressToBase64(image.path);

      setState(() {
        base64Image = base64;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal ambil gambar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.read<AktivitasSehatProvider>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: const CustomAppBar(title: "Edit Aktivitas"),

      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Section: Detail
            Text("Detail Aktivitas", style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            )),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                children: [
                  CustomTextField(
                    controller: judul,
                    label: "Judul Aktivitas",
                    icon: Icons.title,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Judul tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: desk,
                    label: "Deskripsi",
                    icon: Icons.description,
                    keyboardType: TextInputType.multiline,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Deskripsi tidak boleh kosong";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Foto
            Text("Foto Aktivitas", style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            )),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                    label: Text("Kamera", style: TextStyle(color: AppColors.primaryBlue)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppColors.primaryBlue),
                    ),
                    onPressed: () => _pick(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.photo_library, color: AppColors.primaryBlue),
                    label: Text("Galeri", style: TextStyle(color: AppColors.primaryBlue)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppColors.primaryBlue),
                    ),
                    onPressed: () => _pick(ImageSource.gallery),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (base64Image != null)
              Container(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    base64Decode(base64Image!),
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : () async {
                  if (judul.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Judul tidak boleh kosong"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (desk.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Deskripsi tidak boleh kosong"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final hasInternet = await NetworkHelper.hasInternetConnection();
                  if (!hasInternet) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Tidak ada koneksi internet. Periksa koneksi Anda."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() => _isSubmitting = true);

                  try {
                    final updated = AktivitasModel(
                      id: widget.aktivitas.id,
                      uid: widget.aktivitas.uid,
                      judul: judul.text.trim(),
                      deskripsi: desk.text.trim(),
                      imageBase64: base64Image,
                      createdAt: widget.aktivitas.createdAt,
                    );

                    await p.edit(context, updated);

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Berhasil update aktivitas"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Gagal update: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                },
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                  "Simpan Perubahan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.red, width: 1.5),
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
