import 'package:flutter/material.dart';
import 'menu_card.dart';

class TipsKesehatanCard extends StatelessWidget {
  final VoidCallback onTap;

  const TipsKesehatanCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MenuCard(
      icon: Icons.article,
      color: Colors.green,
      title: "Tips Kesehatan",
      subtitle: "Baca tips kesehatan harian",
      onTap: onTap,
    );
  }
}
