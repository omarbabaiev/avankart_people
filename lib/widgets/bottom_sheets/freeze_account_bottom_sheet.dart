import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/controllers/profile_controller.dart';
import 'verification_bottom_sheet.dart';

class FreezeAccountBottomSheet {
  static void show(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              context.buildBottomSheetHandle(),
              const SizedBox(height: 10),
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onError,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.error_outline,
                    size: 26,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'freeze_account_confirm_title'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'freeze_account_confirm_subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back(); // sheet'i kapat
                      final success =
                          await profileController.requestFreezeAccount();
                      if (success) {
                        _showVerificationSheet(context, profileController);
                      }
                    },
                    style: AppTheme.primaryButtonStyle(),
                    child: Text(
                      'confirm'.tr, // Təsdiqlə
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'cancel'.tr, // Ləğv et
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  static void _showVerificationSheet(
      BuildContext context, ProfileController controller) {
    final currentContext = Get.context ?? context;
    VerificationBottomSheet.show(
      currentContext,
      title: 'otp'.tr,
      subtitle:
          '${controller.profile.value?.email} email adresinə göndərilən 6 rəqəmli şifrəni daxil edin',
      showTimer: true,
      onVerify: (otp) async {
        return await controller.verifyUpdateOTP(otp);
      },
      onResend: () async {
        await controller.requestFreezeAccount();
      },
    );
  }
}
