import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_theme.dart';
import '../../utils/bottom_sheet_extension.dart';
import '../../controllers/profile_controller.dart';
import 'verification_bottom_sheet.dart';

class GenderChangeBottomSheet {
  // Gender mapping - backend'e gönderilecek değerler
  static final Map<String, String> _genderMapping = {
    'male': 'male'.tr,
    'female': 'female'.tr,
  };

  static void show(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    String? selectedGenderValue;

    // Mevcut gender değerini al
    final currentGender = controller.profile.value?.gender;
    if (currentGender != null) {
      // Gender değeri 'male' veya 'female' olabilir
      if (currentGender == 'male' || currentGender == 'female') {
        selectedGenderValue = currentGender;
      }
    }

    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    context.buildBottomSheetHandle(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            'gender'.tr,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ..._genderMapping.entries.map((entry) {
                            final isSelected = selectedGenderValue == entry.key;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedGenderValue = entry.key;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).shadowColor,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).hintColor,
                                          width: 2,
                                        ),
                                        color: isSelected
                                            ? Theme.of(context)
                                                .scaffoldBackgroundColor
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 32),
                          GetBuilder<ProfileController>(
                            builder: (controller) {
                              return Obx(() => SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: controller
                                                  .isOtpSending.value ||
                                              selectedGenderValue == null
                                          ? null
                                          : () async {
                                              if (selectedGenderValue == null) {
                                                return;
                                              }

                                              Get.back();

                                              final success = await controller
                                                  .sendUpdateOTP(
                                                'gender',
                                                selectedGenderValue!,
                                              );

                                              if (success) {
                                                _showVerificationSheet(
                                                    context, controller);
                                              }
                                            },
                                      style: AppTheme.primaryButtonStyle(),
                                      child: controller.isOtpSending.value
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Platform.isIOS
                                                  ? CupertinoActivityIndicator(
                                                      radius: 10,
                                                      color: Colors.white,
                                                    )
                                                  : CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                            )
                                          : Text(
                                              'change'.tr,
                                              style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ));
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'cancel'.tr,
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
          subtitle: 'enter_otp_sent_to_email'
              .tr
              .replaceAll('{email}', controller.profile.value?.email ?? ''),
          showTimer: true,
          successMessage: 'profile_updated_successfully'.tr,
          onVerify: (otp) async {
            return await controller.verifyUpdateOTP(otp);
          },
          onResend: () async {
            await controller.resendOTP();
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
      subtitle: 'enter_otp_sent_to_email'
          .tr
          .replaceAll('{email}', controller.profile.value?.email ?? ''),
      showTimer: true,
      successMessage: 'profile_updated_successfully'.tr,
      onVerify: (otp) async {
        return await controller.verifyUpdateOTP(otp);
      },
      onResend: () async {
        await controller.resendOTP();
      },
    );
  }
}
