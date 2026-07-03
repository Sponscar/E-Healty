import 'dart:convert';
import 'package:e_healty/core/utils/image_helper.dart';
import 'package:e_healty/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/aktivitas_sehat_provider.dart';

class AddAktivitasPage extends StatefulWidget {
  const AddAktivitasPage({super.key});

  @override
  State<AddAktivitasPage> createState() => _AddAktivitasPageState();
}

class _AddAktivitasPageState extends State<AddAktivitasPage> {
  final judul = TextEditingController();
  final desk = TextEditingController();

  String? base64Image;

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
          content: Text("$e"),
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
          "Tambah Aktivitas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

            if (base64Image != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(base64Image!),
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async {
                  await p.add(
                    context: context,
                    judul: judul.text,
                    deskripsi: desk.text,
                    imageBase64: base64Image,
                  );

                  if (!mounted) return;

                  Navigator.pop(context);
                },
                child: const Text(
                  "Simpan Aktivitas",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
