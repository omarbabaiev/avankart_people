import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/theme_controller.dart';
import 'package:avankart_people/controllers/profile_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/widgets/company_card_widget.dart';
import 'package:avankart_people/widgets/settings_widgets/logout_button.dart';
import 'package:avankart_people/widgets/settings_widgets/profile_section.dart';
import 'package:avankart_people/widgets/settings_widgets/settings_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SettingsScreen extends GetView<ThemeController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ları başlat
    Get.put(ThemeController());

    // ProfileController'ı Get.find ile al
    final profileController = Get.find<ProfileController>();

    // Sayfa açılınca profil verilerini yükle (sadece data yoksa)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profileController.profile.value == null) {
        profileController.getProfile();
      }
    });

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 68,
          centerTitle: false,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'settings'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: Obx(() {
          final user = profileController?.profile.value;
          final isLoading = profileController?.isLoading.value ?? false;

          return ListView(
            padding: EdgeInsets.only(bottom: 150),
            children: [
              ProfileSection(
                user: user,
                isLoading: isLoading,
              ),
              buildTile(context, 'cards'.tr, ImageAssets.cardholder, () {
                Get.toNamed(AppRoutes.selectCard);
              }),
              // buildTile(context, 'Rozetlər', ImageAssets.trophy, () {
              //   Get.toNamed(AppRoutes.benefits);
              // }),
              SettingsSection(),
              buildTile(context, 'security'.tr, ImageAssets.locckey, () {
                Get.toNamed(AppRoutes.security);
              }),
              buildTile(context, 'support'.tr, ImageAssets.headset, () {
                Get.toNamed(AppRoutes.support);
              }),
              LogoutButton(),
            ],
          );
        }));
  }
}
