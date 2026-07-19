import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      ),
      elevation: 2,
      centerTitle: true,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: (automaticallyImplyLeading && canPop)
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textOnPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      title: Text(
        title,
        style: AppTextStyles.appBarTitle,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
