import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: AppBar(
          toolbarHeight: 68,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Bildirişlər',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          actions: [
            IconButton.filledTonal(
              icon: Image.asset(
                ImageAssets.trophy,
                width: 24,
                height: 24,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.benefits);
              },
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                fixedSize: Size(44, 44),
              ),
            ),
            SizedBox(width: 4),
            IconButton.filledTonal(
              icon: Image.asset(
                ImageAssets.heartStraight,
                width: 24,
                height: 24,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              onPressed: () {
                Get.toNamed(AppRoutes.favorites);
              },
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                fixedSize: Size(44, 44),
              ),
            ),
            SizedBox(width: 15),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Get.isDarkMode
                  ? Image.asset(ImageAssets.bellIcon, width: 80, height: 80)
                  : Image.asset(ImageAssets.bellIconDark,
                      width: 80, height: 80),
              const SizedBox(height: 16),
              Text(
                'no_notifications'.tr,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'notification_updates'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ));
  }
}
