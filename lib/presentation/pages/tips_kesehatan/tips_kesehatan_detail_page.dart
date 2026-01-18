import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tips_kesehatan_provider.dart';
import '../../widgets/custom_app_bar.dart';

class TipsKesehatanDetailPage extends StatelessWidget {
  final String id;

  const TipsKesehatanDetailPage({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TipsKesehatanProvider>();

    return FutureBuilder(
      future: provider.detail(id),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: const CustomAppBar(title: "Detail Tips"),
            body: Center(
              child: Text(
                "Gagal memuat data:\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final tips = snapshot.data!;

        return Scaffold(
          appBar: const CustomAppBar(title: "Detail Tips"),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ===== GAMBAR =====
                _buildImage(tips.imageUrl),

                const SizedBox(height: 16),

                // ===== JUDUL =====
                Text(
                  tips.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "By ${tips.author}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 16),

                // ===== ISI =====
                Text(
                  tips.content,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ========== WIDGET GAMBAR ==========
  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return const Icon(Icons.health_and_safety, size: 120);
    }

    return Image.network(
      url,
      width: double.infinity,
      fit: BoxFit.cover,

      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, size: 120),

      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
