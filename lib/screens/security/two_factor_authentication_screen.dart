import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TwoFactorAuthenticationScreen extends StatelessWidget {
  const TwoFactorAuthenticationScreen({super.key});

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
            'security'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 4),
            Container(
              width: Get.width,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Column(
                children: [
                  Text(
                    "two_factor_authentication".tr,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "two_fact or_authentication_description".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).unselectedWidgetColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _buildSettingsTile(
                  icon: ImageAssets.envelope,
                  title: "email_authentication".tr,
                  subtitle: "email_authentication_description".tr,
                  context: context,
                  isSwitch: true,
                  isEnabled: false),
            ),
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.onPrimary,
            //   ),
            //   child: _buildSettingsTile(
            //       icon: Icons.phone,
            //       title: "Nömrə ilə doğrulama",
            //       subtitle:
            //           "Telefon nömrənizi əlavə edərək hesabınızı daha güvənli saxlayın",
            //       context: context,
            //       isSwitch: true),
            // ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _buildSettingsTile(
                  icon: ImageAssets.qrcode,
                  title: "authenticator".tr,
                  subtitle: "authenticator_description".tr,
                  context: context,
                  isSwitch: true,
                  isEnabled: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String icon,
    required String title,
    required String subtitle,
    bool isSwitch = false,
    bool isEnabled = true,
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
          icon,
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
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).unselectedWidgetColor,
        ),
      ),
      trailing: isSwitch
          ? Switch.adaptive(
              value: true,
              onChanged: isEnabled ? (value) {} : null,
              activeColor: AppTheme.primaryColor,
            )
          : Icon(
              Icons.chevron_right_sharp,
              size: 35,
              color: Theme.of(context).colorScheme.onBackground,
            ),
      onTap: onTap,
    );
  }
}
