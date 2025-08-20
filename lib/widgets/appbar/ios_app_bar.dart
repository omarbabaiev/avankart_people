import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final VoidCallback? onBackPressed;

  const IosAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.trailing,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Theme.of(context).dividerColor,
          height: 1,
        ),
      ),
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      elevation: 1,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Get.back(),
              iconSize: 20,
              color: Theme.of(context).colorScheme.onBackground,
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: "Poppins",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: titleColor ?? Theme.of(context).colorScheme.onBackground,
        ),
      ),
      actions: trailing != null ? [trailing!] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
