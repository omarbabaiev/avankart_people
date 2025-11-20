import 'package:avankart_people/assets/image_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import '../../utils/bottom_sheet_extension.dart';
import '../../utils/snackbar_utils.dart';
import '../../controllers/profile_controller.dart';
import 'verification_bottom_sheet.dart';

class DeleteAccountBottomSheet {
  static void show(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                width: 55,
                height: 55,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onError,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  ImageAssets.trash2,
                  height: 5,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'account_delete'.tr,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'account_delete_confirmation'.tr,
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
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();

                      final success =
                          await profileController.requestDeleteProfile();

                      if (success) {
                        _showVerificationSheet(context, profileController);
                      }
                    },
                    style: AppTheme.primaryButtonStyle().copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.error,
                      ),
                    ),
                    child: Text(
                      'delete_account'.tr,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                      ),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).unselectedWidgetColor,
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

  static void _showVerificationSheet(
      BuildContext context, ProfileController controller) {
    // Context'in geçerli olup olmadığını kontrol et
    if (!context.mounted) {
      debugPrint(
          '[VERIFICATION SHEET] Context is not mounted, using Get.context');
      // Eğer context geçerli değilse Get.context kullan
      final currentContext = Get.context;
      if (currentContext != null) {
        VerificationBottomSheet.show(
          currentContext,
          title: 'otp'.tr,
          subtitle:
              '${controller.profile.value?.email} email adresinə göndərilən 6 rəqəmli şifrəni daxil edin',
          showTimer: true,
          onVerify: (otp) async {
            return await controller.submitDeleteProfileOTP(otp);
          },
          onResend: () async {
            await controller.requestDeleteProfile();
          },
        );
      } else {
        debugPrint('[VERIFICATION SHEET] Get.context is also null');
      }
      return;
    }

    // Context geçerliyse normal şekilde devam et
    VerificationBottomSheet.show(
      context,
      title: 'otp'.tr,
      subtitle:
          '${controller.profile.value?.email} email adresinə göndərilən 6 rəqəmli şifrəni daxil edin',
      showTimer: true,
      onVerify: (otp) async {
        return await controller.submitDeleteProfileOTP(otp);
      },
      onResend: () async {
        await controller.requestDeleteProfile();
      },
    );
  }
}
