import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/theme_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/widgets/restaurant_card_widget.dart';
import 'package:avankart_people/widgets/settings_widgets/logout_button.dart';
import 'package:avankart_people/widgets/settings_widgets/profile_section.dart';
import 'package:avankart_people/widgets/settings_widgets/settings_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends GetView<ThemeController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    Get.put(ThemeController());
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: AppBar(
          toolbarHeight: 68,
          centerTitle: false,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Tənzimləmələr',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.only(bottom: 150),
          children: [
            buildProfileTile(context),
            buildCompanyTile(context),
            buildTile(context, 'Kartlar', ImageAssets.cardholder, () {
              Get.toNamed(AppRoutes.selectCard);
            }),
            buildTile(context, 'Rozetlər', ImageAssets.trophy, () {
              Get.toNamed(AppRoutes.benefits);
            }),
            SettingsSection(),
            buildTile(context, 'Təhlükəsizlik', ImageAssets.locckey, () {
              Get.toNamed(AppRoutes.security);
            }),
            buildTile(context, 'Dəstək', ImageAssets.headset, () {
              Get.toNamed(AppRoutes.support);
            }),
            buildLogoutButton(context),
          ],
        ));
  }
}
