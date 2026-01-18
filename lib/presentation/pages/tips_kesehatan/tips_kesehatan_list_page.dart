import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../providers/tips_kesehatan_provider.dart';
import '../../widgets/custom_app_bar.dart';

class TipsKesehatanListPage extends StatefulWidget {
  const TipsKesehatanListPage({super.key});

  @override
  State<TipsKesehatanListPage> createState() =>
      _TipsKesehatanListPageState();
}

class _TipsKesehatanListPageState
    extends State<TipsKesehatanListPage> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
      context.read<TipsKesehatanProvider>().loadTips()
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TipsKesehatanProvider>();

    return Scaffold(
      appBar: const CustomAppBar(title: "Tips Kesehatan"),

      body: provider.loading
          ? const Center(child: CircularProgressIndicator())

          : provider.list.isEmpty
              ? const Center(
                  child: Text("Belum ada data tips kesehatan"),
                )

              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.list.length,
                  itemBuilder: (context, i) {
                    final tips = provider.list[i];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: _buildImage(tips.imageUrl),

                        title: Text(
                          tips.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        subtitle: Text(
                          "By ${tips.author}",
                          style: const TextStyle(fontSize: 12),
                        ),

                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.tipsKesehatanDetail,
                            arguments: tips.id,
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  // ========== HANDLE GAMBAR AMAN ==========
  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return const Icon(Icons.health_and_safety, size: 50);
    }

    return Image.network(
      url,
      width: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, size: 50),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const SizedBox(
          width: 60,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
