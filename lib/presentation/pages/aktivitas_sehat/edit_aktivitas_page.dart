import 'dart:convert';
import 'package:e_healty/core/widgets/custom_text_field.dart';
import 'package:e_healty/data/models/aktivitas_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/image_helper.dart';
import '../../../domain/entities/aktivitas_sehat.dart';
import '../../providers/aktivitas_sehat_provider.dart';
import 'package:e_healty/core/widgets/custom_button.dart';

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

  @override
  void initState() {
    super.initState();

    judul = TextEditingController(text: widget.aktivitas.judul);
    desk = TextEditingController(text: widget.aktivitas.deskripsi);

    // ambil gambar lama kalau ada
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
      appBar: AppBar(
        title: const Text(
          "Edit Aktivitas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // 🔥 TANPA TOMBOL BACK
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera, color: Colors.white),
                    label: const Text(
                      "Kamera",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () => _pick(ImageSource.camera),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo, color: Colors.white),
                    label: const Text(
                      "Galeri",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () => _pick(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ===== PREVIEW GAMBAR =====
            if (base64Image != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.memory(
                    base64Decode(base64Image!),
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ===== BUTTON SIMPAN (CUSTOM) =====
            CustomButton(
              text: "Simpan Perubahan",
              onPressed: () async {

                final updated = AktivitasModel(
                  id: widget.aktivitas.id,
                  uid: widget.aktivitas.uid,
                  judul: judul.text,
                  deskripsi: desk.text,
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
              },
            ),

            const SizedBox(height: 8),

            // ===== BUTTON BATAL (MERAH + TEXT PUTIH) =====
            CustomButton(
              text: "Batal",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
