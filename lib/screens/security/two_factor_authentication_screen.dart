import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/widgets/restaurant_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

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
            'Təhlükəsizlik',
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
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Column(
                children: [
                  Text(
                    "2 addımlı doğrulama",
                    style: TextStyle(
    fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Hesabınızın təhlükəsizliyi bizim üçün önəmlidir. İki addımlı doğrulama ilə hesabınıza girişləri tam idarə edin.",
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
                  icon: Icons.phone,
                  title: "E-poçt doğrulama",
                  subtitle:
                      "Email adresinizi təsdiqləyərək hesabınızı daha güvənli saxlayın",
                  context: context,
                  isSwitch: true),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _buildSettingsTile(
                  icon: Icons.phone,
                  title: "Nömrə ilə doğrulama",
                  subtitle:
                      "Telefon nömrənizi əlavə edərək hesabınızı daha güvənli saxlayın",
                  context: context,
                  isSwitch: true),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _buildSettingsTile(
                  icon: Icons.phone,
                  title: "Authenticator",
                  subtitle:
                      "QR kod və ya Auth key ilə hesabınızı daha güvənli saxlayın",
                  context: context,
                  isSwitch: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
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
              onChanged: (value) {},
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
