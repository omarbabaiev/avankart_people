import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/screens/security/pin_code_screen.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/widgets/restaurant_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Təhlükəsizlik',
            style: GoogleFonts.poppins(
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
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _buildSecureTile(
                icon: ImageAssets.pencil,
                iconLeading: ImageAssets.envelope,
                title: "E-poçt adresi",
                subtitle: "raminorucov@gmail.com",
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
                icon: ImageAssets.pencil,
                iconLeading: ImageAssets.lockKeyOpen,
                title: "Şifrə",
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
                title: "Hesabı dondur",
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
                title: "Barmaq izi",
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
                title: "PIN kod",
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
                title: "2 addımlı doğrulama",
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
                  title: "Hesabı sil",
                  context: context,
                  onTap: () {}),
            ),
          ],
        ),
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
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: GoogleFonts.poppins(
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
    String? icon,
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
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.error.withOpacity(0.5),
              ),
            ),
      onTap: onTap,
    );
  }
}
