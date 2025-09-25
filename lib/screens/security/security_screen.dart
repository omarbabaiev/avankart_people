import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/widgets/bottom_sheets/delete_account_bottom_sheet.dart';
import 'package:avankart_people/controllers/profile_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'security'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          // Sayfa açılınca profil verilerini yükle (sadece data yoksa)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.profile.value == null) {
              controller.getProfile();
            }
          });

          return Skeletonizer(
            enabled: controller.isLoading.value,
            enableSwitchAnimation: true,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _buildSecureTile(
                      icon: ImageAssets.pencil,
                      iconLeading: ImageAssets.envelope,
                      title: "email_address".tr,
                      subtitle: controller.profile.value?.email ?? '',
                      context: context,
                      isSwitch: false,
                      onTap: () {
                        Get.toNamed(AppRoutes.changeEmailAdress);
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _buildSecureTile(
                      onTap: () {
                        Get.toNamed(AppRoutes.changePassword);
                      },
                      icon: ImageAssets.pencil,
                      iconLeading: ImageAssets.lockKeyOpen,
                      title: "password".tr,
                      context: context,
                      isSwitch: false,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _buildSecureTile(
                      icon: ImageAssets.caretRight,
                      iconLeading: ImageAssets.hourglassMedium,
                      title: "freeze_account".tr,
                      context: context,
                      isSwitch: false,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _buildSecureTile(
                      iconLeading: ImageAssets.faceId,
                      title: "Face ID",
                      context: context,
                      isSwitch: false,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _buildSecureTile(
                      iconLeading: ImageAssets.fingerprintSimple,
                      title: "finger_print".tr,
                      context: context,
                      isSwitch: false,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _buildSecureTile(
                      onTap: () {
                        Get.toNamed(AppRoutes.setPinCode);
                      },
                      iconLeading: ImageAssets.password,
                      title: "pin_code".tr,
                      context: context,
                      isSwitch: false,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _buildSecureTile(
                      onTap: () {
                        Get.toNamed(AppRoutes.twoFactorAuthentication);
                      },
                      iconLeading: ImageAssets.lockKeyOpen,
                      title: "two_step_verification".tr,
                      context: context,
                      isSwitch: false,
                      icon: ImageAssets.caretRight,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _buildRemoveTile(
                        iconLeading: ImageAssets.trash,
                        title: "delete_account".tr,
                        context: context,
                        onTap: () => DeleteAccountBottomSheet.show(context)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSecureTile({
    String? icon,
    required String iconLeading,
    required String title,
    String? subtitle,
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
        child: Image.asset(
          iconLeading,
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
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
      trailing: icon == null
          ? Switch.adaptive(
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryColor,
            )
          : Image.asset(
              icon,
              width: 20,
              height: 20,
              color: Theme.of(context).colorScheme.onBackground,
            ),
      onTap: onTap,
    );
  }

  Widget _buildRemoveTile({
    required String iconLeading,
    required String title,
    String? subtitle,
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
          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          iconLeading,
          width: 23,
          height: 23,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.error.withOpacity(0.5),
              ),
            ),
      onTap: onTap,
    );
  }
}
