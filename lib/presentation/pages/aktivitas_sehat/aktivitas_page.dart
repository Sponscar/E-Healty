import 'dart:convert';
import 'package:e_healty/presentation/pages/aktivitas_sehat/edit_aktivitas_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/aktivitas_sehat_provider.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';

class AktivitasSehatPage extends StatefulWidget {
  const AktivitasSehatPage({super.key});

  @override
  State<AktivitasSehatPage> createState() => _AktivitasSehatPageState();
}

class _AktivitasSehatPageState extends State<AktivitasSehatPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<AktivitasSehatProvider>().load(context),
    );
  }

  // ===== DIALOG KONFIRMASI HAPUS =====
  Future<void> _confirmDelete(
    BuildContext context,
    AktivitasSehatProvider provider,
    String aktivitasId,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Aktivitas"),
          content: const Text(
            "Apakah kamu yakin ingin menghapus aktivitas ini?",
          ),
          actionsPadding: const EdgeInsets.all(12),
          actions: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Batal",
                    backgroundColor: Colors.blue.shade300,
                    textColor: Colors.white,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: "Hapus",
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (result == true) {
      await provider.remove(context, aktivitasId);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aktivitas berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AktivitasSehatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Aktivitas Sehat",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addAktivitas);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: p.loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : p.list.isEmpty
              ? const Center(child: Text("Belum ada aktivitas"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: p.list.length,
                  itemBuilder: (_, i) {
                    final a = p.list[i];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: (a.imageBase64 ?? '').isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(a.imageBase64!),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.run_circle,
                                size: 40,
                                color: Colors.blue,
                              ),

                        title: Text(
                          a.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.deskripsi),
                            const SizedBox(height: 4),
                            Text(
                              "Dibuat: ${a.createdAt.toLocal()}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ===== EDIT =====
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditAktivitasPage(aktivitas: a),
                                  ),
                                );
                              },
                            ),

                            // ===== DELETE (DIALOG) =====
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(context, p, a.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
