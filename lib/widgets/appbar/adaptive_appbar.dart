import 'dart:io';
import 'package:flutter/material.dart';
import 'android_app_bar.dart';
import 'ios_app_bar.dart';

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? titleColor;
  final VoidCallback? onBackPressed;

  const AdaptiveAppBar({
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
    if (Platform.isIOS) {
      return IosAppBar(
        title: title,
        showBackButton: showBackButton,
        trailing: trailing,
        backgroundColor: backgroundColor,
        titleColor: titleColor,
        onBackPressed: onBackPressed,
      );
    }

    return AndroidAppBar(
      title: title,
      showBackButton: showBackButton,
      trailing: trailing,
      backgroundColor: backgroundColor,
      titleColor: titleColor,
      onBackPressed: onBackPressed,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
