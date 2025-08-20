import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import '../../utils/bottom_sheet_extension.dart';
import '../../utils/auth_utils.dart';
import '../../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/snackbar_utils.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        onTap: () {
          _showLogoutDialog(context);
        },
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.error.withOpacity(.2)),
          child: Image.asset(
            ImageAssets.signout,
            height: 23,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        title: Text(
          'logout'.tr,
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.error,
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
                style: TextStyle(
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
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    try {
                      await AuthUtils.logout();
                    } catch (e) {
                      SnackbarUtils.showErrorSnackbar(e.toString());
                    }
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
}
