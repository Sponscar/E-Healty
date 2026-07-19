import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.offWhite,
      appBar: const CustomAppBar(title: "Tips Kesehatan"),

      body: provider.loading
          ? const Center(child: CircularProgressIndicator())

          : provider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Coba Lagi"),
                        onPressed: () {
                          context.read<TipsKesehatanProvider>().loadTips();
                        },
                      ),
                    ],
                  ),
                )

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
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.tipsKesehatanDetail,
                            arguments: tips.id,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildImage(tips.imageUrl),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tips.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.person_outline,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            tips.author,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

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
