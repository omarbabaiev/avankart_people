import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/notification_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/language_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/bottom_sheet_extension.dart';
import 'settings_radio_item.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Column(
        children: [
          _buildNotificationTile(context),
          GetBuilder<ThemeController>(
            builder: (controller) => _buildSettingsTile(
              imageUrl: ImageAssets.brightness,
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
              imageUrl: ImageAssets.globe,
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

  Widget _buildNotificationTile(BuildContext context) {
    final controller = Get.put(NotificationSettingsController());

    return Obx(() => Skeletonizer(
          enabled: controller.isLoading.value,
          enableSwitchAnimation: true,
          child: _buildSettingsTile(
            imageUrl: ImageAssets.bellringing,
            title: 'notifications'.tr,
            isSwitch: true,
            switchValue: controller.isNotificationEnabled.value,
            onSwitchChanged: (value) => controller.toggleNotification(value),
            onTap: () => controller.openAppNotificationSettings(),
            context: context,
          ),
        ));
  }

  Widget _buildSettingsTile({
    required String imageUrl,
    required String title,
    bool isSwitch = false,
    VoidCallback? onTap,
    bool? switchValue,
    Function(bool)? onSwitchChanged,
    bool isLoading = false,
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
        child: Image.asset(
          imageUrl,
          width: 23,
          height: 23,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      trailing: isSwitch
          ? Skeletonizer(
              enabled: isLoading,
              enableSwitchAnimation: true,
              child: Switch.adaptive(
                value: switchValue ?? false,
                onChanged: onSwitchChanged ?? (value) {},
                activeColor: AppTheme.primaryColor,
              ))
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
                      title: 'azerbaijani_language'.tr,
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
                      title: 'english_language'.tr,
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
                      title: 'turkish_language'.tr,
                      value: Locale('tr', 'TR'),
                      groupValue: controller.locale,
                      onChanged: (Locale? value) {
                        if (value != null) {
                          controller.changeLanguage(value);
                          Get.back();
                        }
                      },
                    ),
                    SettingsRadioItem<Locale>(
                      title: 'russian_language'.tr,
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
