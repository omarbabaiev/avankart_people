import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../utils/bottom_sheet_extension.dart';

Widget buildLogoutButton(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(bottom: 4),
    padding: EdgeInsets.symmetric(horizontal: 4),
    height: 65,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
    child: Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          overlayColor: Theme.of(context).colorScheme.error,
          minimumSize: Size(Get.width, 40),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () {
          _showLogoutDialog(context);
        },
        icon: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Transform.rotate(
            angle: 3.14,
            child: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
              size: 23,
            ),
          ),
        ),
        label: Text(
          'logout'.tr,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    ),
  );
}

void _showLogoutDialog(BuildContext context) {
  context.showPerformantBottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            context.buildBottomSheetHandle(),
            const SizedBox(height: 10),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onError,
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: 3.14,
                child: Icon(
                  Icons.logout_outlined,
                  color: Theme.of(context).colorScheme.onBackground,
                  size: 24,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'logout'.tr,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'logout_confirm'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: AppTheme.primaryButtonStyle(
                  backgroundColor: AppTheme.error,
                ),
                child: Text(
                  'yes_logout'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'no'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).unselectedWidgetColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      );
    },
  );
}
