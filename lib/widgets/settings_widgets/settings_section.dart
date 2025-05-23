import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/language_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/bottom_sheet_extension.dart';
import 'settings_radio_item.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'notifications'.tr,
            isSwitch: true,
            context: context,
          ),
          GetBuilder<ThemeController>(
            builder: (controller) => _buildSettingsTile(
              icon: Icons.brightness_6_outlined,
              title: controller.themeName,
              onTap: () {
                Get.back();
                _showThemeSelectionDialog(context);
              },
              context: context,
            ),
          ),
          GetBuilder<LanguageController>(
            builder: (controller) => _buildSettingsTile(
              icon: Icons.language,
              title: controller.currentLanguage,
              onTap: () {
                _showLanguageSelectionDialog(context);
              },
              context: context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    bool isSwitch = false,
    VoidCallback? onTap,
    required BuildContext context,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 1,
      ),
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 23,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      trailing: isSwitch
          ? Switch.adaptive(
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryColor,
            )
          : Image.asset(
              ImageAssets.caretRight,
              width: 24,
              height: 24,
              color: Theme.of(context).colorScheme.onBackground,
            ),
      onTap: onTap,
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    context.showPerformantBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      builder: (context) {
        final ThemeController themeController = Get.find<ThemeController>();
        return GetBuilder<ThemeController>(
          builder: (_) => Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                context.buildBottomSheetHandle(),
                const SizedBox(height: 10),
                SettingsRadioItem(
                  title: 'light_mode'.tr,
                  value: ThemeMode.light,
                  groupValue: themeController.theme,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      themeController.changeTheme(value);
                      Get.back();
                    }
                  },
                ),
                Divider(height: 0.5, color: Theme.of(context).dividerColor),
                SettingsRadioItem(
                  title: 'dark_mode'.tr,
                  value: ThemeMode.dark,
                  groupValue: themeController.theme,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      themeController.changeTheme(value);
                      Get.back();
                    }
                  },
                ),
                Divider(height: 0.5, color: Theme.of(context).dividerColor),
                SettingsRadioItem(
                  title: 'system_mode'.tr,
                  value: ThemeMode.system,
                  groupValue: themeController.theme,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      themeController.changeTheme(value);
                      Get.back();
                    }
                  },
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    context.showPerformantBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              GetBuilder<LanguageController>(
                builder: (controller) => Column(
                  children: [
                    SettingsRadioItem<Locale>(
                      title: 'azerbaijan'.tr,
                      value: Locale('az', 'AZ'),
                      groupValue: controller.locale,
                      onChanged: (Locale? value) {
                        if (value != null) {
                          controller.changeLanguage(value);
                          Get.back();
                        }
                      },
                    ),
                    Divider(
                      height: 0.5,
                      color: Theme.of(context).dividerColor,
                    ),
                    SettingsRadioItem<Locale>(
                      title: 'united_states'.tr,
                      value: Locale('en', 'US'),
                      groupValue: controller.locale,
                      onChanged: (Locale? value) {
                        if (value != null) {
                          controller.changeLanguage(value);
                          Get.back();
                        }
                      },
                    ),
                    Divider(
                      height: 0.5,
                      color: Theme.of(context).dividerColor,
                    ),
                    SettingsRadioItem<Locale>(
                      title: 'russia'.tr,
                      value: Locale('ru', 'RU'),
                      groupValue: controller.locale,
                      onChanged: (Locale? value) {
                        if (value != null) {
                          controller.changeLanguage(value);
                          Get.back();
                        }
                      },
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
