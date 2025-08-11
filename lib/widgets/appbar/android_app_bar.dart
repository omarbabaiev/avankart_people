import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AndroidAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? titleColor;
  final VoidCallback? onBackPressed;

  const AndroidAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.trailing,
    this.backgroundColor,
    this.titleColor,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 4,
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Get.back(),
              color: Theme.of(context).colorScheme.onBackground,
            )
          : null,
      title: Text(
        title,
        style: TextStyle(fontFamily: "Poppins", 
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: titleColor ?? Theme.of(context).colorScheme.onBackground,
        ),
      ),
      actions: trailing != null ? [trailing!] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
