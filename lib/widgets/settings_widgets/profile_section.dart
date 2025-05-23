import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildProfileTile(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    margin: EdgeInsets.only(bottom: 4),
    padding: EdgeInsets.symmetric(horizontal: 16),
    height: 100,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
    child: ListTile(
      onTap: () {
        Get.toNamed(AppRoutes.profil);
      },
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).hoverColor,
        radius: 30,
        child: Center(
          child: Text(
            'RO',
            style: GoogleFonts.poppins(
              color: Theme.of(context).primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      title: Text(
        'Ramin Orucov',
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      trailing: Image.asset(
        ImageAssets.caretRight,
        width: 24,
        height: 24,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    ),
  );
}

Widget buildCompanyTile(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    margin: EdgeInsets.only(bottom: 4),
    padding: EdgeInsets.symmetric(horizontal: 16),
    height: 70,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
    child: ListTile(
      onTap: () {
        Get.toNamed(AppRoutes.membershipList);
      },
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          ImageAssets.addressBook,
          width: 23,
          height: 23,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      title: Text(
        'Üzvlük',
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        'Veysəloğlu MMC',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).unselectedWidgetColor,
        ),
      ),
      trailing: Image.asset(
        ImageAssets.caretRight,
        width: 24,
        height: 24,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    ),
  );
}

Widget buildTile(
    BuildContext context, String title, String icon, VoidCallback onTap) {
  return Container(
    alignment: Alignment.center,
    margin: EdgeInsets.only(bottom: 4),
    padding: EdgeInsets.symmetric(horizontal: 16),
    height: 65,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
    child: ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          icon,
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
      trailing: Image.asset(
        ImageAssets.caretRight,
        width: 24,
        height: 24,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    ),
  );
}
