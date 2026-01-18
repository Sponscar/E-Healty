import 'package:flutter/material.dart';
import 'menu_card.dart';

class AktivitasCard extends StatelessWidget {
  final VoidCallback onTap;

  const AktivitasCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MenuCard(
      icon: Icons.favorite,
      color: Colors.red,
      title: "Aktivitas Sehat",
      subtitle: "Catat aktivitas sehatmu",
      onTap: onTap,
    );
  }
}
